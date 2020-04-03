#
# Copyright (c) 2016-2019  Moddable Tech, Inc.
#
#   This file is part of the Moddable SDK Tools.
# 
#   The Moddable SDK Tools is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
# 
#   The Moddable SDK Tools is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with the Moddable SDK Tools.  If not, see <http://www.gnu.org/licenses/>.
#

GRROSE_BASE ?= $(HOME)/rose_sketch
HOST_OS := $(shell uname)

XS_GIT_VERSION ?= $(shell git -C $(MODDABLE) describe --tags --always --dirty 2>/dev/null)
ARDUINO_ROOT ?= $(GRROSE_BASE)/arduino
ARDUINO_GRROSE = $(ARDUINO_ROOT)/core
TOOLS_ROOT ?= $(GRROSE_BASE)/toolchain/$(HOST_OS)
PLATFORM_DIR = $(MODDABLE)/build/devices/gr_rose

ifeq ($(DEBUG),1)
	LIB_DIR = $(BUILD_DIR)/tmp/gr_rose/debug/lib
else
	ifeq ($(INSTRUMENT),1)
		LIB_DIR = $(BUILD_DIR)/tmp/gr_rose/instrument/lib
	else
		LIB_DIR = $(BUILD_DIR)/tmp/gr_rose/release/lib
	endif
endif

# serial port configuration
UPLOAD_SPEED ?= 921600
DEBUGGER_SPEED ?= 921600
ifeq ($(HOST_OS),Darwin)
UPLOAD_PORT ?= /dev/cu.SLAB_USBtoUART
else
UPLOAD_PORT ?= /dev/ttyUSB0
endif
UPLOAD_RESET ?= nodemcu
ifeq ($(VERBOSE),1)
UPLOAD_VERB = -v
endif

# Board settings for ESP-12E module (the most common); change for other modules
FLASH_SIZE ?= 4M
FLASH_MODE ?= qio
FLASH_SPEED ?= 80
FLASH_LAYOUT ?= eagle.flash.4m.ld

# WiFi & Debug settings
WIFI_SSID ?= 
WIFI_PSK ?= 
DEBUG_IP ?= 

# End user-configurable values. Derived values below.
NET_CONFIG_FLAGS := 
ifneq ($(WIFI_SSID),)
NET_CONFIG_FLAGS += -DWIFI_SSID=$(WIFI_SSID)
endif
ifneq ($(WIFI_PSK),)
NET_CONFIG_FLAGS += -DWIFI_PSK=$(WIFI_PSK)
endif
ifneq ($(DEBUG_IP),)
comma := ,
NET_CONFIG_FLAGS += -DDEBUG_IP=$(subst .,$(comma),$(DEBUG_IP))
endif

NEWLIBC_PATH = $(ESPRESSIF_SDK_ROOT)/components/newlib/newlib/lib/libc.a

CORE_DIR = $(ARDUINO_ROOT)/core
INC_DIRS = \
 	$(CORE_DIR) \
 	$(ARDUINO_ROOT)/variants/generic \
 	$(ARDUINO_ROOT)/cores/gr_rose/spiffs
