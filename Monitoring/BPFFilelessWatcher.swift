import Foundation

class BPFFilelessWatcher: ObservableObject {
    private var monitoring = false
    
    func startMonitoring(scriptName: String, processDetectedCallback: @escaping (Int, String) -> Void) {
        guard !monitoring else { return }
        monitoring = true
        
        guard let scriptPath = Bundle.main.path(forResource: "ptrace", ofType: "btf") else {
            print("BPF script bulunamadı")
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/bpftrace")
            task.arguments = [scriptPath]

            
            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe
            
            do {
                try task.run()
            } catch {
                print("BPFtrace çalıştırılamadı: \(error)")
                self.monitoring = false
                return
            }
            
            pipe.fileHandleForReading.readabilityHandler = { fileHandle in
                if let line = String(data: fileHandle.availableData, encoding: .utf8) {
                    self.parseOutput(line: line, callback: processDetectedCallback)
                }
            }
            
            task.waitUntilExit()
            self.monitoring = false
        }
    }
    
    private func parseOutput(line: String, callback: @escaping (Int, String) -> Void) {
        let pattern = #"PID:(\d+)\s+Message:(.+)"#
        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
           let match = regex.firstMatch(in: line, options: [], range: NSRange(line.startIndex..., in: line)) {
            
            if let pidRange = Range(match.range(at: 1), in: line),
               let messageRange = Range(match.range(at: 2), in: line),
               let pid = Int(line[pidRange]) {
                let message = String(line[messageRange])
                DispatchQueue.main.async {
                    callback(pid, message)
                }
            }
        }
    }
}
