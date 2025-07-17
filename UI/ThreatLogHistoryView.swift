import SwiftUI

struct ThreatLogHistoryView: View {
    @State private var allEvents: [OCSFLog] = []
    @State private var selectedType: String = "Tümü"
    
    let eventTypes: [String] = [
        "Tümü",
        "process_exec",
        "process_injection",
        "fileless_execution",
        "credential_access",
        "memory_tamper"
    ]
    
    var filteredEvents: [OCSFLog] {
        if selectedType == "Tümü" {
            return allEvents.sorted { $0.timestamp > $1.timestamp }
        } else {
            return allEvents
                .filter { $0.eventType == selectedType }
                .sorted { $0.timestamp > $1.timestamp }
        }
    }
    
    var eventTypeCounts: [String: Int] {
        Dictionary(grouping: allEvents, by: { $0.eventType })
            .mapValues { $0.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Özet kutuları
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(eventTypes.filter { $0 != "Tümü" }, id: \.self) { type in
                        let count = eventTypeCounts[type] ?? 0
                        VStack {
                            Text("\(count)")
                                .font(.title2)
                                .bold()
                            Text(type)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 80, height: 60)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Filtreleme ve kayıt sayısı
            HStack {
                Text("🧾 Kayıt Sayısı: \(filteredEvents.count)")
                    .font(.caption)
                
                Spacer()
                
                Picker("Olay Türü", selection: $selectedType) {
                    ForEach(eventTypes, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            .padding(.horizontal)
            
            Divider()
            
            // Liste görünümü
            List(filteredEvents, id: \.id) { event in
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.processName)
                        .font(.headline)
                    
                    Text("🕒 \(Date(timeIntervalSince1970: event.timestamp).formatted(date: .abbreviated, time: .standard))")
                        .font(.caption)
                    
                    Text("📂 Tür: \(event.eventType)")
                        .font(.caption2)
                    
                    if let reason = event.details["reason"] {
                        Text("📌 \(reason)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .onAppear {
            allEvents = ThreatLogger.shared.fetchAllLogs()
        }
    }
}
