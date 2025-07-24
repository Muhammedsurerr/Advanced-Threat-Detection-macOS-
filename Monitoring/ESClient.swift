import EndpointSecurity
import Foundation

// C fonksiyonu Swift'te kullanmak için declare ediyoruz:
@_silgen_name("audit_token_to_pid")
func audit_token_to_pid(_ token: UnsafePointer<UInt32>) -> Int32

// Audit token'dan PID almayı sağlayan yardımcı fonksiyon:
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
            let msg = message.pointee

            if msg.event_type == ES_EVENT_TYPE_NOTIFY_EXEC {
                let exec = msg.event.exec
                let target = exec.target.pointee  // es_process_t
                
                let executable = target.executable.pointee
                let pathStruct = executable.path

                guard let pathData = pathStruct.data else {
                    print("Executable path okunamadı.")
                    return
                }

                let pathString = String(bytesNoCopy: UnsafeMutableRawPointer(mutating: pathData),
                                        length: Int(pathStruct.length),
                                        encoding: .utf8,
                                        freeWhenDone: false) ?? "<bilinmiyor>"
                
                let pid = pidFromAuditToken(target.audit_token)
                
                // PPID için EndpointSecurity API içinde doğrudan yok, geçici 0 kullanalım
                let ppid: Int = 0

                if pathString.lowercased().contains("inject") ||
                    pathString.lowercased().contains("task_for_pid") ||
                    pathString.lowercased().contains("mach_inject") {

                    let log = OCSFLog(
                        id: UUID().uuidString,
                        timestamp: Date().timeIntervalSince1970,
                        pid: Int(pid),
                        ppid: ppid,
                        processName: pathString,
                        commandLine: "",
                        eventType: "process_injection",
                        details: ["reason": "Yürütülen süreç task_for_pid veya benzeri içeriyor."]
                    )

                    OCSFLogger.save(log: log)
                    ThreatLogger.shared.insert(log: log)

                    print(" Process Injection şüphesi: \(pathString) (PID: \(pid))")
                } else {
                    print(" Process exec: \(pathString) (PID: \(pid))")
                }
            }
        }

        if result != ES_NEW_CLIENT_RESULT_SUCCESS || client == nil {
            print(" ES client oluşturulamadı.")
            return nil
        }

        let events: [es_event_type_t] = [ES_EVENT_TYPE_NOTIFY_EXEC]

        if es_subscribe(client!, events, UInt32(events.count)) != ES_RETURN_SUCCESS {
            print(" Subscribe başarısız.")
            return nil
        }

        print(" ESClient aktif.")
    }

    deinit {
        if let client = client {
            es_delete_client(client)
        }
    }
}