SDK_SRC = \
	$(ARDUINO_GRROSE)/abi.cpp \
	$(ARDUINO_GRROSE)/cont.S \
	$(ARDUINO_GRROSE)/cont_util.c \
	$(ARDUINO_GRROSE)/core_gr_rose_main.cpp \
	$(ARDUINO_GRROSE)/core_gr_rose_noniso.c \
	$(ARDUINO_GRROSE)/core_gr_rose_phy.c \
	$(ARDUINO_GRROSE)/core_gr_rose_postmortem.c \
	$(ARDUINO_GRROSE)/core_gr_rose_si2c.c \
	$(ARDUINO_GRROSE)/core_gr_rose_timer.c \
	$(ARDUINO_GRROSE)/core_gr_rose_wiring.c \
	$(ARDUINO_GRROSE)/core_gr_rose_wiring_digital.c \
	$(ARDUINO_GRROSE)/core_gr_rose_wiring_pwm.c \
	$(ARDUINO_GRROSE)/Esp.cpp \
	$(ARDUINO_GRROSE)/heap.c \
	$(ARDUINO_GRROSE)/libc_replacements.c \
	$(ARDUINO_GRROSE)/spiffs/spiffs_cache.c \
	$(ARDUINO_GRROSE)/spiffs/spiffs_check.c \
	$(ARDUINO_GRROSE)/spiffs/spiffs_gc.c \
	$(ARDUINO_GRROSE)/spiffs/spiffs_hydrogen.c \
	$(ARDUINO_GRROSE)/spiffs/spiffs_nucleus.c \
	$(ARDUINO_GRROSE)/time.c \
	$(ARDUINO_GRROSE)/umm_malloc/umm_malloc.c \
	$(ARDUINO_GRROSE)/Schedule.cpp \
	$(PLATFORM_DIR)/lib/bsearch/bsearch.c \
	$(PLATFORM_DIR)/lib/fmod/e_fmod.c \
	$(PLATFORM_DIR)/lib/rtc/rtctime.c \
	$(PLATFORM_DIR)/lib/tinyprintf/tinyprintf.c \
	$(PLATFORM_DIR)/lib/tinyuart/tinyuart.c

SDK_SRC_SKIPPED = \
	$(ARDUINO_GRROSE)/base64.cpp \
	$(ARDUINO_GRROSE)/cbuf.cpp \
	$(ARDUINO_GRROSE)/core_gr_rose_eboot_command.c \
	$(ARDUINO_GRROSE)/core_gr_rose_i2s.c \
	$(ARDUINO_GRROSE)/core_gr_rose_flash_utils.c \
	$(ARDUINO_GRROSE)/core_gr_rose_wiring_analog.c \
	$(ARDUINO_GRROSE)/core_gr_rose_wiring_pulse.c \
	$(ARDUINO_GRROSE)/core_gr_rose_wiring_shift.c \
	$(ARDUINO_GRROSE)/debug.cpp \
	$(ARDUINO_GRROSE)/pgmspace.cpp \
	$(ARDUINO_GRROSE)/HardwareSerial.cpp \
	$(ARDUINO_GRROSE)/IPAddress.cpp \
	$(ARDUINO_GRROSE)/spiffs_api.cpp \
	$(ARDUINO_GRROSE)/Print.cpp \
	$(ARDUINO_GRROSE)/MD5Builder.cpp \
	$(ARDUINO_GRROSE)/Stream.cpp \
	$(ARDUINO_GRROSE)/Tone.cpp \
	$(ARDUINO_GRROSE)/uart.c \
	$(ARDUINO_GRROSE)/Updater.cpp \
	$(ARDUINO_GRROSE)/WMath.cpp \
	$(ARDUINO_GRROSE)/WString.cpp \
	$(ARDUINO_GRROSE)/FS.cpp \
	$(ARDUINO_GRROSE)/libb64/cdecode.c \
	$(ARDUINO_GRROSE)/libb64/cencode.c \
	$(ARDUINO_GRROSE)/StreamString.cpp

SDK_OBJ = $(subst .ino,.cpp,$(patsubst %,$(LIB_DIR)/%.o,$(notdir $(SDK_SRC))))
SDK_DIRS = $(sort $(dir $(SDK_SRC)))
    
