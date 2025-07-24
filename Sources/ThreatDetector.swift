import Foundation

class ThreatDetector {
    
    // analyze: Verilen ProcessInfo üzerinde çeşitli tehdit türlerini kontrol eder
    // Eğer bir tehdit tespit edilirse, (true, sebep) çiftini döner, aksi halde (false, nil)
    static func analyze(process: ProcessInfo) -> (detected: Bool, details: String?) {
        let cmd = process.name.lowercased()        // Komut adı
        let args = process.arguments.lowercased()  // Argümanlar

        // MARK: - 1. Process Injection (T1055.002)
        // Yaygın injection araçları ve fonksiyon isimleri
        let injectionIndicators = [
            "inject", "mach_inject", "task_for_pid", "dlopen", "dlsym", "mach_vm_write",
            "mach_vm_allocate", "pthread_create", "thread_create", "libinject", "remote_call",
            "dyld_insert_libraries"
        ]
        if injectionIndicators.contains(where: { cmd.contains($0) || args.contains($0) }) {
            return mark(process, type: "process_injection", reason: "Process Injection (T1055.002) belirtisi.")
        }

        // MARK: - 2. Credential Dumping (T1555.004)
        let credentialIndicators = [
            "keychain", "security find-generic-password", "security dump-keychain",
            "/usr/bin/security", "keychain_dump", "SecKey", "SecItemCopy", "SecKeychain"
        ]
        if credentialIndicators.contains(where: { cmd.contains($0) || args.contains($0) }) {
            return mark(process, type: "credential_access", reason: "Credential Dumping (T1555.004) şüphesi.")
        }

        // MARK: - 3. Fileless Malware Execution (T1059.002)
        let filelessIndicators = [
            "osascript", "jxa", "memory-only", "eval", "run script", "NSAppleScript",
            "AppleScript", "do shell script"
        ]
        if filelessIndicators.contains(where: { cmd.contains($0) || args.contains($0) }) {
            return mark(process, type: "fileless_execution", reason: "Dosyasız Zararlı Yazılım (T1059.002) belirtisi.")
        }

        // MARK: - 4. Memory Tampering / Anti-Debug (T1620)
        let memoryIndicators = [
            "ptrace", "PT_DENY_ATTACH", "mprotect", "rwx", "memcpy", "virtualprotect",
            "memory tamper", "hook", "inject_code", "syscall intercept"
        ]
        if memoryIndicators.contains(where: { cmd.contains($0) || args.contains($0) }) {
            return mark(process, type: "memory_tamper", reason: "Bellek üzerinde şüpheli işlem (T1620).")
        }

        // MARK: - 5. Genel Malware Adı / Şablon Tespiti
        let suspiciousNames = ["malware", "trojan", "ransom", "spy", "stealer"]
        if suspiciousNames.contains(where: { cmd.contains($0) }) {
            return mark(process, type: "process_exec", reason: "Şüpheli malware adı içeriyor.")
        }

        // Tehdit tespit edilmedi
        return (false, nil)
    }

    // mark: Şüpheli süreç için OCSF log kaydı oluşturur
    private static func mark(_ process: ProcessInfo, type: String, reason: String) -> (Bool, String) {
        let log = OCSFLog(
            id: UUID().uuidString,
            timestamp: Date().timeIntervalSince1970,
            pid: process.pid,
            ppid: process.ppid,
            processName: process.name,
            commandLine: process.arguments,
            eventType: type,
            details: ["reason": reason]
        )
        OCSFLogger.save(log: log)
        ThreatLogger.shared.insert(log: log)
        return (true, reason)
    }
    static func processContainsRWXMemory(pid: Int32) -> Bool {
            // Swift wrapper kullanılabilir: task_for_pid + vm_region
            // Burada sadece örnek bir kontrol gösterimi
            let output = shell(["vmmap", String(pid)])
            return output.contains("rwx")
        }

        static func containsSuspiciousStringsInMemory(pid: Int32) -> Bool {
            let output = shell(["strings", "/proc/\(pid)/exe"])
            let keywords = ["task_for_pid", "dlopen", "eval", "osascript", "secitemcopy", "ptrace"]
            return keywords.contains { output.contains($0) }
        }

        static func processHasSuspiciousOpenFiles(pid: Int32) -> Bool {
            let output = shell(["lsof", "-p", String(pid)])
            return output.contains("/tmp") || output.contains(".dylib")
        }

        // MARK: - Shell Executor
        @discardableResult
        static func shell(_ args: [String]) -> String {
            let task = Process()
            task.launchPath = "/usr/bin/env"
            task.arguments = args

            let pipe = Pipe()
            task.standardOutput = pipe
            task.launch()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8) ?? ""
        }
    }


