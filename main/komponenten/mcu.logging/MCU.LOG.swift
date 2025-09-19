// MCU.LOG.swift
// ESP-IDF native logging, idiomatisches Swift-Interface
// Keine Foundation nötig auf Embedded/ESP32


@_silgen_name("mcu_log")
func mcu_log(_ level: Int32, _ message: UnsafePointer<CChar>)

@_silgen_name("mcu_log_set_level")
func mcu_log_set_level(_ level: Int32)


@inline(__always)
func log(_ message: String, _ level: MCU.LOG.Level = .info) {
    MCU.LOG.log(message, level: level)
}


// Globale Funktion zum Setzen des LogLevels
@inline(__always)
func setLogLevel(_ level: MCU.LOG.Level) {
  MCU.LOG.setLevel(level)
}

// set log level globally (convenience wrapper)
// @inline(__always)
// func setLogLevel(_ level: MCU.LOG.Level) {
//     MCU.LOG.setLevel(level)
// }


extension MCU {
  struct LOG {
    // ESP-IDF Loglevel Mapping
    enum Level: Int, Comparable, CaseIterable {
      case debug = 0
      case info = 1
      case warn = 2
      case error = 3
      case none = 4

      static func < (lhs: Level, rhs: Level) -> Bool {
        lhs.rawValue < rhs.rawValue
      }

      var description: String {
        switch self {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warn: return "WARN"
        case .error: return "ERROR"
        case .none: return "NONE"
        }
      }

      var espLevel: esp_log_level_t {
        switch self {
        case .debug: return ESP_LOG_DEBUG
        case .info: return ESP_LOG_INFO
        case .warn: return ESP_LOG_WARN
        case .error: return ESP_LOG_ERROR
        case .none: return ESP_LOG_NONE
        }
      }
    }

    // Default log tag (not used in C bridge)
    static let defaultTag = "[CUSTOM]"
    private static var minLevel: Level = .debug

    // Set minimum log level (global)
    static func setLevel(_ level: Level) {
        minLevel = level
        mcu_log_set_level(Int32(level.rawValue))
    }

    // Main log function (Swift types, ESP-IDF backend)
    static func log(_ message: String, level: Level = .debug) {
        guard level >= minLevel else { return }
        message.withCString { msg in
            mcu_log(Int32(level.rawValue), msg)
        }
    }
  }
}