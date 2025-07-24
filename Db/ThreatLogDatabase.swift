//  Bu sınıf, uygulama tarafından tespit edilen tehdit olaylarını SQLite veritabanına kaydeder,
//  geçmiş logları okur ve istatistiksel analiz için kullanılabilir hale getirir.
//

import Foundation
import SQLite

// Singleton sınıf: Tüm loglama işlemleri buradan yönetilir
class ThreatLogger {
    static let shared = ThreatLogger() // Global erişim için tek bir nesne

    // SQLite bağlantısı
    private var db: Connection!
    
    // Logların tutulduğu tablo referansı
    private let logs = Table("threat_logs")

    // Tablodaki sütunlar
    private let id = Expression<String>("id")
    private let timestamp = Expression<Double>("timestamp")
    private let pid = Expression<Int>("pid")
    private let ppid = Expression<Int>("ppid")
    private let processName = Expression<String>("processName")
    private let eventType = Expression<String>("eventType")
    private let details = Expression<String>("details") // JSON string

    // Sınıf ilk oluşturulduğunda çağrılır
    private init() {
        setupDatabase()
    }

    // Veritabanı yapılandırması
    private func setupDatabase() {
        do {
            // Kullanıcı doküman dizinine şifreli veritabanı konumu
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dbPath = documents.appendingPathComponent("threat_logs_encrypted.sqlite").path
            db = try Connection(dbPath)

            //  SQLCipher kullanıyorsan 
            // try db.key("sifre")

            // Tabloyu oluştur (zaten varsa oluşturma)
            try db.run(logs.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(timestamp)
                t.column(pid)
                t.column(ppid)
                t.column(processName)
                t.column(eventType)
                t.column(details) // JSON formatında açıklayıcı bilgiler
            })

            print(" SQLite veritabanı oluşturuldu: \(dbPath)")
        } catch {
            print(" Veritabanı hatası: \(error)")
        }
    }

    // Yeni log ekleme (JSON olarak detayları saklar)
    func insert(log: OCSFLog) {
        do {
            // details: [String: String] → JSON string'e dönüştür
            let jsonDetails = try JSONSerialization.data(withJSONObject: log.details, options: [])
            let jsonString = String(data: jsonDetails, encoding: .utf8) ?? "{}"
            
            // SQLite'a ekle
            try db.run(logs.insert(
                id <- log.id,
                timestamp <- log.timestamp,
                pid <- log.pid,
                ppid <- log.ppid,
                processName <- log.processName,
                eventType <- log.eventType,
                details <- jsonString
            ))
            print(" Log başarıyla SQLite’a eklendi: \(log.processName)")
        } catch {
            print(" Log ekleme hatası: \(error)")
        }
    }

    // Tüm logları getir (detayları JSON'dan tekrar [String: String]'e dönüştür)
    func fetchAllLogs() -> [OCSFLog] {
        var results: [OCSFLog] = []
        
        do {
            for row in try db.prepare(logs) {
                if let detailsData = row[details].data(using: .utf8),
                   let detailsDict = try? JSONSerialization.jsonObject(with: detailsData) as? [String: String] {
                    
                    let log = OCSFLog(
                        id: row[id],
                        timestamp: row[timestamp],
                        pid: row[pid],
                        ppid: row[ppid],
                        processName: row[processName],
                        commandLine: "", // SQLite henüz bu alanı tutmadığı için geçici olarak boş
                        eventType: row[eventType],
                        details: detailsDict
                    )

                    results.append(log)
                }
            }
        } catch {
            print(" Kayıtlar okunamadı: \(error)")
        }
        
        return results
    }

    // Her bir eventType için kaç adet kayıt var? → İstatistiksel analiz için
    func countByEventType() -> [String: Int] {
        var result: [String: Int] = [:]

        do {
            for row in try db.prepare(logs) {
                let type = row[eventType]
                result[type, default: 0] += 1
            }
        } catch {
            print(" Sayım hatası: \(error)")
        }

        return result
    }
}
