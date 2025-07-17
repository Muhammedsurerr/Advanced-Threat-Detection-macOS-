import SwiftUI

// ProcessDetailView: Tek bir process bilgisinin detaylarını gösterir.
// ProcessInfo tipinde bir veri alır ve o process ile ilgili tüm kritik bilgileri listeler.
struct ProcessDetailView: View {
    let process: ProcessInfo  

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Process Detail")
                .font(.title2)
                .padding(.bottom)

            // Process temel bilgileri
            Text("PID: \(process.pid)")
            Text("PPID: \(process.ppid)")
            Text("Name: \(process.name)")
            Text("Arguments: \(process.arguments)")

            // Eğer bu process için tehdit tespit edildiyse uyarı göster
            if process.threatDetected {
                Text("⚠️ Threat Detected:")
                    .font(.headline)
                    .foregroundColor(.red)
                Text(process.threatDetails ?? "Bilinmiyor")
            } else {
                Text("No Threat Detected")
                    .foregroundColor(.green)
            }

            Spacer()
        }
        .padding()
    }
}

