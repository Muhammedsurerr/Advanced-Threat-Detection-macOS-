import Foundation

// Sistem olaylarını temsil eden yapı
// Identifiable ve Codable protokollerini uygulayarak,
// SwiftUI listelerinde kullanılabilir ve JSON gibi formatlara kolayca çevrilebilir.
struct Event: Identifiable, Codable {
    let id: UUID                // Olay için benzersiz kimlik
    let processName: String     // Olayı oluşturan süreç ismi
    let ppid: Int               // Ebeveyn süreç ID'si
    let eventType: String       // Olay tipi (örn. "process_exec", "process_injection" vb.)
    let pid: Int                // Süreç ID'si
    let timestamp: TimeInterval // Olayın zamanı (Unix zaman damgası)
    let details: EventDetails   // Olayla ilgili detaylı bilgiler

    // Yapıcı fonksiyon: id opsiyonel, varsayılan olarak UUID oluşturulur
    init(id: UUID = UUID(), processName: String, ppid: Int, eventType: String, pid: Int, timestamp: TimeInterval, details: EventDetails) {
        self.id = id
        self.processName = processName
        self.ppid = ppid
        self.eventType = eventType
        self.pid = pid
        self.timestamp = timestamp
        self.details = details
    }
}

// Olay detaylarını tutan yapı
// İlgili API çağrısı, hedef, script, metod ve kaynak bilgilerini içerir
struct EventDetails: Codable {
    let api: String?     // API ismi, varsa
    let target: String?  // Hedef süreç ya da dosya
    let script: String?  // Çalıştırılan script içeriği ya da adı
    let method: String?  // Kullanılan yöntem (method)
    let source: String?  // Olayın kaynağı
}

// Çalışan süreç bilgilerini temsil eden yapı
// Identifiable olması, SwiftUI'da listelemeyi kolaylaştırır
struct ProcessInfo: Identifiable {
    let id = UUID()           // Benzersiz kimlik
    let pid: Int              // Süreç ID'si
    let ppid: Int             // Ebeveyn süreç ID'si
    let name: String       // Süreç adı/komutu
    let arguments: String     // Süreç argümanları (komut satırı parametreleri)
    var threatDetected: Bool = false  // Tehdit tespiti varsa true
    var threatDetails: String? = nil  // Tehdit ile ilgili detaylı bilgi, yoksa nil
    var threatDescription: String?
}
