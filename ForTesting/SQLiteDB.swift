/*
import Foundation
import SQLite3

class SQLiteDB {
    private var db: OpaquePointer?

    init?(path: String) {
        if sqlite3_open(path, &db) != SQLITE_OK {
            print("❌ Veritabanı açılamadı")
            return nil
        }
        print("✅ Veritabanı açıldı: \(path)")
    }

    deinit {
        sqlite3_close(db)
    }

    func execute(sql: String) -> Bool {
        var errMsg: UnsafeMutablePointer<Int8>? = nil
        if sqlite3_exec(db, sql, nil, nil, &errMsg) != SQLITE_OK {
            if let err = errMsg {
                print("❌ SQL Hatası: \(String(cString: err))")
                sqlite3_free(errMsg)
            }
            return false
        }
        return true
    }

    func prepareStatement(sql: String) -> OpaquePointer? {
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            return stmt
        } else {
            print("❌ Statement hazırlanamadı")
            return nil
        }
    }

    func finalizeStatement(stmt: OpaquePointer?) {
        if let s = stmt {
            sqlite3_finalize(s)
        }
    }
}
*/
