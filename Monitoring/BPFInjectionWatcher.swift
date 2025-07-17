import Foundation

class BPFInjectionWatcher: ObservableObject {
    private var monitoring = false

    func startMonitoring(scriptName: String, processDetectedCallback: @escaping (Int, String) -> Void) {
        guard !monitoring else { return }
        monitoring = true

        guard let scriptPath = Bundle.main.path(forResource: scriptName, ofType: "btf") else {
            print("❌ BPF script bulunamadı: \(scriptName).btf")
            monitoring = false
            return
        }
        print("✅ BPF script yolu bulundu: \(scriptPath)")

        // Script içeriğini oku, test için yazdır
        do {
            let content = try String(contentsOfFile: scriptPath, encoding: .utf8)
            print("📄 Script içeriği:\n\(content)")
        } catch {
            print("❌ Script okunamadı: \(error)")
        }

        // Burada script çalıştırılacak kısmı geçici kapatalım ya da açalım:
        DispatchQueue.global(qos: .background).async {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
            task.arguments = ["bpftrace", scriptPath]

            let pipe = Pipe()
            task.standardOutput = pipe
            task.standardError = pipe

            do {
                try task.run()
            } catch {
                print("❌ BPFtrace çalıştırılamadı: \(error)")
                self.monitoring = false
                return
            }

            pipe.fileHandleForReading.readabilityHandler = { fileHandle in
                if let line = String(data: fileHandle.availableData, encoding: .utf8) {
                    print("📢 BPFtrace çıktı: \(line)")
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

    // Test için: script var mı yok mu direkt kontrol
    func testScriptPresence(scriptName: String) {
        if let scriptPath = Bundle.main.path(forResource: scriptName, ofType: "btf") {
            print("✅ Test: Script bulundu: \(scriptPath)")
        } else {
            print("❌ Test: Script bulunamadı: \(scriptName).btf")
        }
    }
}
