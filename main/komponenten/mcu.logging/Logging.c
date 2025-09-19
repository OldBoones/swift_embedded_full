// Logging.c - Implementation of esp-idf logging bridge
// Keep includes minimal to reduce IntelliSense macro parsing issues
#include <stdint.h>
#include <stddef.h>
#include "LoggingBridge.h"
#include "esp_log.h"

static const char *TAG = "APP";

void mcu_log(int level, const char *message) {
    if (!message) return;
    esp_log_level_t espLevel;
    switch(level) {
        case 0: espLevel = ESP_LOG_DEBUG; break;
        case 1: espLevel = ESP_LOG_INFO; break;
        case 2: espLevel = ESP_LOG_WARN; break;
        case 3: espLevel = ESP_LOG_ERROR; break;
        default: espLevel = ESP_LOG_INFO; break;
    }
    // Direkt esp_log_write verwenden (um IntelliSense-Makro-Parsingsprobleme mit variadischen Makros zu vermeiden)
    esp_log_write(espLevel, TAG, "%s", message);
}

void mcu_log_set_level(int level) {
    // Map our 0..3 onto esp-idf levels (verbose/debug/info/warn/error)
    // We choose the minimum level to display up to that severity.
    // For simplicity: set base level so that desired messages are not filtered out.
    // If level==0 (debug) -> ESP_LOG_DEBUG, 1->INFO, 2->WARN, 3->ERROR
    esp_log_level_t esp_level = ESP_LOG_INFO;
    switch(level) {
        case 0: esp_level = ESP_LOG_DEBUG; break;
        case 1: esp_level = ESP_LOG_INFO; break;
        case 2: esp_level = ESP_LOG_WARN; break;
        case 3: esp_level = ESP_LOG_ERROR; break;
        default: esp_level = ESP_LOG_INFO; break;
    }
    esp_log_level_set("*", esp_level);
}