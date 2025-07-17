/*
import SwiftUI

// LogDetailView: Tek bir olayın (event) detaylarını gösteren sayfa.
// Event tipinde bir veri alır ve olayın tüm önemli bilgilerini listeler.
struct LogDetailView: View {
    let event: Event

    var body: some View {
        ScrollView { // İçerik uzun olursa kaydırma için ScrollView
            VStack(alignment: .leading, spacing: 12) {
                Text("🧾 Olay Detayı")
                    .font(.title2)
                    .padding(.bottom, 10)

                // Olayın temel bilgileri
                Text("🆔 ID: \(event.id.uuidString)")  // UUID olarak olay kimliği
                Text("🔍 Process: \(event.processName)")  // Süreç adı
                Text("⚙️ Event Type: \(event.eventType)")  // Olay türü
                Text("🧠 PID: \(event.pid), PPID: \(event.ppid)")  // Proses ID ve Parent PID
                Text("🕒 Zaman: \(Date(timeIntervalSince1970: event.timestamp).formatted(date: .abbreviated, time: .standard))")  // Zaman damgası, okunabilir formatta

                Divider()

                Text("📦 Detaylar:")
                    .font(.headline)

                // details içindeki opsiyonel alanlar varsa göster
                if let api = event.details.api {
                    Text("• API: \(api)")
                }
                if let target = event.details.target {
                    Text("• Hedef: \(target)")
                }
                if let script = event.details.script {
                    Text("• Script: \(script)")
                }
                if let method = event.details.method {
                    Text("• Method: \(method)")
                }
                if let source = event.details.source {
                    Text("• Kaynak: \(source)")
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Log Detayı")  
    }
}
*/
