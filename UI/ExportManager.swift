import Foundation
import AppKit

// ExportManager: Log dosyasını kullanıcıya kaydetmesi için gösterilen arayüzü ve
// dosya kopyalama işlemini yöneten yardımcı sınıf
class ExportManager {
    // Log dosyasını kullanıcı tarafından seçilen konuma kopyalar
    static func exportLogFile() {
        let fileManager = FileManager.default
        // Kullanıcının Belgeler dizini yolu
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Gerçek log dosyasının tam yolu (threat_logs.json)
        let logFileURL = documentsURL.appendingPathComponent("threat_logs.json")
        
        // Eğer log dosyası yoksa hata mesajı yazdır ve işlemi durdur
        guard fileManager.fileExists(atPath: logFileURL.path) else {
            print("❌ Log dosyası bulunamadı: \(logFileURL.path)")
            return
        }

        // NSSavePanel: Kullanıcının dosyayı kaydetmek istediği yeri seçmesi için standart macOS diyalogu
        let savePanel = NSSavePanel()
        savePanel.title = "Log Dosyasını Kaydet"  // Panel başlığı
        // Kaydedilecek dosya için varsayılan isim (tarih formatlı)
        savePanel.nameFieldStringValue = "threat_log_\(Date().formatted(date: .numeric, time: .omitted)).json"
        savePanel.allowedContentTypes = [.json]  // Sadece JSON dosyası olarak kaydetme izni
        
        // Panel açılır ve kullanıcı işlem yapana kadar bekler
        savePanel.begin { result in
            // Eğer kullanıcı "Kaydet" butonuna bastıysa ve geçerli bir URL seçildiyse
            if result == .OK, let destinationURL = savePanel.url {
                do {
                    // Log dosyasını seçilen yere kopyala
                    try fileManager.copyItem(at: logFileURL, to: destinationURL)
                    print("✅ Log başarıyla dışa aktarıldı: \(destinationURL.path)")
                } catch {
                    // Kopyalama sırasında hata olursa yazdır
                    print("❌ Dışa aktarma hatası: \(error.localizedDescription)")
                }
            }
        }
    }
}
