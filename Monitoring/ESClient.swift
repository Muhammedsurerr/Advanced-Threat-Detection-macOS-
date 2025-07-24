import EndpointSecurity
import Foundation

@_silgen_name("audit_token_to_pid")
func audit_token_to_pid(_ token: UnsafePointer<UInt32>) -> Int32

func pidFromAuditToken(_ token: audit_token_t) -> pid_t {
    var pid: pid_t = 0
    var tokenCopy = token
    withUnsafePointer(to: &tokenCopy) {
        $0.withMemoryRebound(to: UInt32.self, capacity: 8) { tokenPtr in
            pid = audit_token_to_pid(tokenPtr)
        }
    }
    return pid
}

class ESClient {
    private var client: OpaquePointer?

    init?() {
        let result = es_new_client(&client) { client, message in
            guard let msg = message?.pointee else {
                print("Geçersiz mesaj.")
                return
            }

            guard msg.event_type == ES_EVENT_TYPE_NOTIFY_EXEC else {
                return
            }

            let exec = msg.event.exec
            let target = exec.target.pointee
            let executable = target.executable.pointee
            let pathStruct = executable.path

            guard let pathData = pathStruct.data else {
                print("Yürütülebilir yol okunamadı.")
                return
            }

            let path = String(bytesNoCopy: UnsafeMutableRawPointer(mutating: pathData),
                              length: Int(pathStruct.length),
                              encoding: .utf8,
                              freeWhenDone: false) ?? "<bilinmiyor>"

            let pid = pidFromAuditToken(target.audit_token)
            let ppid = Int(target.ppid)
            
            // Komut satırı argümanlarını topla
            var commandLine = ""
            let argc = Int(exec.argc)
            for i in 0..<argc {
                if let argPtr = exec.argv[i] {
                    commandLine += String(cString: argPtr) + " "
                }
            }
            commandLine = commandLine.trimmingCharacters(in: .whitespaces)

            // İleri düzey tespit - sadece dosya adında değil içerikte de kontrol
            let suspicious = [
                "inject", "task_for_pid", "mach_inject", "dlopen", "mprotect",
                "osascript", "SecurityAgent", "DYLD_INSERT_LIBRARIES"
            ]

            let joined = path.lowercased() + " " + commandLine.lowercased()
            let isThreat = suspicious.contains { joined.contains($0) }

            if isThreat {
                let log = OCSFLog(
                    id: UUID().uuidString,
                    timestamp: Date().timeIntervalSince1970,
                    pid: Int(pid),
                    ppid: ppid,
                    processName: path,
                    commandLine: commandLine,
                    eventType: "process_injection",
                    details: ["reason": "Şüpheli işlem içeriği tespit edildi."]
                )

                OCSFLogger.save(log: log)
                ThreatLogger.shared.insert(log: log)

                print(" Şüpheli işlem tespit edildi: \(path) (PID: \(pid))")
            } else {
                print("Normal işlem: \(path) (PID: \(pid))")
            }
        }

        guard result == ES_NEW_CLIENT_RESULT_SUCCESS, let client = client else {
            print("ES client oluşturulamadı.")
            return nil
        }

        let events: [es_event_type_t] = [ES_EVENT_TYPE_NOTIFY_EXEC]

        guard es_subscribe(client, events, UInt32(events.count)) == ES_RETURN_SUCCESS else {
            print("Subscribe başarısız.")
            return nil
        }

        print("ESClient başlatıldı.")
    }

    deinit {
        if let client = client {
            es_delete_client(client)
        }
    }
}
