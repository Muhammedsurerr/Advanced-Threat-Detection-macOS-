
import SwiftUI

struct ContentView: View {
    
    @State private var runningProcesses: [ProcessInfo] = []
    @State private var selectedProcess: ProcessInfo? = nil
    @State private var scanStarted = false
    @State private var showOnlyThreats = false
    @State private var showEventHistory = false
    @State private var showSQLiteLogView = false
    @State private var showStatistics = false
    
    @StateObject private var injectionWatcher = BPFInjectionWatcher()
    @StateObject private var antiExploitWatcher = AntiExploitWatcher()
    @StateObject private var credentialWatcher = CredentialDumpingWatcher()
    @StateObject private var filelessWatcher = BPFFilelessWatcher()
    @StateObject private var memoryTamperMonitor = MemoryTamperMonitor()




    var body: some View {
        NavigationView {
            if !scanStarted {
                VStack(spacing: 30) {
                    Spacer()
                
                    Text("🛡️ Davranışsal Tehdit Algılama")
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                    
                    Text("MacOS sisteminizdeki süreçlerde şüpheli davranışları analiz etmek için taramayı başlatın.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button(action: {
                        // Süreçleri çek ve tehdit analizi yaparak sırala
                        runningProcesses = ProcessMonitor.fetchProcessList()
                            .map { proc in
                                var mutableProc = proc
                                let analysis = ThreatDetector.analyze(process: proc)
                                mutableProc.threatDetected = analysis.detected
                                mutableProc.threatDescription = analysis.details
                                return mutableProc
                            }
                            .sorted { $0.threatDetected && !$1.threatDetected }
                        
                        // Injection watcher başlat
                        injectionWatcher.startMonitoring(scriptName: "task_for_pid") { pid, message in
                            DispatchQueue.main.async {
                                runningProcesses.removeAll { $0.pid == pid }

                                let injectedProcess = ProcessInfo(
                                    pid: pid,
                                    ppid: 0,
                                    name: "Unknown (Injection)",
                                    arguments: "",
                                    threatDetected: true,
                                    threatDetails: nil,
                                    threatDescription: message
                                )

                                runningProcesses.append(injectedProcess)

                                // 📥 OCSF log oluştur ve hem dosyaya hem SQLite’a kaydet
                                let log = OCSFLog(
                                    id: UUID().uuidString,
                                    timestamp: Date().timeIntervalSince1970,
                                    pid: pid,
                                    ppid: 0,
                                    processName: "Unknown (Injection)",
                                    commandLine: "",        
                                    eventType: "process_injection",
                                    details: ["reason": message]
                                )

                                OCSFLogger.save(log: log)
                                ThreatLogger.shared.insert(log: log)
                            }
                        }
                        
                        // AntiExploit watcher başlat
                        antiExploitWatcher.startMonitoring { pid, message in
                            DispatchQueue.main.async {
                                runningProcesses.removeAll { $0.pid == pid }
                                let suspiciousProcess = ProcessInfo(
                                    pid: pid,
                                    ppid: 0,
                                    name: "Unknown (AntiExploit Alert)",
                                    arguments: "",
                                    threatDetected: true,
                                    threatDetails: nil,
                                    threatDescription: message
                                )
                                runningProcesses.append(suspiciousProcess)

                                // 💾 Log kaydı
                                let log = OCSFLog(
                                    id: UUID().uuidString,
                                    timestamp: Date().timeIntervalSince1970,
                                    pid: pid,
                                    ppid: 0,
                                    processName: "Unknown (AntiExploit Alert)",
                                    commandLine: "",
                                    eventType: "memory_tamper",
                                    details: ["reason": message]
                                )
                                OCSFLogger.save(log: log)
                                ThreatLogger.shared.insert(log: log)
                            }
                        }
                        
                        // Credential Dumping izleyicisi başlat
                        credentialWatcher.startMonitoring { pid, message in
                            DispatchQueue.main.async {
                                runningProcesses.removeAll { $0.pid == pid }
                                let suspiciousProcess = ProcessInfo(
                                    pid: pid,
                                    ppid: 0,
                                    name: "Unknown (Credential CLI)",
                                    arguments: "",
                                    threatDetected: true,
                                    threatDetails: nil,
                                    threatDescription: message
                                )
                                runningProcesses.append(suspiciousProcess)

                                // SQLite log kaydı
                                let log = OCSFLog(
                                    id: UUID().uuidString,
                                    timestamp: Date().timeIntervalSince1970,
                                    pid: pid,
                                    ppid: 0,
                                    processName: "security",
                                    commandLine: "",
                                    eventType: "credential_access",
                                    details: ["reason": message]
                                )
                                OCSFLogger.save(log: log)
                                ThreatLogger.shared.insert(log: log)
                            }
                        }
                        // Başlatma kısmı:
                        filelessWatcher.startMonitoring(scriptName: "fileless_detection") { pid, message in
                            DispatchQueue.main.async {
                                runningProcesses.removeAll { $0.pid == pid }
                                let suspiciousProcess = ProcessInfo(
                                    pid: pid,
                                    ppid: 0,
                                    name: "Unknown (Fileless Malware Alert)",
                                    arguments: "",
                                    threatDetected: true,
                                    threatDetails: nil,
                                    threatDescription: message
                                )
                                runningProcesses.append(suspiciousProcess)

                                let log = OCSFLog(
                                    id: UUID().uuidString,
                                    timestamp: Date().timeIntervalSince1970,
                                    pid: pid,
                                    ppid: 0,
                                    processName: "Unknown (Fileless Malware Alert)",
                                    commandLine: "",
                                    eventType: "fileless_execution",
                                    details: ["reason": message]
                                )
                                OCSFLogger.save(log: log)
                                ThreatLogger.shared.insert(log: log)
                            }
                        }
                        
                        memoryTamperMonitor.startMonitoring(scriptName: "memory_tamper") { pid, message in
                            DispatchQueue.main.async {
                                runningProcesses.removeAll { $0.pid == pid }
                                let suspiciousProcess = ProcessInfo(
                                    pid: pid,
                                    ppid: 0,
                                    name: "Unknown (Memory Tamper Alert)",
                                    arguments: "",
                                    threatDetected: true,
                                    threatDetails: nil,
                                    threatDescription: message
                                )
                                runningProcesses.append(suspiciousProcess)

                                let log = OCSFLog(
                                    id: UUID().uuidString,
                                    timestamp: Date().timeIntervalSince1970,
                                    pid: pid,
                                    ppid: 0,
                                    processName: "Unknown (Memory Tamper Alert)",
                                    commandLine: "",
                                    eventType: "memory_tamper",
                                    details: ["reason": message]
                                )
                                OCSFLogger.save(log: log)
                                ThreatLogger.shared.insert(log: log)
                            }
                        }
                        
                        let lpeWatcher = LPEWatcher()
                        lpeWatcher.startMonitoring(scriptName: "lpe_attempts") { pid, message in
                            DispatchQueue.main.async {
                                runningProcesses.removeAll { $0.pid == pid }

                                let suspiciousProcess = ProcessInfo(
                                    pid: pid,
                                    ppid: 0,
                                    name: "Unknown (Privilege Escalation Attempt)",
                                    arguments: "",
                                    threatDetected: true,
                                    threatDetails: nil,
                                    threatDescription: message
                                )
                                runningProcesses.append(suspiciousProcess)

                                let log = OCSFLog(
                                    id: UUID().uuidString,
                                    timestamp: Date().timeIntervalSince1970,
                                    pid: pid,
                                    ppid: 0,
                                    processName: suspiciousProcess.name,
                                    commandLine: "",
                                    eventType: "privilege_escalation",
                                    details: ["reason": message]
                                )
                                OCSFLogger.save(log: log)
                                ThreatLogger.shared.insert(log: log)
                            }
                        }
                        let sipWatcher = LPEWatcher() 
                        sipWatcher.startMonitoring(scriptName: "sip_bypass") { pid, message in
                            DispatchQueue.main.async {
                                runningProcesses.removeAll { $0.pid == pid }

                                let suspiciousProcess = ProcessInfo(
                                    pid: pid,
                                    ppid: 0,
                                    name: "Unknown (SIP Bypass Attempt)",
                                    arguments: "",
                                    threatDetected: true,
                                    threatDetails: nil,
                                    threatDescription: message
                                )
                                runningProcesses.append(suspiciousProcess)

                                let log = OCSFLog(
                                    id: UUID().uuidString,
                                    timestamp: Date().timeIntervalSince1970,
                                    pid: pid,
                                    ppid: 0,
                                    processName: suspiciousProcess.name,
                                    commandLine: "",
                                    eventType: "sip_bypass",
                                    details: ["reason": message]
                                )
                                OCSFLogger.save(log: log)
                                ThreatLogger.shared.insert(log: log)
                            }
                        }



                        withAnimation {
                            scanStarted = true
                        }
                    }) {
                        Text("🚨 Tehdit Aramasını Başlat")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: 250)
                            .background(Color.red.opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(NSColor.windowBackgroundColor))
                .transition(.opacity)
            } else {
                VStack(spacing: 0) {
                    HStack {
                        Toggle("Yalnızca Tehditleri Göster", isOn: $showOnlyThreats)
                            .toggleStyle(SwitchToggleStyle(tint: .red))
                            .padding(.leading)
                        
                        Spacer()
                        
                        Button(action: {
                            runningProcesses = ProcessMonitor.fetchProcessList()
                                .map { proc in
                                    var mutableProc = proc
                                    let analysis = ThreatDetector.analyze(process: proc)
                                    mutableProc.threatDetected = analysis.detected
                                    mutableProc.threatDescription = analysis.details
                                    return mutableProc
                                }
                                .sorted { $0.threatDetected && !$1.threatDetected }
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                        .padding(.horizontal, 5)
                        
                        Button(action: {
                            ExportManager.exportLogFile()
                        }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .padding(.horizontal, 5)
                        
                        Button(action: {
                            withAnimation {
                                showEventHistory.toggle()
                                showStatistics = false
                            }
                        }) {
                            Text(showEventHistory ? "✖️ Olay Geçmişini Kapat" : "📜 Olay Geçmişini Göster")
                                .font(.subheadline)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.trailing, 5)
                        
                        Button(action: {
                            withAnimation {
                                showStatistics.toggle()
                                showEventHistory = false
                            }
                        }) {
                            Text(showStatistics ? "✖️ İstatistikleri Kapat" : "📊 İstatistikler")
                                .font(.subheadline)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.trailing, 5)
                        
                        Button(action: {
                            showSQLiteLogView.toggle()
                        }) {
                            Text("🗄️ SQLite Loglarını Göster")
                                .font(.subheadline)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color.purple.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.trailing, 5)
                    }
                    .frame(height: 44)
                    .background(Color(NSColor.windowBackgroundColor))
                    .padding(.bottom, 4)
                    
                    HStack(spacing: 0) {
                        List(filteredProcesses) { process in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(process.name)
                                        .font(.headline)
                                        .foregroundColor(process.threatDetected ? .red : .primary)
                                    Text("PID: \(process.pid), PPID: \(process.ppid)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    if process.threatDetected {
                                        Text("⚠️ Tehdit Algılandı")
                                            .font(.caption2)
                                            .foregroundColor(.red)
                                        if let desc = process.threatDescription {
                                            Text(desc)
                                                .font(.caption2)
                                                .foregroundColor(.orange)
                                        }
                                    }
                                }
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedProcess = process
                            }
                        }
                        .frame(minWidth: (showEventHistory || showStatistics) ? 600 : 900, maxWidth: .infinity)
                        
                        if showEventHistory {
                            Divider()
                            ThreatLogHistoryView()
                                .frame(width: 320)
                        }
                        
                        if showStatistics {
                            Divider()
                            ThreatStatisticsView()
                                .frame(width: 350)
                        }
                    }
                    .navigationTitle("Çalışan Processler")
                }
                .sheet(item: $selectedProcess) { proc in
                    ProcessDetailView(process: proc)
                }
                .sheet(isPresented: $showSQLiteLogView) {
                    ThreatLogSQLiteView()
                }
            }
        }
    }
    
    var filteredProcesses: [ProcessInfo] {
        showOnlyThreats ? runningProcesses.filter { $0.threatDetected } : runningProcesses
    }
}
