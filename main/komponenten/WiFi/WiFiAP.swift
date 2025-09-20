// MARK: - WiFiAP: Embedded-safe, ESP-IDF idiomatic implementation

class WiFiAP {
    let ssid: String
    let password: String
    private(set) var isStarted: Bool = false
    private var netif: OpaquePointer?
    private var eventHandler: UnsafeMutableRawPointer? = nil

    // Neue Properties
    var currentChannel: UInt8 {
        didSet {
            updateAPConfig()
        }
    }
    var maxClients: UInt8 {
        didSet {
            updateAPConfig()
        }
    }

    // Standard-Init
    init(ssid: String, password: String) {
        self.ssid = ssid
        self.password = password
        self.currentChannel = 1
        self.maxClients = 4
    }

    // Erweiterter Init
    convenience init(ssid: String, password: String, channel: UInt8 = 1, maxClients: UInt8 = 4) {
        self.init(ssid: ssid, password: password)
        self.currentChannel = channel
        self.maxClients = maxClients
    }

    // AP-Konfiguration dynamisch aktualisieren
    private func updateAPConfig() {
        var config = wifi_config_t()
        memset(&config, 0, MemoryLayout<wifi_config_t>.size)
        let ssidBytes = Array(ssid.utf8.prefix(32))
        let pwdBytes = Array(password.utf8.prefix(64))
        withUnsafeMutableBytes(of: &config.ap.ssid) { buffer in
            for (i, b) in ssidBytes.enumerated() { buffer[i] = b }
        }
        withUnsafeMutableBytes(of: &config.ap.password) { buffer in
            for (i, b) in pwdBytes.enumerated() { buffer[i] = b }
        }
        config.ap.ssid_len = UInt8(ssidBytes.count)
        config.ap.max_connection = maxClients
        config.ap.channel = currentChannel
        config.ap.authmode = WIFI_AUTH_WPA_WPA2_PSK
        let setResult = esp_wifi_set_config(WIFI_IF_AP, &config)
        if setResult == ESP_OK {
            log(
                "WiFiAP: AP-Konfiguration aktualisiert (channel: \(currentChannel), maxClients: \(maxClients))",
                .info)
        } else {
            log("WiFiAP: Fehler beim Aktualisieren der AP-Konfiguration: \(setResult)", .error)
        }
    }

    func start() -> Bool {
        // NVS Flash initialisieren
        var nvs_result = nvs_flash_init()
        if nvs_result == ESP_ERR_NVS_NO_FREE_PAGES || nvs_result == ESP_ERR_NVS_NEW_VERSION_FOUND {
            log("NVS Flash löschen und neu initialisieren", .debug)
            nvs_flash_erase()
            nvs_result = nvs_flash_init()
        }
        guard nvs_result == ESP_OK else {
            log("NVS Initialisierung fehlgeschlagen: \(nvs_result)", .error)
            return false
        }
        _ = esp_netif_init()
        log("esp_netif_init erfolgreich", .info)
        wait(100)
        _ = esp_event_loop_create_default()
        log("event loop erfolgreich erstellt", .info)
        wait(100)
        // Default AP network interface
        netif = esp_netif_create_default_wifi_ap()
        guard netif != nil else {
            log("WiFiAP: esp_netif_create_default_wifi_ap fehlgeschlagen", .error)
            return false
        }
        log("esp_netif_create_default_wifi_ap erfolgreich", .info)
        var wifiInitCfg = get_default_wifi_init_config()
        log("wifi_init_cfg erfolgreich erstellt", .info)
        _ = esp_wifi_init(&wifiInitCfg)
        log("wifi_init erfolgreich", .info)
        wait(100)
        _ = esp_wifi_set_mode(WIFI_MODE_AP)
        log("WIFI_MODE_AP gesetzt", .info)
        wait(1500)
        _ = esp_wifi_start()
        log("esp_wifi_start erfolgreich", .info)
        wait(100)
        // WiFi AP Konfiguration
        var config = wifi_config_t()
        memset(&config, 0, MemoryLayout<wifi_config_t>.size)
        let ssidBytes = Array(ssid.utf8.prefix(32))
        let pwdBytes = Array(password.utf8.prefix(64))
        withUnsafeMutableBytes(of: &config.ap.ssid) { buffer in
            for (i, b) in ssidBytes.enumerated() { buffer[i] = b }
        }
        withUnsafeMutableBytes(of: &config.ap.password) { buffer in
            for (i, b) in pwdBytes.enumerated() { buffer[i] = b }
        }
        config.ap.ssid_len = UInt8(ssidBytes.count)
        config.ap.max_connection = maxClients
        config.ap.channel = currentChannel
        config.ap.authmode = WIFI_AUTH_WPA_WPA2_PSK
        let setResult = esp_wifi_set_config(WIFI_IF_AP, &config)
        if setResult != ESP_OK {
            log("WiFiAP: esp_wifi_set_config fehlgeschlagen: \(setResult)", .error)
            return false
        }
        // DHCP-Server wird automatisch gestartet
        // Event-Handler für neue Verbindungen
        let WIFI_EVENT_AP_STACONNECTED: Int32 = 18  // ESP-IDF Wert
        var handlerInstance: UnsafeMutableRawPointer? = nil
        let handlerResult = esp_event_handler_instance_register(
            WIFI_EVENT,
            WIFI_EVENT_AP_STACONNECTED,
            { (handler_arg, event_base, event_id, event_data) in
                let client = Unmanaged<WiFiAP>.fromOpaque(handler_arg!).takeUnretainedValue()
                client.isStarted = true
                log("WiFiAP: Ein Client hat sich verbunden.", .info)
            },
            Unmanaged.passUnretained(self).toOpaque(),
            &handlerInstance
        )
        if handlerResult != ESP_OK {
            log("WiFiAP: Event-Handler Registrierung fehlgeschlagen: \(handlerResult)", .error)
            return false
        }
        self.eventHandler = handlerInstance
        log("WiFiAP: Access Point '\(ssid)' gestartet.", .info)
        return true
    }

    deinit {
        let WIFI_EVENT_AP_STACONNECTED: Int32 = 18
        if let handler = eventHandler {
            esp_event_handler_instance_unregister(
                WIFI_EVENT,
                WIFI_EVENT_AP_STACONNECTED,
                handler
            )
        }
        if let netif = netif {
            esp_netif_destroy(netif)
        }
    }
}