import Foundation

class MemoryTamperMonitor: ObservableObject {
    private var task: Process?

    func startMonitoring(scriptName: String, onDetect: @escaping (_ pid: Int, _ message: String) -> Void) {
        guard let scriptPath = Bundle.main.path(forResource: scriptName, ofType: "btf") else {
            print("❌ Script bulunamadı: \(scriptName).bt")
            return
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
        process.arguments = ["bpftrace", scriptPath]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        process.terminationHandler = { _ in
            print("📴 Memory tamper monitor process ended.")
        }
        
        do {
            try process.run()
            self.task = process
            print("🚀 Memory tamper monitoring started.")
            
            pipe.fileHandleForReading.readabilityHandler = { handle in
                let output = String(data: handle.availableData, encoding: .utf8) ?? ""
                if !output.isEmpty {
                    // Basit parse, örn: "PID 1234 ptrace detected on (processName)"
                    // Burada output'tan pid ve message çıkarılmalı
                    
                    let pid: Int
                    if let pidMatch = output.range(of: #"PID (\d+)"#, options: .regularExpression) {
                        let pidStr = String(output[pidMatch]).replacingOccurrences(of: "PID ", with: "")
                        pid = Int(pidStr) ?? 0
                    } else {
                        pid = 0
                    }
                    
                    onDetect(pid, output.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
        } catch {
            print("❌ Failed to start memory tamper monitor: \(error)")
        }
    }
    
    func stopMonitoring() {
        task?.terminate()
        task = nil
    }
}
