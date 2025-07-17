import SwiftUI

// Bu görünüm, SQLite veritabanındaki tüm logları liste halinde gösterir
struct ThreatLogSQLiteView: View {
    // SQLite'tan çekilen log kayıtları
    @State private var logs: [OCSFLog] = []

    var body: some View {
        // Kayıtları listeleme
        List(logs, id: \.id) { log in
            VStack(alignment: .leading, spacing: 5) {
                // Süreç adı (örneğin: bash, curl, python)
                Text("🧾 \(log.processName)")
                    .font(.headline)

                // Zaman bilgisi - olayın gerçekleşme tarihi ve saati
                Text("📅 \(Date(timeIntervalSince1970: log.timestamp).formatted(date: .abbreviated, time: .standard))")
                    .font(.caption)

                // Olay türü (örneğin: process_exec, memory_tamper)
                Text("⚙️ Event: \(log.eventType)")
                    .font(.subheadline)

                // Eğer varsa olayın detay açıklaması
                if let reason = log.details["reason"] {
                    Text("📌 Detay: \(reason)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 4)
        }

        // Navigation bar başlığı
        .navigationTitle("SQLite Log Geçmişi")

        // Görünüm açıldığında veritabanından logları çek
        .onAppear {
            logs = ThreatLogger.shared.fetchAllLogs()
        }
    }
}
