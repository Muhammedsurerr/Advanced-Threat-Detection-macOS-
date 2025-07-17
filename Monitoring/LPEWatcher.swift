import Foundation

class LPEWatcher {
    private var task: Process?

    func startMonitoring(scriptName: String, onDetect: @escaping (_ pid: Int, _ message: String) -> Void) {
        guard let scriptPath = Bundle.main.path(forResource: scriptName, ofType: "btf") else {
            print("⚠️ Script not found: \(scriptName).btf")
            return
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
        process.arguments = ["bpftrace", scriptPath]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        process.terminationHandler = { _ in
            print("📴 LPEWatcher terminated")
        }

        do {
            try process.run()
            self.task = process
            print("🚀 LPEWatcher monitoring started")

            pipe.fileHandleForReading.readabilityHandler = { handle in
                let output = String(data: handle.availableData, encoding: .utf8) ?? ""
                if output.contains("LPE attempt detected") {
                    let pidMatch = output.range(of: #"PID (\d+)"#, options: .regularExpression)
                    let pidStr = pidMatch != nil ? String(output[pidMatch!]).replacingOccurrences(of: "PID ", with: "") : "0"
                    let pid = Int(pidStr) ?? 0
                    onDetect(pid, output.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
        } catch {
            print("❌ Could not start LPEWatcher: \(error)")
        }
    }

    func stopMonitoring() {
        task?.terminate()
        task = nil
    }
}
