# Advanced Threat Detection for macOS

##  Proje Hakkında

ThreatDetectionSim, macOS işletim sistemi üzerinde çalışan gelişmiş bir tehdit tespit uygulamasıdır. EndpointSecurity API ve diğer yerel sistem mekanizmalarını kullanarak kullanıcı alanındaki ve sistem belleğindeki olağan dışı davranışları gerçek zamanlı olarak izlemeyi ve tespit etmeyi hedefler.

Projede MITRE ATT&CK taktikleri kapsamında aşağıdaki saldırı teknikleri için tespit desteği yer almaktadır:

| # | Tehdit Başlığı               | Açıklama                                                                 | MITRE ID         |
|---|------------------------------|--------------------------------------------------------------------------|------------------|
| 1 | Process Injection            | `task_for_pid`, `dylib`, `mach_inject`, `dlopen` gibi davranışların izlenmesi | T1055.002        |
| 2 | Memory Tamper & Anti-Debug  | `ptrace(PT_DENY_ATTACH)`, `mprotect`, RWX memory kullanımının izlenmesi | T1620            |
| 3 | Fileless Malware            | `osascript`, `JXA`, bellek üstünden yürütülen saldırıların tespiti       | T1059.002        |
| 4 | Credential Dumping          | `security` CLI, `keychain` erişimlerinin ve kötüye kullanımının izlenmesi | T1555.004        |

---

## Bilgilendirme!

>  `bpftrace` destekli `Watcher` sınıfları ve `.btf` uzantılı çekirdek verisi içeren izleyiciler **şu an devre dışıdır**. Bu bileşenler sistem uyumsuzluğu ve erişim kısıtlamaları nedeniyle aktif olarak çalışmamaktadır.  
> Bu nedenle proje analizi yapılırken `EndpointSecurity` tabanlı `ESClient.swift` ve `ThreatLogger.swift` gibi bileşenler dikkate alınmalıdır.

---

## Özellikler

-  macOS EndpointSecurity tabanlı canlı process izleme
-  Gelişmiş kural tabanlı saldırı analizi
-  OCSF (Open Cybersecurity Schema Framework) uyumlu loglama
-  Lokal SQLite veritabanına gerçek zamanlı kayıt
-  Kullanıcı dostu UI tasarımı

---

## Gereksinimler

- macOS 11.0+ (Big Sur ve üzeri)
- Xcode 14+ ve Swift 5.7+
- Sistem Güvenliği:
  - System Integrity Protection (SIP) kapalı olmalı veya uygulama izinli olmalı
  - Geliştirici Sertifikası / uygun `Entitlements` dosyası
  - Uygulama System Extension ya da root yetkileri ile çalıştırılmalı

---

## Kullanılan Paketler ve Modüller

| Paket/Başlık            | Açıklama                                      |
|------------------------|-----------------------------------------------|
| `EndpointSecurity`     | macOS güvenlik olaylarının izlenmesini sağlar |
| `Foundation`           | Temel veri türleri ve zaman yönetimi          |
| `SQLite.swift`         | Olayların veritabanına kaydedilmesi           |
| `OCSFLogger` (custom)  | OCSF standardında log üretimi                 |
| `ThreatLogger` (custom)| Tehditleri veritabanına kaydeden katman       |

---

## Arayüz Tasarımı


<img width="941" height="734" alt="3" src="https://github.com/user-attachments/assets/1eff0ba2-092b-469f-a9f0-903a64fe9db8" />



