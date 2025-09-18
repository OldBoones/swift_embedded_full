// MARK: - Enums (lokal, bis Modulbindung gesichert)
public enum GPIODirection {
    case input
    case output
    case inputOutput
}

public enum GPIOPull {
    case none
    case up
    case down
}

public enum GPIOInterrupt {
    case none
    case risingEdge
    case fallingEdge
    case anyEdge
    case lowLevel
    case highLevel
}
// GPIO.swift
// Hauptschnittstelle für GPIO-Steuerung in Swift


@_exported import struct Foundation.Data
@_exported import class Foundation.NSObject
// Importiere die lokalen Enums


// Importiere die C-Symbole aus dem Bridging Header
// (Der Import erfolgt implizit über BridgingHeader.h, ggf. Modulname anpassen)


import Foundation

public class GPIO {
    public let pin: UInt32
    public private(set) var direction: GPIODirection
    public private(set) var pull: GPIOPull
    public private(set) var interrupt: GPIOInterrupt

    // MARK: - Initializer
    public init(pin: UInt32, direction: GPIODirection, pull: GPIOPull = .none, interrupt: GPIOInterrupt = .none) {
        self.pin = pin
        self.direction = direction
        self.pull = pull
        self.interrupt = interrupt
        configure()
    }

    public convenience init(pin: UInt32, direction: GPIODirection) {
        self.init(pin: pin, direction: direction, pull: .none, interrupt: .none)
    }

    // MARK: - Konfiguration
    public func setDirection(_ direction: GPIODirection) {
        self.direction = direction
        configure()
    }

    public func setPull(_ pull: GPIOPull) {
        self.pull = pull
        configure()
    }

    public func setInterrupt(_ interrupt: GPIOInterrupt) {
        self.interrupt = interrupt
        configure()
    }

    // MARK: - Lesen/Schreiben
    public func write(_ value: Bool) {
    // gpio_set_level(pin, value ? 1 : 0) // C-Bindung prüfen
    }

    public func read() -> Bool {
    // return gpio_get_level(pin) != 0 // C-Bindung prüfen
    return false
    }

    // MARK: - Private Hilfsfunktionen
    private func configure() {
    // var config = gpio_config_t()
    // config.pin_bit_mask = 1 << pin
    // config.mode = toGPIOMode(direction)
    // config.pull_up_en = (pull == .up) ? 1 : 0
    // config.pull_down_en = (pull == .down) ? 1 : 0
    // config.intr_type = toGPIOIntrType(interrupt)
    // gpio_config(&config)
    }

    // private func toGPIOMode(_ direction: GPIODirection) -> gpio_mode_t {
    //     switch direction {
    //     case .input: return GPIO_MODE_INPUT
    //     case .output: return GPIO_MODE_OUTPUT
    //     case .inputOutput: return GPIO_MODE_INPUT_OUTPUT
    //     }
    // }

    // private func toGPIOIntrType(_ interrupt: GPIOInterrupt) -> gpio_int_type_t {
    //     switch interrupt {
    //     case .none: return GPIO_INTR_DISABLE
    //     case .risingEdge: return GPIO_INTR_POSEDGE
    //     case .fallingEdge: return GPIO_INTR_NEGEDGE
    //     case .anyEdge: return GPIO_INTR_ANYEDGE
    //     case .lowLevel: return GPIO_INTR_LOW_LEVEL
    //     case .highLevel: return GPIO_INTR_HIGH_LEVEL
    //     }
    // }
}
