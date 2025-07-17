/*import Foundation

class EncryptedThreatLogger {
    static let shared = EncryptedThreatLogger()

    private let db: SQLiteDB

    private init?() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = documents.appendingPathComponent("threat_logs.sqlite").path

        guard let database = SQLiteDB(path: dbPath) else {
            print("❌ Veritabanı açılamadı")
            return nil
        }

        self.db = database

        let createTableSQL = """
        CREATE TABLE IF NOT EXISTS threat_logs (
            id TEXT PRIMARY KEY,
            timestamp REAL,
            pid INTEGER,
            ppid INTEGER,
            processName TEXT,
            eventType TEXT,
            details TEXT
        );
        """

        if !db.execute(sql: createTableSQL) {
            print("❌ Tablo oluşturulamadı")
        }
    }

    func insert(log: OCSFLog) {
        let insertSQL = """
        INSERT INTO threat_logs (id, timestamp, pid, ppid, processName, eventType, details)
        VALUES (?, ?, ?, ?, ?, ?, ?);
        """

        guard let stmt = db.prepareStatement(sql: insertSQL) else {
            return
        }

        defer {
            db.finalizeStatement(stmt: stmt)
        }

        // Bind parametreler
        sqlite3_bind_text(stmt, 1, (log.id as NSString).utf8String, -1, nil)
        sqlite3_bind_double(stmt, 2, log.timestamp)
        sqlite3_bind_int(stmt, 3, Int32(log.pid))
        sqlite3_bind_int(stmt, 4, Int32(log.ppid))
        sqlite3_bind_text(stmt, 5, (log.processName as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 6, (log.eventType as NSString).utf8String, -1, nil)

        // Details JSON String
        let jsonData = try? JSONSerialization.data(withJSONObject: log.details, options: [])
        let jsonString = jsonData.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        sqlite3_bind_text(stmt, 7, (jsonString as NSString).utf8String, -1, nil)

        if sqlite3_step(stmt) != SQLITE_DONE {
            print("❌ Log eklenemedi")
        } else {
            print("✅ Log eklendi: \(log.id)")
        }
    }
}
*/
