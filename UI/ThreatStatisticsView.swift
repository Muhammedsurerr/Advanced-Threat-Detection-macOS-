//  Bu görünüm, kullanıcıya tehdit kayıtlarına dair özet istatistikleri,
//  en sık karşılaşılan süreçleri ve son 5 olayı sunar.

import SwiftUI

struct ThreatStatisticsView: View {
    // SQLite'tan çekilen tüm tehdit logları
    @State private var logs: [OCSFLog] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Başlık
            Text("📊 Tehdit İstatistikleri")
                .font(.title2)
                .padding(.bottom, 8)

            // Toplam olay sayısı
            Text("Toplam Olay: \(logs.count)")
                .font(.headline)

            // Tür bazında dağılım (boş değilse)
            if !threatCounts.isEmpty {
                Text("🧬 Türlere Göre Dağılım:")
                    .font(.subheadline)

                // Her bir tür ve adedi
                ForEach(threatCounts.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                    HStack {
                        Text("• \(key)") // Tür adı
                        Spacer()
                        Text("\(value)") // Adet
                    }
                }
            }

            // En sık görülen process
            if let mostFrequentProcess = mostFrequentProcess() {
                Divider()
                Text("🔥 En Sık Görülen Süreç:")
                    .font(.subheadline)

                Text(mostFrequentProcess)
                    .foregroundColor(.blue)
            }

            // Son 5 olay
            Divider()
            Text("🕒 Son 5 Olay:")
                .font(.subheadline)

            ForEach(recentLogs.prefix(5), id: \.id) { log in
                VStack(alignment: .leading) {
                    Text("• \(log.processName) (\(log.eventType))")
                    Text(Date(timeIntervalSince1970: log.timestamp).formatted(date: .abbreviated, time: .standard))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }

            Spacer() // Kalan alanı boş bırak
        }
        .padding()
        .onAppear {
            // View yüklendiğinde logları çek
            logs = ThreatLogger.shared.fetchAllLogs()
        }
        .frame(minWidth: 300) // Sabit minimum genişlik
    }

    // 📌 Tehdit türlerine göre adet sayımı
    private var threatCounts: [String: Int] {
        Dictionary(grouping: logs, by: { $0.eventType })
            .mapValues { $0.count }
    }

    // 🔍 En sık geçen processName’i bul
    private func mostFrequentProcess() -> String? {
        let countMap = Dictionary(grouping: logs, by: { $0.processName })
            .mapValues { $0.count }

        return countMap.max { $0.value < $1.value }?.key
    }

    // 🕒 Zaman bazlı sıralı log listesi
    private var recentLogs: [OCSFLog] {
        logs.sorted { $0.timestamp > $1.timestamp }
    }
}
