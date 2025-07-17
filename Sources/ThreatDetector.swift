import Foundation

// ThreatDetector: Süreç komutlarını ve argümanlarını inceleyerek potansiyel tehditleri tespit eden sınıf
// Hala test amaçlı ekranda çıktı veriyor
class ThreatDetector {
    
    // analyze: Verilen ProcessInfo üzerinde çeşitli tehdit türlerini kontrol eder
    // Eğer bir tehdit tespit edilirse, (true, sebep) çiftini döner
    // Aksi halde (false, nil)
    static func analyze(process: ProcessInfo) -> (detected: Bool, details: String?) {
        let cmd = process.name.lowercased()     // Komut adı küçük harfe çevrilir
        let args = process.arguments.lowercased()  // Argümanlar küçük harfe çevrilir

        // Process Injection kontrolü
        // Komut veya argümanlar arasında "inject" veya "mach_inject" varsa şüpheli kabul edilir
        if cmd.contains("inject") || args.contains("mach_inject") {
            return mark(process, type: "process_injection", reason: "Process Injection şüphesi.")
        }

        // Credential Dumping kontrolü
        // "keychain" komut ya da argümanlarda bulunursa şüpheli kabul edilir
        if args.contains("keychain") || cmd.contains("keychain") {
            return mark(process, type: "credential_access", reason: "Credential Dumping şüphesi.")
        }

        // Dosyasız Zararlı Yazılım (Fileless Malware) kontrolü
        // Argümanlarda osascript, jxa, memory-only veya eval varsa şüpheli kabul edilir
        if args.contains("osascript") || args.contains("jxa") || args.contains("memory-only") || args.contains("eval") {
            return mark(process, type: "fileless_execution", reason: "Dosyasız zararlı yazılım şüphesi.")
        }

        // Bellek Üzerinde Şüpheli İşlem (Memory Tamper) kontrolü
        // Argümanlarda ptrace, mprotect, rwx, PT_DENY_ATTACH, inject_code varsa şüpheli kabul edilir
        if args.contains("ptrace") || args.contains("mprotect") || args.contains("rwx") || args.contains("PT_DENY_ATTACH") || args.contains("inject_code") {
            return mark(process, type: "memory_tamper", reason: "Bellek üzerinde şüpheli işlem tespit edildi.")
        }

        // Genel Malware kontrolü (Şüpheli malware benzeri isimler)
        if cmd.contains("malware") {
            return mark(process, type: "process_exec", reason: "Şüpheli malware benzeri komut tespit edildi.")
        }

        // Hiçbir tehdit tespit edilmedi
        return (false, nil)
    }

    // mark: Şüpheli süreç için OCSF formatında log oluşturur ve kaydeder
    // Ayrıca SQLite veritabanına da ekleme yapar
    // İşaretlenen sürecin tespit edildiğini ve sebebini döner
    private static func mark(_ process: ProcessInfo, type: String, reason: String) -> (Bool, String) {
        let log = OCSFLog(
            id: UUID().uuidString,
            timestamp: Date().timeIntervalSince1970,
            pid: process.pid,
            ppid: process.ppid,
            processName: process.name,
            commandLine: process.arguments, // Yeni alan burada dolduruluyor
            eventType: type,
            details: ["reason": reason]
        )
        OCSFLogger.save(log: log)
        ThreatLogger.shared.insert(log: log)
        return (true, reason)
    }

}
