
//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

#include <stdio.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/gpio.h"
#include "sdkconfig.h"

#include "esp_mac.h"

#include "led_strip.h"
#include "led_strip_rmt.h"
#include "led_strip_types.h"

// logging, storage and configuration
#include "esp_log.h"
#include "esp_log_level.h"
#include "nvs_flash.h"
#include "nvs.h"

#include "driver/rmt_rx.h"
#include "driver/rmt_tx.h"
#include "driver/rmt_types.h"

// Networking - WICHTIG: Reihenfolge beachten!
#include "esp_netif_types.h" // <- Zuerst die Typen
#include "esp_netif.h"       // <- Dann die Funktionen
#include "esp_wifi_types.h"  // <- WiFi Typen
#include "esp_wifi.h"        // <- WiFi Funktionen
#include "esp_event.h"
#include "esp_http_server.h"

#include "komponenten/LedStrip/LedStripBridge.h"
#include "komponenten/WiFi//wifi_wrapper.h"

#include "esp_log.h"
#include "esp_system.h"

#include "komponenten/mcu.logging/LoggingBridge.h"