XS_OBJ = \
	$(LIB_DIR)/xsHost.c.o \
	$(LIB_DIR)/xsPlatform.c.o \
	$(LIB_DIR)/xsAll.c.o \
	$(LIB_DIR)/xsAPI.c.o \
	$(LIB_DIR)/xsArguments.c.o \
	$(LIB_DIR)/xsArray.c.o \
	$(LIB_DIR)/xsAtomics.c.o \
	$(LIB_DIR)/xsBigInt.c.o \
	$(LIB_DIR)/xsBoolean.c.o \
	$(LIB_DIR)/xsCode.c.o \
	$(LIB_DIR)/xsCommon.c.o \
	$(LIB_DIR)/xsDataView.c.o \
	$(LIB_DIR)/xsDate.c.o \
	$(LIB_DIR)/xsDebug.c.o \
	$(LIB_DIR)/xsError.c.o \
	$(LIB_DIR)/xsFunction.c.o \
	$(LIB_DIR)/xsGenerator.c.o \
	$(LIB_DIR)/xsGlobal.c.o \
	$(LIB_DIR)/xsJSON.c.o \
	$(LIB_DIR)/xsLexical.c.o \
	$(LIB_DIR)/xsMapSet.c.o \
	$(LIB_DIR)/xsMarshall.c.o \
	$(LIB_DIR)/xsMath.c.o \
	$(LIB_DIR)/xsMemory.c.o \
	$(LIB_DIR)/xsModule.c.o \
	$(LIB_DIR)/xsNumber.c.o \
	$(LIB_DIR)/xsObject.c.o \
	$(LIB_DIR)/xsPlatforms.c.o \
	$(LIB_DIR)/xsProfile.c.o \
	$(LIB_DIR)/xsPromise.c.o \
	$(LIB_DIR)/xsProperty.c.o \
	$(LIB_DIR)/xsProxy.c.o \
	$(LIB_DIR)/xsRegExp.c.o \
	$(LIB_DIR)/xsRun.c.o \
	$(LIB_DIR)/xsScope.c.o \
	$(LIB_DIR)/xsScript.c.o \
	$(LIB_DIR)/xsSourceMap.c.o \
	$(LIB_DIR)/xsString.c.o \
	$(LIB_DIR)/xsSymbol.c.o \
	$(LIB_DIR)/xsSyntaxical.c.o \
	$(LIB_DIR)/xsTree.c.o \
	$(LIB_DIR)/xsType.c.o \
	$(LIB_DIR)/xsdtoa.c.o \
	$(LIB_DIR)/xsre.c.o \
	$(LIB_DIR)/xsmc.c.o \
	$(LIB_DIR)/main.cpp.o
XS_DIRS = \
	$(XS_DIR)/includes \
	$(XS_DIR)/sources \
	$(XS_DIR)/sources/pcre \
	$(XS_DIR)/platforms/gr_rose \
	$(BUILD_DIR)/devices/gr_rose
XS_HEADERS = \
	$(XS_DIR)/includes/xs.h \
	$(XS_DIR)/includes/xsmc.h \
	$(XS_DIR)/sources/xsScript.h \
	$(XS_DIR)/sources/xsAll.h \
	$(XS_DIR)/sources/xsCommon.h \
	$(XS_DIR)/platforms/gr_rose/xsHost.h \
	$(XS_DIR)/platforms/gr_rose/xsPlatform.h
HEADERS += $(XS_HEADERS)

TOOLS_BIN = $(TOOLS_ROOT)/rx-elf/bin
CC  = $(TOOLS_BIN)/rx-elf-gcc
CPP = $(TOOLS_BIN)/rx-elf-g++
LD  = $(CC)
AR  = $(TOOLS_BIN)/rx-elf-ar
OTA_TOOL = $(TOOLS_ROOT)/gr_roseota.py
ESPTOOL = $(ESPRESSIF_SDK_ROOT)/components/gr_rosetool_py/gr_rosetool/gr_rosetool.py

ifeq ($(HOST_OS),Darwin)
MODDABLE_TOOLS_DIR = $(BUILD_DIR)/bin/mac/release
else
MODDABLE_TOOLS_DIR = $(BUILD_DIR)/bin/lin/release
endif
BUILDCLUT = $(MODDABLE_TOOLS_DIR)/buildclut
COMPRESSBMF = $(MODDABLE_TOOLS_DIR)/compressbmf
RLE4ENCODE = $(MODDABLE_TOOLS_DIR)/rle4encode
MCLOCAL = $(MODDABLE_TOOLS_DIR)/mclocal
MCREZ = $(MODDABLE_TOOLS_DIR)/mcrez
PNG2BMP = $(MODDABLE_TOOLS_DIR)/png2bmp
IMAGE2CS = $(MODDABLE_TOOLS_DIR)/image2cs
WAV2MAUD = $(MODDABLE_TOOLS_DIR)/wav2maud
XSC = $(MODDABLE_TOOLS_DIR)/xsc
XSID = $(MODDABLE_TOOLS_DIR)/xsid
XSL = $(MODDABLE_TOOLS_DIR)/xsl

