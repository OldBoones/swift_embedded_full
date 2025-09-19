// LoggingBridge.h - C bridge for esp-idf logging
#pragma once

#ifdef __cplusplus
extern "C" {
#endif

void mcu_log(int level, const char *message);          // level: 0=debug 1=info 2=warning 3=error
void mcu_log_set_level(int level);                     // sets global log level (same mapping)

#ifdef __cplusplus
}
#endif