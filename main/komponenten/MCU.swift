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
}