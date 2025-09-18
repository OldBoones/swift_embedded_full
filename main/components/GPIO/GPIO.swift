@_silgen_name("getStdout")
func getStdout() -> UnsafeMutablePointer<FILE>?


// MARK: - Enums (Swift <-> ESP-IDF Mapping)
public enum GPIODirection {
    case input
    case output
    case inputOutput
    case outputOpenDrain
    case inputOutputOpenDrain

    var cValue: gpio_mode_t {
        switch self {
        case .input: return GPIO_MODE_INPUT
        case .output: return GPIO_MODE_OUTPUT
        case .inputOutput: return GPIO_MODE_INPUT_OUTPUT
        case .outputOpenDrain: return GPIO_MODE_OUTPUT_OD
        case .inputOutputOpenDrain: return GPIO_MODE_INPUT_OUTPUT_OD
        }
    }
}

public enum GPIOPull {
    case none
    case up
    case down
    case upDown

    var cValue: gpio_pull_mode_t {
        switch self {
        case .none: return GPIO_FLOATING
        case .up: return GPIO_PULLUP_ONLY
        case .down: return GPIO_PULLDOWN_ONLY
        case .upDown: return GPIO_PULLUP_PULLDOWN
        }
    }
}

public enum GPIOInterrupt {
    case none
    case risingEdge
    case fallingEdge
    case anyEdge
    case lowLevel
    case highLevel

    var cValue: gpio_int_type_t {
        switch self {
        case .none: return GPIO_INTR_DISABLE
        case .risingEdge: return GPIO_INTR_POSEDGE
        case .fallingEdge: return GPIO_INTR_NEGEDGE
        case .anyEdge: return GPIO_INTR_ANYEDGE
        case .lowLevel: return GPIO_INTR_LOW_LEVEL
        case .highLevel: return GPIO_INTR_HIGH_LEVEL
        }
    }
}
// GPIO.swift
// Hauptschnittstelle für GPIO-Steuerung in Swift


// Keine Foundation-Importe nötig für Embedded Swift

public class GPIO {
    public let pin: Int32
    public private(set) var direction: GPIODirection
    public private(set) var pull: GPIOPull
    public private(set) var interrupt: GPIOInterrupt

    // MARK: - Initializer
    public init(pin: Int32, direction: GPIODirection, pull: GPIOPull = .none, interrupt: GPIOInterrupt = .none) {
        self.pin = pin
        self.direction = direction
        self.pull = pull
        self.interrupt = interrupt
        configure()
    }

    // MARK: - Konfiguration
    public func setDirection(_ direction: GPIODirection) {
        self.direction = direction
    _ = gpio_set_direction(gpio_num_t(pin), direction.cValue)
    }

    public func setPull(_ pull: GPIOPull) {
        self.pull = pull
    _ = gpio_set_pull_mode(gpio_num_t(pin), pull.cValue)
    }

    public func setInterrupt(_ interrupt: GPIOInterrupt) {
        self.interrupt = interrupt
    _ = gpio_set_intr_type(gpio_num_t(pin), interrupt.cValue)
    }

    // MARK: - Lesen/Schreiben
    public func write(_ value: Bool) {
    _ = gpio_set_level(gpio_num_t(pin), value ? 1 : 0)
    }

    public func read() -> Bool {
    return gpio_get_level(gpio_num_t(pin)) != 0
    }

    // MARK: - Erweiterte Funktionen
    public func reset() {
    _ = gpio_reset_pin(gpio_num_t(pin))
    }

    // input_enable, output_enable etc. sind nicht Teil der aktuellen ESP-IDF API und werden entfernt

    public func enablePullup() {
    _ = gpio_pullup_en(gpio_num_t(pin))
    }

    public func disablePullup() {
    _ = gpio_pullup_dis(gpio_num_t(pin))
    }

    public func enablePulldown() {
    _ = gpio_pulldown_en(gpio_num_t(pin))
    }

    public func disablePulldown() {
    _ = gpio_pulldown_dis(gpio_num_t(pin))
    }

    public func enableOpenDrain() {
    _ = gpio_set_direction(gpio_num_t(pin), GPIO_MODE_OUTPUT_OD)
    }

    public func setDriveStrength(_ strength: gpio_drive_cap_t) {
    _ = gpio_set_drive_capability(gpio_num_t(pin), strength)
    }

    public func getDriveStrength() -> gpio_drive_cap_t? {
        var cap = GPIO_DRIVE_CAP_DEFAULT
    let res = gpio_get_drive_capability(gpio_num_t(pin), &cap)
        return res == ESP_OK ? cap : nil
    }

    public func holdEnable() {
    _ = gpio_hold_en(gpio_num_t(pin))
    }

    public func holdDisable() {
    _ = gpio_hold_dis(gpio_num_t(pin))
    }

    public func enableWakeup(_ type: GPIOInterrupt) {
    _ = gpio_wakeup_enable(gpio_num_t(pin), type.cValue)
    }

    public func disableWakeup() {
    _ = gpio_wakeup_disable(gpio_num_t(pin))
    }

    // MARK: - Interrupt Service
    public static func installISRService(flags: Int32 = 0) {
        _ = gpio_install_isr_service(flags)
    }

    public static func uninstallISRService() {
        gpio_uninstall_isr_service()
    }

    public func addISRHandler(_ handler: @escaping @convention(c) (UnsafeMutableRawPointer?) -> Void, args: UnsafeMutableRawPointer? = nil) {
    _ = gpio_isr_handler_add(gpio_num_t(pin), handler, args)
    }

    public func removeISRHandler() {
    _ = gpio_isr_handler_remove(gpio_num_t(pin))
    }

    // MARK: - Dump IO Config
    public static func dumpConfiguration(mask: UInt64) {
        // stdout ist in Swift nicht direkt verfügbar, aber über Bridging Header importiert
        gpio_dump_io_configuration(getStdout(), mask)
    }

    // MARK: - Private Hilfsfunktionen
    private func configure() {
        var config = gpio_config_t(
            pin_bit_mask: UInt64(1) << UInt64(pin),
            mode: direction.cValue,
            pull_up_en: (pull == .up || pull == .upDown) ? GPIO_PULLUP_ENABLE : GPIO_PULLUP_DISABLE,
            pull_down_en: (pull == .down || pull == .upDown) ? GPIO_PULLDOWN_ENABLE : GPIO_PULLDOWN_DISABLE,
            intr_type: interrupt.cValue
        )
        _ = withUnsafePointer(to: &config) { gpio_config($0) }
    }
}
