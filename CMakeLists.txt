# ESP-IDF Project Configuration
# For more information about build system see
# https://docs.espressif.com/projects/esp-idf/en/latest/api-guides/build-system.html

cmake_minimum_required(VERSION 3.16)

# Set the project name
set(PROJECT_NAME "esp32-starter")

# Include the ESP-IDF CMake build system
include($ENV{IDF_PATH}/tools/cmake/project.cmake)

# Define the project
project(${PROJECT_NAME})

