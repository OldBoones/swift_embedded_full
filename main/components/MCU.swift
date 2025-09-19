// MCU.swift
// Statische Hilfsfunktionen für Embedded MCU

public struct MCU {
    private init() {}

    public enum LogLevel: Int {
        case debug = 0
        case info = 1
        case warning = 2
        case error = 3
    }

    public static func log(_ message: String, level: LogLevel = .info) {
        message.withCString { cStr in
            mcu_log(Int32(level.rawValue), cStr)
        }
    }
}

// Swift Logging Wrapper
extension MCU {
    public struct Logging {
        private init() {}
        public static func setGlobal(level: MCU.LogLevel) {
            mcu_log_set_level(Int32(level.rawValue))
        }
        public static func log(_ message: String, level: MCU.LogLevel = .info) {
            MCU.log(message, level: level)
        }
    }
}

@_silgen_name("mcu_log") private func mcu_log(_ level: Int32, _ msg: UnsafePointer<CChar>)
@_silgen_name("mcu_log_set_level") private func mcu_log_set_level(_ level: Int32)