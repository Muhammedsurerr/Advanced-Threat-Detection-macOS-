/*
import Foundation

// EventSimulator: Sahte (test amaçlı) güvenlik olayları oluşturan yardımcı yapı
struct EventSimulator {
    
    // generateFakeEvents: Farklı türlerde sahte güvenlik olayları (Event) listesi döner
    static func generateFakeEvents() -> [Event] {
        return [
            // Process Injection simülasyonu: "malwareInjector" isimli kötü amaçlı işlem
            Event(
                processName: "malwareInjector",
                ppid: 1,
                eventType: "process_exec",
                pid: 1234,
                timestamp: Date().timeIntervalSince1970,
                details: EventDetails(
                    api: "task_for_pid",   // Bu API çağrısı tipik olarak süreç enjeksiyonu ile ilişkilendirilir
                    target: "launchd",
                    script: nil,
                    method: nil,
                    source: nil
                )
            ),
            
            // Dosyasız zararlı yazılım simülasyonu: osascript kullanarak script çalıştırma
            Event(
                processName: "osascript",
                ppid: 1,
                eventType: "script_exec",
                pid: 5678,
                timestamp: Date().timeIntervalSince1970,
                details: EventDetails(
                    api: nil,
                    target: nil,
                    script: "JXA",        // JavaScript for Automation (JXA) scripting
                    method: nil,
                    source: "memory-only"  // Dosyasız, bellek üzerinde çalışan zararlı
                )
            ),
            
            // Bellek manipülasyonu (Anti-debug) simülasyonu
            Event(
                processName: "debugBlocker",
                ppid: 1,
                eventType: "memory_access",
                pid: 6666,
                timestamp: Date().timeIntervalSince1970,
                details: EventDetails(
                    api: "ptrace(PT_DENY_ATTACH)",  // Debugging engelleme API çağrısı
                    target: nil,
                    script: nil,
                    method: nil,
                    source: nil
                )
            ),
            
            // Bellek manipülasyonu (RWX segment) simülasyonu
            Event(
                processName: "selfLoader",
                ppid: 1,
                eventType: "memory_exec",
                pid: 7777,
                timestamp: Date().timeIntervalSince1970,
                details: EventDetails(
                    api: "mprotect(RWX)",  // RWX (read-write-execute) segment değişikliği
                    target: nil,
                    script: nil,
                    method: nil,
                    source: nil
                )
            ),
            
            // Credential Dumping (Kimlik bilgisi çalma) simülasyonu
            Event(
                processName: "keychainStealer",
                ppid: 1,
                eventType: "credential_access",
                pid: 8888,
                timestamp: Date().timeIntervalSince1970,
                details: EventDetails(
                    api: nil,
                    target: nil,
                    script: nil,
                    method: "security",  // "security" aracı ile kimlik bilgisi erişimi
                    source: nil
                )
            ),
            
            Event(
                processName: "credentialDumpTool",
                ppid: 1,
                eventType: "credential_access",
                pid: 9999,
                timestamp: Date().timeIntervalSince1970,
                details: EventDetails(
                    api: nil,
                    target: nil,
                    script: nil,
                    method: "keychain",  // "keychain" aracı ile kimlik bilgisi erişimi
                    source: nil
                )
            )
        ]
    }
}
*/
