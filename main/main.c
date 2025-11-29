/**
 * ESP32 Starter Project
 * 
 * A clean, production-ready ESP32-S3 firmware starter.
 * This example demonstrates basic functionality and best practices.
 */

#include <stdio.h>
#include <stdint.h>
#include <stddef.h>
#include <string.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_log.h"
#include "esp_chip_info.h"
#include "esp_flash.h"

static const char *TAG = "MAIN";

/**
 * @brief Print chip information
 */
void print_chip_info(void)
{
    esp_chip_info_t chip_info;
    uint32_t flash_size;
    
    esp_chip_info(&chip_info);
    
    ESP_LOGI(TAG, "ESP32 Chip Information:");
    ESP_LOGI(TAG, "  Model: %s", CONFIG_IDF_TARGET);
    ESP_LOGI(TAG, "  Cores: %d", chip_info.cores);
    ESP_LOGI(TAG, "  Silicon Revision: %d", chip_info.revision);
    
    if(esp_flash_get_size(NULL, &flash_size) == ESP_OK) {
        ESP_LOGI(TAG, "  Flash Size: %lu MB", flash_size / (1024 * 1024));
    }
    
    ESP_LOGI(TAG, "  Features:");
    ESP_LOGI(TAG, "    WiFi: %s", (chip_info.features & CHIP_FEATURE_WIFI_BGN) ? "Yes" : "No");
    ESP_LOGI(TAG, "    Bluetooth: %s", (chip_info.features & CHIP_FEATURE_BT) ? "Yes" : "No");
    ESP_LOGI(TAG, "    BLE: %s", (chip_info.features & CHIP_FEATURE_BLE) ? "Yes" : "No");
    
    ESP_LOGI(TAG, "  Free Heap: %lu bytes", esp_get_free_heap_size());
}

/**
 * @brief Main application task
 */
void app_main(void)
{
    ESP_LOGI(TAG, "========================================");
    ESP_LOGI(TAG, "ESP32 Starter Project");
    ESP_LOGI(TAG, "========================================");
    ESP_LOGI(TAG, "ESP-IDF Version: %s", esp_get_idf_version());
    ESP_LOGI(TAG, "");
    
    // Print chip information
    print_chip_info();
    
    ESP_LOGI(TAG, "");
    ESP_LOGI(TAG, "System initialized successfully!");
    ESP_LOGI(TAG, "Entering main loop...");
    
    // Main application loop
    uint32_t counter = 0;
    while (1) {
        counter++;
        ESP_LOGI(TAG, "Main loop iteration: %lu | Free heap: %lu bytes", 
                 counter, esp_get_free_heap_size());
        
        // Wait for 5 seconds
        vTaskDelay(pdMS_TO_TICKS(5000));
    }
}

