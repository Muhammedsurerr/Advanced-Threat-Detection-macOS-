import Foundation

// RuleEngine: Güvenlik olaylarını belirli kurallara göre analiz eden ve tehdit tespiti yapan sınıf
class RuleEngine {
    
    // Genel değerlendirme fonksiyonu
    // Verilen Event (güvenlik olayı) üzerinde çeşitli tehdit tespit fonksiyonlarını çalıştırır
    // Eğer herhangi bir tehdit tespit edilirse true döner, aksi halde false
    static func evaluate(event: Event) -> Bool {
        if detectProcessInjection(event: event) { return true }
        if detectMemoryTamper(event: event) { return true }
        if detectFilelessExecution(event: event) { return true }
        if detectCredentialDumping(event: event) { return true }
        return false
    }
    
    // Process Injection tespiti:
    // Event detaylarında API çağrısı "task_for_pid" içeriyorsa bu tür saldırı tespit edilir
    private static func detectProcessInjection(event: Event) -> Bool {
        if let api = event.details.api,
           api.contains("task_for_pid") {
            print("Process Injection tespit edildi!")
            return true
        }
        return false
    }
    
    // Memory Tampering tespiti:
    // API çağrısı içinde "ptrace" veya "rwx" geçiyorsa bellek manipülasyonu olduğu varsayılır
    private static func detectMemoryTamper(event: Event) -> Bool {
        if let api = event.details.api?.lowercased() {
            if api.contains("ptrace") || api.contains("rwx") {
                print("Memory Tamper tespit edildi!")
                return true
            }
        }
        return false
    }
    
    // Fileless Execution (dosyasız zararlı yazılım) tespiti:
    // Script bilgisi içinde "osascript" veya "jxa" var ise dosyasız zararlı yazılım olarak algılanır
    private static func detectFilelessExecution(event: Event) -> Bool {
        if let script = event.details.script,
           script.lowercased().contains("osascript") || script.lowercased().contains("jxa") {
            print("Dosyasız Zararlı Yazılım tespit edildi!")
            return true
        }
        return false
    }
    
    // Credential Dumping tespiti:
    // Method bilgisi içinde "security" veya "keychain" geçiyorsa kullanıcı kimlik bilgileri çalınmaya çalışılıyor olabilir
    private static func detectCredentialDumping(event: Event) -> Bool {
        if let method = event.details.method?.lowercased() {
            if method.contains("security") || method.contains("keychain") {
                print("Credential Dumping tespit edildi!")
                return true
            }
        }
        return false
    }
}
