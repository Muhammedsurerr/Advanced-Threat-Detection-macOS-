import Foundation
import SQLite

// LogManager: SQLite tabanlı JSON formatında log verilerini kaydetmek, okumak ve dışa aktarmak için singleton sınıf
class LogManager {
    static let shared = LogManager()

    private var db: Connection?                 // SQLite bağlantısı
    private let logsTable = Table("logs")      // Tablo adı
    private let id = Expression<String>("id")  // Primary key olarak UUID string
    private let json = Expression<String>("json") // Event objesinin JSON hali

    private init() {
        // Veritabanı dosyasının yolu (Documents dizini)
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        print("📁 Veritabanı dizini: \(path)")
        do {
            // SQLite bağlantısını oluştur
            db = try Connection("\(path)/logs.sqlite3")

            // Eğer tablo yoksa oluştur
            try db?.run(logsTable.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(json)
            })
        } catch {
            db = nil
            print("❌ SQLite bağlantısı kurulamadı: \(error)")
        }
    }

    // Yeni bir event log kaydı ekle
    func log(event: Event) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            // Event objesini JSON stringe dönüştür
            let jsonData = try encoder.encode(event)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else { return }

            // Konsola yazdır
            print("🚨 OCSF JSON Log:\n\(jsonString)")

            // SQLite tablosuna ekle
            let insert = logsTable.insert(id <- UUID().uuidString, json <- jsonString)
            try db?.run(insert)
        } catch {
            print("❌ Log kaydı yapılamadı: \(error)")
        }
    }

    // Tüm logları oku ve Event dizisi olarak döndür
    func fetchLoggedEvents() -> [Event] {
        var events = [Event]()

        do {
            for row in try db!.prepare(logsTable) {
                let jsonString = row[json]
                if let jsonData = jsonString.data(using: .utf8) {
                    let event = try JSONDecoder().decode(Event.self, from: jsonData)
                    events.append(event)
                }
            }
        } catch {
            print("❌ Loglar okunamadı: \(error)")
        }

        return events
    }

    // Tüm logları sil
    func clearAllLogs() {
        do {
            try db?.run(logsTable.delete())
            print("🧹 Tüm loglar silindi.")
        } catch {
            print("❌ Loglar silinemedi: \(error)")
        }
    }

    // Logları JSON dosyası olarak masaüstüne dışa aktar
    func exportLogs(_ events: [Event]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(events)

            let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
            let exportURL = desktopURL.appendingPathComponent("exported_logs.json")

            try jsonData.write(to: exportURL)
            print("✅ Loglar başarıyla dışa aktarıldı: \(exportURL.path)")
        } catch {
            print("❌ Log dışa aktarma hatası: \(error)")
        }
    }
}
