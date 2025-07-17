/*
import Foundation

// MonitoredProcess: İzlenen bir süreç (process) bilgisini tutan yapı.
// PID, PPID, komut adı ve argümanları içerir.
struct MonitoredProcess {
    let pid: Int       // Süreç ID'si
    let ppid: Int      // Üst süreç ID'si (Parent PID)
    let command: String    // Sürecin komut adı (örneğin "bash", "Safari")
    let arguments: String  // Sürecin aldığı argümanlar (parametreler)
}

// ProcessInfoMonitor: Sistemdeki çalışan süreçleri listeleyen sınıf.
class ProcessInfoMonitor {
    // Sistemdeki mevcut tüm süreçleri döner.
    static func fetchRunningProcesses() -> [MonitoredProcess] {
        let task = Process()
        // 'ps' komutunu çağırarak süreç bilgisini alıyoruz.
        task.executableURL = URL(fileURLWithPath: "/bin/ps")
        task.arguments = ["-axo", "pid,ppid,comm,args"] // PID, PPID, komut, argümanları listeler

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
        } catch {
            print("⚠️ ps komutu çalıştırılamadı: \(error)")
            return []  // Hata durumunda boş liste döner.
        }

        // Komutun çıktısını okuyup String'e çeviriyoruz.
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return [] }

        var results = [MonitoredProcess]()
        // Çıktıyı satırlara böl, ilk satır başlık olduğu için atla
        let lines = output.split(separator: "\n").dropFirst()

        for line in lines {
            // Her satırı boşluklardan ayır, boşlukları filtrele
            let parts = line.trimmingCharacters(in: .whitespaces)
                             .components(separatedBy: .whitespaces)
                             .filter { !$0.isEmpty }

            // Satırda en az 4 parça olmalı: PID, PPID, komut ve en az bir argüman
            if parts.count >= 4,
               let pid = Int(parts[0]),
               let ppid = Int(parts[1]) {
                let command = parts[2]
                // Argümanları birleştir
                let args = parts.dropFirst(3).joined(separator: " ")
                // MonitoredProcess nesnesi oluşturup listeye ekle
                results.append(MonitoredProcess(pid: pid, ppid: ppid, command: command, arguments: args))
            }
        }

        return results
    }
}
*/
