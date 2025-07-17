/*
import Foundation

// Tehdit tespit sonucunu temsil eden yapı
// Identifiable protokolü, SwiftUI'da listeleme için gereklidir.
struct ThreatDetectionResult: Identifiable {
    let id = UUID()          // Benzersiz kimlik
    let pid: String          // Süreç ID'si (string olarak)
    let command: String      // Süreç komut adı
    let threatType: String   // Tespit edilen tehdit türü (örneğin: Process Injection)
}

// Süreç komutlarını analiz ederek potansiyel tehditleri tespit eden sınıf
class ProcessAnalyzer {
    // Parametre olarak (pid, command) çiftlerinden oluşan süreç dizisi alır
    // Tehdit olarak işaretlenen süreçlerin listesini döner
    static func analyze(processes: [(pid: String, command: String)]) -> [ThreatDetectionResult] {
        var results: [ThreatDetectionResult] = []
        
        for proc in processes {
            let cmd = proc.command.lowercased() // Komutu küçük harfe çevirerek kontrolü kolaylaştırır
            
            // Komut içinde anahtar kelimeler aranır ve bulunan tehdit türü belirlenir
            if cmd.contains("task_for_pid") {
                // Süreç enjeksiyonu (process injection) belirtisi
                results.append(ThreatDetectionResult(pid: proc.pid, command: proc.command, threatType: "Process Injection"))
            } else if cmd.contains("osascript") || cmd.contains("jxa") {
                // Dosyasız zararlı yazılım (fileless malware) belirtisi
                results.append(ThreatDetectionResult(pid: proc.pid, command: proc.command, threatType: "Fileless Malware"))
            } else if cmd.contains("ptrace") || cmd.contains("rwx") {
                // Bellek manipülasyonu (memory tamper) belirtisi
                results.append(ThreatDetectionResult(pid: proc.pid, command: proc.command, threatType: "Memory Tamper"))
            } else if cmd.contains("keychain") || cmd.contains("security") {
                // Kimlik bilgisi hırsızlığı (credential dumping) belirtisi
                results.append(ThreatDetectionResult(pid: proc.pid, command: proc.command, threatType: "Credential Dumping"))
            }
        }
        
        return results
    }
}
*/
