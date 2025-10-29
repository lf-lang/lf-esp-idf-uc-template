cmake_minimum_required(VERSION 3.20.0)
include(${CMAKE_CURRENT_SOURCE_DIR}/esp-idf/tools/cmake/idf.cmake)
project(reactor-uc-esp-idf)
set(PLATFORM "ESP_IDF" CACHE STRING "Platform to target")

# Define the components to be included in the IDF build
set(IDF_COMPONENTS "freertos" "esptool_py" "driver" "led_strip")
# Set the path for the extra led_strip component
# Additional components can be added here
set(EXTRA_COMPONENT_DIRS idf-extra-components/led_strip)
idf_build_component(idf-extra-components/led_strip)

if (NOT DEFINED LF_MAIN)
  set(LF_MAIN "HelloEsp")
endif()

if (NOT DEFINED LOG_LEVEL)
  set(LOG_LEVEL "LF_LOG_LEVEL_WARN")
endif()

# Create idf::{target} and idf::freertos static libraries
idf_build_process(${ESP_IDF_BOARD} 
                COMPONENTS ${IDF_COMPONENTS} 
                SDKCONFIG ${CMAKE_CURRENT_LIST_DIR}/sdkconfig
                BUILD_DIR ${CMAKE_BINARY_DIR})

set(LF_MAIN_TARGET ${LF_MAIN})
set(elf_file ${LF_MAIN_TARGET}.elf)
add_executable(${LF_MAIN_TARGET})

include($ENV{REACTOR_UC_PATH}/cmake/lfc.cmake)

lf_setup()
lf_run_lfc(${CMAKE_CURRENT_SOURCE_DIR}/src ${LF_MAIN})
lf_build_generated_code(${LF_MAIN_TARGET} ${CMAKE_CURRENT_SOURCE_DIR}/src-gen/${LF_MAIN})

# Add compiler flags to avoid errors from ESP-IDF headers
target_compile_options(${LF_MAIN_TARGET} PRIVATE -Wno-unused-parameter)
target_compile_options(reactor-uc PRIVATE -Wno-unused-parameter)

# Link additional IDF components (all components defined in IDF_COMPONENTS except freertos and esptool_py)
target_link_libraries(${LF_MAIN_TARGET} PRIVATE reactor-uc idf::led_strip idf::driver)
idf_build_executable(${LF_MAIN_TARGET})