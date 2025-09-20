// MARK: - WiFiClient: Embedded-safe, ESP-IDF idiomatic implementation
class WiFiClient {
    let ssid: String
    let password: String
    private(set) var isConnected: Bool = false
    private(set) var ip: String?
    private(set) var subnet: String?
    private(set) var gateway: String?
    private(set) var dns: String?
    private var netif: OpaquePointer?
    // ESP-IDF event handler instance (pointer)
    private var eventHandler: UnsafeMutableRawPointer? = nil

    init(ssid: String, password: String) {
        self.ssid = ssid
        self.password = password
    }

    func connect() -> Bool {
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
        // --- ESP-IDF WiFi stack initialization (robust, only once per boot) ---
        _ = esp_netif_init()
        log("esp_netif_init erfolgreich", .info)
        wait(100)
        _ = esp_event_loop_create_default()
        log("event loop erfolgreich erstellt", .info)
        wait(100)
        // --- Create default STA network interface (nur EINMAL, Handle speichern!) ---
        netif = esp_netif_create_default_wifi_sta()
        guard netif != nil else {
            log("WiFiClient: esp_netif_create_default_wifi_sta fehlgeschlagen", .error)
            return false
        }
        log("esp_netif_create_default_wifi_sta erfolgreich", .info)
        var wifiInitCfg = get_default_wifi_init_config()
        log("wifi_init_cfg erfolgreich erstellt", .info)
        _ = esp_wifi_init(&wifiInitCfg)
        log("wifi_init erfolgreich", .info)
        wait(100)
        _ = esp_wifi_set_mode(WIFI_MODE_STA)
        log("WIFI_MODE_STA gesetzt", .info)
        wait(1500)
        _ = esp_wifi_start()
        log("esp_wifi_start erfolgreich", .info)
        wait(100)
        // --- WiFi configuration (embedded-safe string copy) ---
        var config = wifi_config_t()
        memset(&config, 0, MemoryLayout<wifi_config_t>.size)
        let ssidBytes = Array(ssid.utf8.prefix(32))
        let pwdBytes = Array(password.utf8.prefix(64))
        withUnsafeMutableBytes(of: &config.sta.ssid) { buffer in
            for (i, b) in ssidBytes.enumerated() { buffer[i] = b }
        }
        withUnsafeMutableBytes(of: &config.sta.password) { buffer in
            for (i, b) in pwdBytes.enumerated() { buffer[i] = b }
        }
        let setResult = esp_wifi_set_config(WIFI_IF_STA, &config)
        if setResult != ESP_OK {
            log("WiFiClient: esp_wifi_set_config fehlgeschlagen: \(setResult)", .error)
            return false
        }

        // MARK: DHCP CLIENT
        // --- Start DHCP client ---
        // stoppe den DHCP-Client, um sicherzustellen, dass er neu gestartet wird
        // log(
        //     "stoppe und starte den DHCP-Client, um sicherzustellen, dass er neu gestartet wird",
        //     level: .info)
        // guard let netif = netif else {
        //     log("WiFiClient: netif ist nil, kann DHCP nicht starten/stoppen", level: .error)
        //     return false
        // }
        // esp_netif_dhcpc_stop(netif)
        // _ = esp_netif_dhcpc_start(netif)
        // log("dhcp client erfolgreich gestartet", level: .info)

        // --- Register event handler for IP assignment ---
        // IP_EVENT_STA_GOT_IP is not imported; in ESP-IDF it is 0
        let IP_EVENT_STA_GOT_IP_ID: Int32 = 0
        var handlerInstance: UnsafeMutableRawPointer? = nil
        let handlerResult = esp_event_handler_instance_register(
            IP_EVENT,
            IP_EVENT_STA_GOT_IP_ID,
            { (handler_arg, event_base, event_id, event_data) in
                guard let eventData = event_data?.assumingMemoryBound(to: ip_event_got_ip_t.self)
                else { return }
                var ip = eventData.pointee.ip_info.ip
                var netmask = eventData.pointee.ip_info.netmask
                var gw = eventData.pointee.ip_info.gw
                let ipStr = String(cString: esp_idf_ip4addr_ntoa(&ip))
                let maskStr = String(cString: esp_idf_ip4addr_ntoa(&netmask))
                let gwStr = String(cString: esp_idf_ip4addr_ntoa(&gw))
                let client = Unmanaged<WiFiClient>.fromOpaque(handler_arg!).takeUnretainedValue()
                client.isConnected = true
                client.ip = ipStr
                client.subnet = maskStr
                client.gateway = gwStr
                // DNS (optional)
                var dnsInfo = esp_netif_dns_info_t()
                if esp_netif_get_dns_info(client.netif, ESP_NETIF_DNS_MAIN, &dnsInfo) == ESP_OK {
                    var dnsip = dnsInfo.ip.u_addr.ip4
                    client.dns = String(cString: esp_idf_ip4addr_ntoa(&dnsip))
                }
                log("WiFiClient: IP erhalten: \(ipStr)", .info)
            },
            Unmanaged.passUnretained(self).toOpaque(),
            &handlerInstance
        )
        if handlerResult != ESP_OK {
            log(
                "***/t***/n***WiFiClient: Event-Handler Registrierung fehlgeschlagen: \(handlerResult)",
                .error)
            return false
        }
        self.eventHandler = handlerInstance

        // --- Connect to AP ---
        let connectResult = esp_wifi_connect()
        if connectResult != ESP_OK {
            log("WiFiClient: esp_wifi_connect fehlgeschlagen: \(connectResult)", .error)
            return false
        }
        log("WiFiClient: Verbindung zu '\(ssid)' wird aufgebaut...", .info)
        return true
    }

    deinit {
        // --- Unregister event handler ---
        // IP_EVENT_STA_GOT_IP is 0 in ESP-IDF
        let IP_EVENT_STA_GOT_IP_ID: Int32 = 0
        if let handler = eventHandler {
            esp_event_handler_instance_unregister(
                IP_EVENT,
                IP_EVENT_STA_GOT_IP_ID,
                handler
            )
        }
        if let netif = netif {
            esp_netif_destroy(netif)
        }
    }
}