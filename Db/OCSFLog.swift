import Foundation

/// OCSFLog: Açık siber güvenlik kayıt formatı.
/// Gerçek zamanlı olayların JSON olarak kaydedilmesini sağlar.
struct OCSFLog: Codable, Identifiable {
    let id: String                 // Benzersiz log ID'si
    let timestamp: Double          // Epoch zaman
    let pid: Int                   // Sürecin PID'si
    let ppid: Int                  // Üst süreç PID'si
    let processName: String        // Komut veya binary adı
    let commandLine: String        // TAM komut satırı (argümanlarla birlikte)
    let eventType: String          // Olay tipi (örneğin: credential_access)
    let details: [String: String]  // Ek bilgiler: reason, tespit tekniği, API vb.
}
