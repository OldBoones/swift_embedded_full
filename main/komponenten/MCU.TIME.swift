// Time.swift
// Erweiterung für Zeitfunktionen

@_silgen_name("esp_timer_get_time")
func esp_timer_get_time() -> Int64

/// Globale wait-Funktion, die MCU.Time.wait aufruft
@inline(__always)
public func wait(ms: UInt64, debug: Bool = false) {
    MCU.Time.wait(ms: ms, debug: debug)
}

extension MCU {
    /// Zeitfunktionen für die MCU
    public struct Time {
        private init() {}

        /// Gibt die aktuelle Uptime in ms zurück (nutzt esp_timer_get_time)
        public static func uptimeMs() -> UInt64 {
            // esp_timer_get_time liefert Mikrosekunden seit Boot
            return UInt64(esp_timer_get_time()) / 1000
        }

        /// Wartet mindestens ms Millisekunden (busy-wait)
        public static func wait(ms: UInt64, debug: Bool = false) {
            let start = uptimeMs()
            while (uptimeMs() - start) < ms {
                // busy-wait, 1ms granularity
                if debug {
                    if (uptimeMs() - start) % 100 == 0 {
                        break
                    }
                    log("Waiting for \(ms) ms... \(uptimeMs()-start) ms elapsed")
                }
                vTaskDelay(1)
            }
        }
    }
}