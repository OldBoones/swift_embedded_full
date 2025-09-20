//#include "esp_wifi.h"
#include "wifi_wrapper.h"
#include "esp_log.h"
#include "lwip/ip4_addr.h"

// C-Wrapper für WIFI_INIT_CONFIG_DEFAULT Macro
wifi_init_config_t get_default_wifi_init_config(void)
{
    wifi_init_config_t config = WIFI_INIT_CONFIG_DEFAULT();
    return config;
}

void esp_idf_log(esp_log_level_t level, const char *tag, const char *msg)
{
    // Use ESP-IDF logging macros
    switch (level)
    {
    case ESP_LOG_DEBUG:
        ESP_LOGD(tag, "%s", msg);
        break;
    case ESP_LOG_INFO:
        ESP_LOGI(tag, "%s", msg);
        break;
    case ESP_LOG_WARN:
        ESP_LOGW(tag, "%s", msg);
        break;
    case ESP_LOG_ERROR:
        ESP_LOGE(tag, "%s", msg);
        break;
    case ESP_LOG_NONE:
    default:
        // No logging
        break;
    }
}

const char *esp_idf_ip4addr_ntoa(const void *ip4addr)
{
    return ip4addr_ntoa((const ip4_addr_t *)ip4addr);
}