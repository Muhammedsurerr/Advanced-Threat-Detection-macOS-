/*
import Foundation

// ShellExecutor: macOS/Linux terminal komutlarını çalıştırmak için yardımcı sınıf
class ShellExecutor {
    
    // run: Verilen shell komutunu çalıştırır ve çıktı olarak sonucu String döner
    // Başarısız olursa nil döner
    static func run(_ command: String) -> String? {
        let process = Process()  // Yeni bir Process örneği oluşturulur
        process.executableURL = URL(fileURLWithPath: "/bin/bash")  // Bash shell kullanılacak
        process.arguments = ["-c", command]  // Komut -c argümanı ile verilir
        
        let pipe = Pipe()  // Komut çıktısını okumak için Pipe oluşturulur
        process.standardOutput = pipe  // Standart çıktı pipe'a yönlendirilir
        
        do {
            try process.run()  // Komut çalıştırılır
        } catch {
            print("Error running command: \(error)")  // Hata varsa yazdırılır
            return nil  // Nil döndürülür
        }
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()  // Komut çıktısı okunur
        return String(data: data, encoding: .utf8)  // Çıktı UTF-8 olarak String'e çevrilir ve döner
    }
}
*/
