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
UPLOAD_SPEED ?= 115200
DEBUGGER_SPEED ?= 115200
ifeq ($(HOST_OS),Darwin)
UPLOAD_PORT ?= /dev/cu.SLAB_USBtoUART
else
UPLOAD_PORT ?= /dev/ttyUSB0
endif
UPLOAD_RESET ?= nodemcu
ifeq ($(VERBOSE),1)
UPLOAD_VERB = -v
endif

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
	$(ARDUINO_ROOT) \
	$(ARDUINO_ROOT)/core \
	$(ARDUINO_ROOT)/lib/SPI \
	$(FREERTOS_ROOT)/config_files \
	$(FREERTOS_ROOT)/lib/aws/include \
	$(FREERTOS_ROOT)/lib/aws/include/private \
	$(FREERTOS_ROOT)/lib/aws/FreeRTOS/portable/GCC/RX600v2 \
	$(FREERTOS_ROOT)/lib/aws/FreeRTOS-Plus-TCP/include \
	$(FREERTOS_ROOT)/lib/aws/FreeRTOS-Plus-TCP/source/portable/Compiler/GCC \
	$(FREERTOS_ROOT)/src/amazon_freertos_common \
	$(FREERTOS_ROOT)/src/FIT_modified_code/r_bsp/mcu/rx65n/register_access/gnuc \
	$(FREERTOS_ROOT)/src/FIT_setting_files/r_config

SDK_SRC = \
	$(PLATFORM_DIR)/lib/fmod/e_fmod.c \
	$(PLATFORM_DIR)/lib/rtc/rtctime.c \
	$(PLATFORM_DIR)/lib/tinyprintf/tinyprintf.c \
	$(PLATFORM_DIR)/lib/tinyuart/tinyuart.c

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

SDK_OBJ = \
	$(PLATFORM_DIR)/lib/fmod/e_fmod.c

CPP_INCLUDES = \
	$(TOOLS_DIR)/rx-elf/include/c++/4.8.5

CC  = rx-elf-gcc
CPP = rx-elf-g++
LD  = $(CPP)
AR  = rx-elf-ar

AR_OPTIONS = rcs

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

LD_DIRS = \
	-L$(MODDABLE)/build/devices/gr_rose/sdk/ld/win \
	-L$(BASE_DIR)/Debug \
	-L$(BASE_DIR)

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
C_INCLUDES += $(DIRECTORIES)
C_INCLUDES += $(foreach dir,$(INC_DIRS) $(SDK_DIRS) $(XS_DIRS) $(LIB_DIR) $(TMP_DIR),-I$(dir))
C_FLAGS = \
	-c \
	-g2 \
	-Os \
	-ffunction-sections \
	-fdata-sections \
	-fno-builtin \
	-fno-delete-null-pointer-checks \
	-fno-exceptions \
	-fno-unwind-tables \
	-fomit-frame-pointer \
	-funsigned-char \
	-Wall \
	-Wextra \
	-Wshadow \
	-Wmissing-field-initializers \
	-Wno-unused-parameter \
	-Wno-write-strings \
	-Wsign-compare \
	-Wunused-variable \
	-Wvla \
	-Wstack-usage=100 \
	-m64bit-doubles \
	-mcpu=rx64m \
	-misa=v2 \
	-mlittle-endian-data \
	-MMD \
	-std=gnu99
C_FLAGS_NODATASECTION = \
	-c \
	-g2 \
	-Os \
	-ffunction-sections \
	-fdata-sections \
	-fno-builtin \
	-fno-delete-null-pointer-checks \
	-fno-exceptions \
	-fno-unwind-tables \
	-fomit-frame-pointer \
	-funsigned-char \
	-Wall \
	-Wextra \
	-Wshadow \
	-Wmissing-field-initializers \
	-Wno-unused-parameter \
	-Wno-write-strings \
	-Wsign-compare \
	-Wunused-variable \
	-Wvla \
	-Wstack-usage=100 \
	-m64bit-doubles \
	-mcpu=rx64m \
	-misa=v2 \
	-mlittle-endian-data \
	-MMD \
	-std=gnu99
CPP_FLAGS = \
	-c \
	-g2 \
	-Os \
	-ffunction-sections \
	-fdata-sections \
	-fno-builtin \
	-fno-delete-null-pointer-checks \
	-fno-exceptions \
	-fno-rtti \
	-fno-unwind-tables \
	-fomit-frame-pointer \
	-fpermissive \
	-funsigned-char \
	-Wall \
	-Wextra \
	-Wshadow \
	-Wmissing-field-initializers \
	-Wno-unused-parameter \
	-Wno-write-strings \
	-Wsign-compare \
	-Wunused-variable \
	-Wvla \
	-Wstack-usage=100 \
	-m64bit-doubles \
	-mcpu=rx64m \
	-misa=v2 \
	-mlittle-endian-data \
	-MMD \
	-std=gnu++11
S_FLAGS = \
	-c \
	-g \
	-x \
	assembler-with-cpp \
	-mcpu=rx64M \
	-mlittle-endian-data \
	-m64bit-doubles \
	-misa=v2 \
	-MMD
LD_FLAGS = \
	-g2 \
	-O3 \
	-ffunction-sections \
	-fdata-sections \
	-fno-builtin \
	-fno-delete-null-pointer-checks \
	-fno-exceptions \
	-fno-rtti \
	-fno-unwind-tables \
	-fomit-frame-pointer \
	-fpermissive \
	-funsigned-char \
	-Wall \
	-Wextra \
	-Wshadow \
	-Wmissing-field-initializers \
	-Wno-unused-parameter \
	-Wno-write-strings \
	-Wsign-compare \
	-Wunused-variable \
	-Wvla \
	-Wstack-usage=100 \
	-m64bit-doubles \
	-mcpu=rx64m \
	-misa=v2 \
	-mlittle-endian-data \
	$(LD_DIRS) \
	-Tlinker_script_bin.ld \
	-nostartfiles \
	-Wl,-e_PowerON_Reset \
	-Wl,-Map=$(BIN_DIR)/main.map,--cref
#	-Wl,--gc-sections undefind rvectors
LD_STD_LIBS = \
	-lm \
	-lc \
	-lgcc \
	-lsim \
	-lnosys \
	-lrose_sketch
LD_STD_CPP = \
	-lstdc++

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

clean:
	echo "# Clean project"
	-rm -rf $(BIN_DIR) 2>/dev/null
	-rm -rf $(TMP_DIR) 2>/dev/null

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

