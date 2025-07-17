
 // Gerçek süreçleri izleyerek tespit yapan sınıf
import Foundation

class ProcessMonitor {
    // Sistem üzerinde çalışan süreçleri çekip, tehdit analizini yapar
    static func fetchProcessList() -> [ProcessInfo] {
        // /bin/ps komutu ile tüm süreçler listelenir: pid, ppid, komut adı, argümanlar
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/ps")
        task.arguments = ["-axo", "pid,ppid,comm,args"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            // Komut çalıştırılır
            try task.run()
        } catch {
            print("ps komutu çalıştırılamadı: \(error)")
            return []
        }
        
        // Komutun çıktısı okunur
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else {
            return []
        }
        
        // Çıktı satır satır ayrılır, ilk satır başlık olduğu için atlanır
        let lines = output.split(separator: "\n").dropFirst()
        var processList: [ProcessInfo] = []
        
        for line in lines {
            // Satırdaki veriler boşluklardan ayrılır, gereksiz boşluklar temizlenir
            let parts = line.trimmingCharacters(in: .whitespaces)
                .components(separatedBy: .whitespaces)
                .filter { !$0.isEmpty }
            
            // En az 4 parça olmalı (pid, ppid, komut, argümanlar)
            if parts.count >= 4,
               let pid = Int(parts[0]),
               let ppid = Int(parts[1]) {
                let command = parts[2]
                let arguments = parts.dropFirst(3).joined(separator: " ")
                
                // ProcessInfo nesnesi oluşturulur
                var procInfo = ProcessInfo(pid: pid, ppid: ppid, name: command, arguments: arguments)
                
                // ThreatDetector ile tehdit analizi yapılır
                let analysis = ThreatDetector.analyze(process: procInfo)
                procInfo.threatDetected = analysis.detected
                procInfo.threatDetails = analysis.details
                
                processList.append(procInfo)
            }
        }
        
        return processList
    }
}

/*
// Bellek üzerinde zararlı yazılım ve dosyasız zararlı yazılım için sahte süreçler
import Foundation

class ProcessMonitor {
    static func fetchProcessList() -> [ProcessInfo] {
        // Sahte süreçler listesi, farklı türden saldırı veya zararlılar simüle edilmiş
        return [
            ProcessInfo(pid: 101, ppid: 1, command: "safesystemd", arguments: "--run clean"),          // Temiz süreç örneği
            ProcessInfo(pid: 201, ppid: 1, command: "keychainDumper", arguments: "--dump keychain"),   // Şüpheli - keychain dökme aracı
            ProcessInfo(pid: 301, ppid: 1, command: "injector_tool", arguments: "inject /bin/bash"),    // Şüpheli - süreç enjeksiyonu
            ProcessInfo(pid: 401, ppid: 1, command: "scriptRunner", arguments: "osascript memory-only eval"),  // Dosyasız zararlı örneği
            ProcessInfo(pid: 501, ppid: 1, command: "debuggerBlock", arguments: "ptrace PT_DENY_ATTACH"),      // Anti-debug teknik
        ].map { process in
            // ThreatDetector ile her süreç için analiz yapılıyor
            let result = ThreatDetector.analyze(process: process)
            var proc = process
            proc.threatDetected = result.detected
            proc.threatDetails = result.details
            return proc
        }
    }
}
*/
