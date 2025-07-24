import Foundation

// OCSFLogger: OCSF formatındaki logları JSON dosyasına kaydetmek için kullanılan yardımcı sınıf.
class OCSFLogger {
    
    // save(log:) fonksiyonu, verilen OCSFLog nesnesini "threat_logs.json" dosyasına ekler.
    static func save(log: OCSFLog) {
        let fileManager = FileManager.default
        // Kullanıcının belge (Documents) dizin yolu
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let logFile = docs.appendingPathComponent("threat_logs.json") // Logların tutulduğu dosya
        
        var logs: [OCSFLog] = []  // Var olan logların tutulacağı dizi
        
        // Eğer log dosyası varsa içeriğini oku ve mevcut loglar dizisine yükle
        if let data = try? Data(contentsOf: logFile),
           let existing = try? JSONDecoder().decode([OCSFLog].self, from: data) {
            logs = existing
        }
        
        // Yeni logu mevcut loglar dizisine ekle
        logs.append(log)
        
        do {
            // Güncellenmiş log dizisini JSON formatında encode et
            let data = try JSONEncoder().encode(logs)
            // JSON verisini dosyaya yaz
            try data.write(to: logFile)
            print(" OCSF log JSON'a kaydedildi: \(logFile.path)")
        } catch {
            // Yazma sırasında hata olursa konsola hata mesajı bas
            print(" JSON log yazma hatası: \(error)")
        }
    }
}