C_DEFINES = \
	-DCPPAPP \
	-DNDEBUG \
	-DTF_LITE_MCU_DEBUG_LOG \
	-DTF_LITE_STATIC_MEMORY \
	-DGEMMLOWP_ALLOW_SLOW_SCALAR_FALLBACK \
	-DARDUINOSTL_M_H \
	-DARDUINO=144 \
	-DGRROSE \
	-D__RX600__ \
	-D__RTOS \
	-DUSING_UXR \
	-DUSING_WIFI \
	$(NET_CONFIG_FLAGS) \
	-DmxUseDefaultSharedChunks=1 \
	-DmxRun=1 \
	-DmxNoConsole=1 \
	-DkCommodettoBitmapFormat=$(DISPLAY) \
	-DkPocoRotation=$(ROTATION)
ifeq ($(DEBUG),1)
	C_DEFINES += -DmxDebug=1 -DDEBUGGER_SPEED=$(DEBUGGER_SPEED)
endif
ifeq ($(INSTRUMENT),1)
	C_DEFINES += -DMODINSTRUMENTATION=1 -DmxInstrument=1
endif
ifeq ($(ESP_SDK_RELEASE),gr_rose-2.3.0)
	C_DEFINES += -DkRX65NVersion=23
else
	C_DEFINES += -DkRX65NVersion=24
endif
C_INCLUDES += $(DIRECTORIES)
C_INCLUDES += $(foreach dir,$(INC_DIRS) $(SDK_DIRS) $(XS_DIRS) $(LIB_DIR) $(TMP_DIR),-I$(dir))
C_FLAGS ?= -c -Os -g -Wpointer-arith -Wno-implicit-function-declaration -Wl,-EL -fno-inline-functions -nostdlib -falign-functions=4 -MMD -std=gnu99 -fdata-sections -ffunction-sections -fno-jump-tables
C_FLAGS_NODATASECTION = -c -Os -g -Wpointer-arith -Wno-implicit-function-declaration -Wl,-EL -fno-inline-functions -nostdlib -falign-functions=4 -MMD -std=gnu99
CPP_FLAGS ?= -c -Os -g -fno-exceptions -fno-rtti -falign-functions=4 -std=c++11 -MMD -ffunction-sections
S_FLAGS ?= -c -g -x assembler-with-cpp -MMD
ifeq ($(ESP_SDK_RELEASE),gr_rose-2.4.0)
LD_FLAGS ?= -g -w -Os -nostdlib -Wl,-Map=$(BIN_DIR)/main.txt -Wl,--cref -Wl,--no-check-sections -u call_user_start -Wl,-static -L$(ARDUINO_LIB) -L$(MODDABLE)/build/devices/gr_rose/sdk/ld -T$(FLASH_LAYOUT) -Wl,--gc-sections -Wl,-wrap,system_restart_local -Wl,-wrap,spi_flash_read
LD_STD_LIBS ?= -lm -lgcc -lhal -lphy -lnet80211 -llwip -lwpa -lmain -lpp -lc -lcrypto
else
LD_FLAGS ?= -g -w -Os -nostdlib -Wl,-Map=$(BIN_DIR)/main.txt -Wl,--cref -Wl,--no-check-sections -u call_user_start -Wl,-static -L$(ARDUINO_LIB) -L$(MODDABLE)/build/devices/gr_rose/sdk/ld -T$(FLASH_LAYOUT) -Wl,--gc-sections -Wl,-wrap,system_restart_local -Wl,-wrap,register_chipv6_phy  -Wl,-wrap,gr_roseconn_init
LD_STD_LIBS ?= -lm -lgcc -lhal -lphy -lnet80211 -llwip -lwpa -lmain -lpp -lsmartconfig -lwps -lcrypto -laxtls
endif
# stdc++ used in later versions of gr_rose Arduino
LD_STD_CPP = lstdc++
ifneq ($(shell grep $(LD_STD_CPP) $(ARDUINO_ROOT)/platform.txt),)
	LD_STD_LIBS += -$(LD_STD_CPP)
