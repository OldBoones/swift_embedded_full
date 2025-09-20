
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
#include "driver/rmt_rx.h"
#include "driver/rmt_tx.h"
#include "driver/rmt_types.h"
#include "sdkconfig.h"

#include "esp_mac.h"

#include "led_strip.h"
#include "led_strip_rmt.h"
#include "led_strip_types.h"
#include "komponenten/LedStrip/LedStripBridge.h"

#include "esp_log.h"
#include "esp_system.h"

#include "komponenten/mcu.logging/LoggingBridge.h"