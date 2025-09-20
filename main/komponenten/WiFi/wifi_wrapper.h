#ifndef WIFI_WRAPPER_H
#define WIFI_WRAPPER_H

#include "esp_wifi.h"
#include "esp_log.h"

// C-Wrapper Funktion für Swift
wifi_init_config_t get_default_wifi_init_config(void);

// Logging bridge for Swift
void esp_idf_log(esp_log_level_t level, const char *tag, const char *msg);

// Convert ip4_addr_t* to string for Swift
const char *esp_idf_ip4addr_ntoa(const void *ip4addr);

#endif