endif

# Utility functions
time_string = $(shell perl -e 'use POSIX qw(strftime); print strftime($(1), localtime());')
BUILD_DATE = $(call time_string,"%Y-%m-%d")
BUILD_TIME = $(call time_string,"%H:%M:%S")
MEM_USAGE = \
  'while (<>) { \
      $$r += $$1 if /^\.(?:data|rodata|bss)\s+(\d+)/;\
		  $$f += $$1 if /^\.(?:irom0\.text|text|data|rodata)\s+(\d+)/;\
	 }\
	 print "\# Memory usage\n";\
	 print sprintf("\#  %-6s %6d bytes\n" x 2 ."\n", "Ram:", $$r, "Flash:", $$f);'

VPATH += $(SDK_DIRS) $(XS_DIRS)

ifeq ($(DEBUG),1)
	ifeq ($(HOST_OS),Darwin)
		LAUNCH = debugmac
	else
		LAUNCH = debuglin
	endif
else
	LAUNCH = release
endif


ESP_FIRMWARE_DIR = $(ESPRESSIF_SDK_ROOT)/components/gr_rose/firmware
ESP_BOOTLOADER_BIN = $(ESP_FIRMWARE_DIR)/boot_v1.7.bin
ESP_DATA_DEFAULT_BIN = $(ESP_FIRMWARE_DIR)/gr_rose_init_data_default.bin

ifeq ($(FLASH_SIZE),1M)
	ESP_INIT_DATA_DEFAULT_BIN_OFFSET = 0xFC000
endif
ifeq ($(FLASH_SIZE),4M)
	ESP_INIT_DATA_DEFAULT_BIN_OFFSET = 0x3FC000
endif

ESPTOOL_FLASH_OPT = \
	--flash_freq $(FLASH_SPEED)m \
	--flash_mode $(FLASH_MODE) \
	--flash_size $(FLASH_SIZE)B \
	0x0000 $(ESP_BOOTLOADER_BIN) \
	0x1000 $(BIN_DIR)/main.bin \
	$(ESP_INIT_DATA_DEFAULT_BIN_OFFSET) $(ESP_DATA_DEFAULT_BIN)

UPLOAD_TO_ESP = $(ESPTOOL) -b $(UPLOAD_SPEED) -p $(UPLOAD_PORT) write_flash $(ESPTOOL_FLASH_OPT)

.PHONY: all

all: $(LAUNCH)

debuglin: $(LIB_DIR) $(BIN_DIR)/main.bin
	$(shell pkill serial2xsbug)
	$(shell nohup $(BUILD_DIR)/bin/lin/release/xsbug > /dev/null 2>&1 &)
	$(UPLOAD_TO_ESP)
#	@echo "# using DEBUGGER_SPEED $(DEBUGGER_SPEED)"
	$(BUILD_DIR)/bin/lin/debug/serial2xsbug $(UPLOAD_PORT) $(DEBUGGER_SPEED) 8N1

debugmac: $(LIB_DIR) $(BIN_DIR)/main.bin
	$(shell pkill serial2xsbug)
	open -a $(BUILD_DIR)/bin/mac/release/xsbug.app -g
	$(UPLOAD_TO_ESP)
#	@echo "# using DEBUGGER_SPEED $(DEBUGGER_SPEED)"
	$(BUILD_DIR)/bin/mac/release/serial2xsbug $(UPLOAD_PORT) $(DEBUGGER_SPEED) 8N1 -elf $(TMP_DIR)/main.elf -bin $(TOOLS_BIN)

release: $(LIB_DIR) $(BIN_DIR)/main.bin
	$(UPLOAD_TO_ESP)

$(LIB_DIR):
	mkdir -p $(LIB_DIR)
	echo "typedef struct { const char *date, *time, *src_version, *env_version;} _tBuildInfo; extern _tBuildInfo _BuildInfo;" > $(LIB_DIR)/buildinfo.h

$(BIN_DIR)/main.bin: $(SDK_OBJ) $(LIB_DIR)/lib_a-setjmp.o $(XS_OBJ) $(TMP_DIR)/mc.xs.c.o $(TMP_DIR)/mc.resources.c.o $(OBJECTS) 
	@echo "# ld main.bin"
	echo '#include "buildinfo.h"' > $(LIB_DIR)/buildinfo.cpp
	echo '_tBuildInfo _BuildInfo = {"$(BUILD_DATE)","$(BUILD_TIME)","$(XS_GIT_VERSION)","$(ESP_GIT_VERSION)"};' >> $(LIB_DIR)/buildinfo.cpp
	$(CPP) $(C_DEFINES) $(C_INCLUDES) $(CPP_FLAGS) $(LIB_DIR)/buildinfo.cpp -o $(LIB_DIR)/buildinfo.cpp.o
	$(LD) $(LD_FLAGS) -Wl,--start-group $^ $(LIB_DIR)/buildinfo.cpp $(LD_STD_LIBS) -Wl,--end-group -L$(LIB_DIR) -o $(TMP_DIR)/main.elf
	$(TOOLS_BIN)/rx-elf-objdump -t $(TMP_DIR)/main.elf > $(BIN_DIR)/main.sym
	$(ESPTOOL) --chip gr_rose elf2image --version=2 -o $@ $(TMP_DIR)/main.elf
	@echo "# Versions"
	@echo "#  ESP:   $(ESP_SDK_RELEASE)"
	@echo "#  XS:    $(XS_GIT_VERSION)"
	@$(TOOLS_BIN)/rx-elf-size -A $(TMP_DIR)/main.elf | perl -e $(MEM_USAGE)

$(LIB_DIR)/lib_a-setjmp.o: $(NEWLIBC_PATH)
	@echo "# ar" $(<F)
	(cd $(LIB_DIR) && $(AR) -xv $< lib_a-setjmp.o)

$(XS_OBJ): $(XS_HEADERS)
$(LIB_DIR)/xs%.c.o: xs%.c
	@echo "# cc" $(<F) "(strings in flash + force-l32)"
	$(CC) $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) $< -o $@.unmapped
	$(TOOLS_BIN)/rx-elf-objcopy --rename-section .rodata.str1.1=.irom0.str.1 $@.unmapped $@

$(LIB_DIR)/%.S.o: %.S
	@echo "# cc" $(<F)
	$(CC) $(C_DEFINES) $(C_INCLUDES) $(S_FLAGS) $< -o $@

$(LIB_DIR)/%.c.o: %.c
	@echo "# cc" $(<F)
	$(CC) $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) $< -o $@

$(LIB_DIR)/%.cpp.o: %.cpp
	@echo "# cpp" $(<F)
	$(CPP) $(C_DEFINES) $(C_INCLUDES) $(CPP_FLAGS) $< -o $@

$(TMP_DIR)/mc.%.c.o: $(TMP_DIR)/mc.%.c
	@echo "# cc" $(<F) "(slots in flash)"
	$(CC) $< $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS_NODATASECTION) -o $@.unmapped
	$(TOOLS_BIN)/rx-elf-objcopy --rename-section .data=.irom0.str.1 --rename-section .rodata=.irom0.str.1 --rename-section .rodata.str1.1=.irom0.str.1 $@.unmapped $@

$(TMP_DIR)/mc.xs.c: $(MODULES) $(MANIFEST)
	@echo "# xsl modules"
	$(XSL) -b $(MODULES_DIR) -o $(TMP_DIR) $(PRELOADS) $(STRIPS) $(CREATION) $(MODULES)

$(TMP_DIR)/mc.resources.c: $(DATA) $(RESOURCES) $(MANIFEST)
	@echo "# mcrez resources"
	$(MCREZ) $(DATA) $(RESOURCES) -o $(TMP_DIR) -p gr_rose -r mc.resources.c

MAKEFLAGS += --jobs
ifneq ($(VERBOSE),1)
MAKEFLAGS += --silent
endif

