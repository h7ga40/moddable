#
# Copyright (c) 2016-2018  Moddable Tech, Inc.
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

HOST_OS = win

!IF "$(BASE_DIR)"==""
BASE_DIR = $(USERPROFILE)
!ENDIF
!IF "$(DEBUGGER_SPEED)"==""
DEBUGGER_SPEED = 115200
!ENDIF

ARDUINO_ROOT = $(BASE_DIR)\arduino
FREERTOS_ROOT = $(BASE_DIR)\FreeRTOS

PLATFORM_DIR = $(MODDABLE)\build\devices\gr_rose

!IF "$(VERBOSE)"=="1"
!CMDSWITCHES -S
!ELSE
!CMDSWITCHES +S
!ENDIF

!IF "$(DEBUG)"=="1"
LIB_DIR = $(BUILD_DIR)\tmp\gr_rose\debug\lib
!ELSEIF "$(INSTRUMENT)"=="1"
LIB_DIR = $(BUILD_DIR)\tmp\gr_rose\instrument\lib
!ELSE
LIB_DIR = $(BUILD_DIR)\tmp\gr_rose\release\lib
!ENDIF

# WiFi & Debug settings
WIFI_SSID =
WIFI_PSK =

# End user-configurable values. Derived values below.
!IF "$(WIFI_SSID)"!=""
NET_CONFIG_FLAGS += -DWIFI_SSID=$(WIFI_SSID)
!ENDIF
!IF "$(WIFI_PSK)"!=""
NET_CONFIG_FLAGS += -DWIFI_PSK=$(WIFI_PSK)
!ENDIF

CORE_DIR = $(ARDUINO_ROOT)\core

INC_DIRS = \
	-I$(ARDUINO_ROOT) \
	-I$(ARDUINO_ROOT)\core \
	-I$(ARDUINO_ROOT)\lib\SPI \
	-I$(FREERTOS_ROOT)\config_files \
	-I$(FREERTOS_ROOT)\lib\aws\include \
	-I$(FREERTOS_ROOT)\lib\aws\include\private \
	-I$(FREERTOS_ROOT)\lib\aws\FreeRTOS\portable\GCC\RX600v2 \
	-I$(FREERTOS_ROOT)\lib\aws\FreeRTOS-Plus-TCP\include \
	-I$(FREERTOS_ROOT)\lib\aws\FreeRTOS-Plus-TCP\source\portable\Compiler\GCC \
	-I$(FREERTOS_ROOT)\src\amazon_freertos_common \
	-I$(FREERTOS_ROOT)\src\FIT_modified_code\r_bsp\mcu\rx65n\register_access\gnuc \
	-I$(FREERTOS_ROOT)\src\FIT_setting_files\r_config \
	-I$(PLATFORM_DIR)\lib\rtc \
	-I$(PLATFORM_DIR)\lib\tinyprintf \

SDK = \
    -I$(PLATFORM_DIR)\lib\tinyprintf \
    -I$(PLATFORM_DIR)\lib\rtc

XS_OBJ = \
	$(LIB_DIR)\xsHost.o \
	$(LIB_DIR)\xsPlatform.o \
	$(LIB_DIR)\xsAll.o \
	$(LIB_DIR)\xsAPI.o \
	$(LIB_DIR)\xsArguments.o \
	$(LIB_DIR)\xsArray.o \
	$(LIB_DIR)\xsAtomics.o \
	$(LIB_DIR)\xsBigInt.o \
	$(LIB_DIR)\xsBoolean.o \
	$(LIB_DIR)\xsCode.o \
	$(LIB_DIR)\xsCommon.o \
	$(LIB_DIR)\xsDataView.o \
	$(LIB_DIR)\xsDate.o \
	$(LIB_DIR)\xsDebug.o \
	$(LIB_DIR)\xsError.o \
	$(LIB_DIR)\xsFunction.o \
	$(LIB_DIR)\xsGenerator.o \
	$(LIB_DIR)\xsGlobal.o \
	$(LIB_DIR)\xsJSON.o \
	$(LIB_DIR)\xsLexical.o \
	$(LIB_DIR)\xsMapSet.o \
	$(LIB_DIR)\xsMarshall.o \
	$(LIB_DIR)\xsMath.o \
	$(LIB_DIR)\xsMemory.o \
	$(LIB_DIR)\xsModule.o \
	$(LIB_DIR)\xsNumber.o \
	$(LIB_DIR)\xsObject.o \
	$(LIB_DIR)\xsPlatforms.o \
	$(LIB_DIR)\xsProfile.o \
	$(LIB_DIR)\xsPromise.o \
	$(LIB_DIR)\xsProperty.o \
	$(LIB_DIR)\xsProxy.o \
	$(LIB_DIR)\xsRegExp.o \
	$(LIB_DIR)\xsRun.o \
	$(LIB_DIR)\xsScope.o \
	$(LIB_DIR)\xsScript.o \
	$(LIB_DIR)\xsSourceMap.o \
	$(LIB_DIR)\xsString.o \
	$(LIB_DIR)\xsSymbol.o \
	$(LIB_DIR)\xsSyntaxical.o \
	$(LIB_DIR)\xsTree.o \
	$(LIB_DIR)\xsType.o \
	$(LIB_DIR)\xsdtoa.o \
	$(LIB_DIR)\xsmc.o \
	$(LIB_DIR)\xsre.o
XS_DIRS = \
	-I$(XS_DIR)\includes \
	-I$(XS_DIR)\sources \
	-I$(XS_DIR)\sources\pcre \
	-I$(XS_DIR)\platforms\gr_rose \
	-I$(BUILD_DIR)\devices\gr_rose
XS_HEADERS = \
	$(XS_DIR)\includes\xs.h \
	$(XS_DIR)\includes\xsmc.h \
	$(XS_DIR)\sources\xsScript.h \
	$(XS_DIR)\sources\xsAll.h \
	$(XS_DIR)\sources\xsCommon.h \
	$(XS_DIR)\platforms\gr_rose\xsHost.h \
	$(XS_DIR)\platforms\gr_rose\xsPlatform.h
SDK_SRC = \
	$(PLATFORM_DIR)\lib\fmod\e_fmod.c \
	$(PLATFORM_DIR)\lib\rtc\rtctime.c \
	$(PLATFORM_DIR)\lib\tinyprintf\tinyprintf.c \
	$(PLATFORM_DIR)\lib\tinyuart\tinyuart.c

SDK_OBJ = \
	$(PLATFORM_DIR)\lib\fmod\e_fmod.c

CPP_INCLUDES = \
	-I$(TOOLS_DIR)\rx-elf\include\c++\4.8.5

HEADERS = $(HEADERS) $(XS_HEADERS)

CC  = rx-elf-gcc
CPP = rx-elf-g++
LD  = $(CPP)
AR  = rx-elf-ar

AR_OPTIONS = rcs

MODDABLE_TOOLS_DIR = $(BUILD_DIR)\bin\win\release
BUILDCLUT = $(MODDABLE_TOOLS_DIR)\buildclut
COMPRESSBMF = $(MODDABLE_TOOLS_DIR)\compressbmf
RLE4ENCODE = $(MODDABLE_TOOLS_DIR)\rle4encode
MCLOCAL = $(MODDABLE_TOOLS_DIR)\mclocal
MCREZ = $(MODDABLE_TOOLS_DIR)\mcrez
PNG2BMP = $(MODDABLE_TOOLS_DIR)\png2bmp
IMAGE2CS = $(MODDABLE_TOOLS_DIR)\image2cs
WAV2MAUD = $(MODDABLE_TOOLS_DIR)\wav2maud
XSC = $(MODDABLE_TOOLS_DIR)\xsc
XSID = $(MODDABLE_TOOLS_DIR)\xsid
XSL = $(MODDABLE_TOOLS_DIR)\xsl

LD_DIRS = \
	-L$(MODDABLE)\build\devices\gr_rose\sdk\ld\win \
	-L$(BASE_DIR)\Debug \
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
!IF "$(DEBUG)"=="1"
C_DEFINES = $(C_DEFINES) -DmxDebug=1 -DDEBUGGER_SPEED=$(DEBUGGER_SPEED)
!ENDIF
!IF "$(INSTRUMENT)"=="1"
C_DEFINES = $(C_DEFINES) -DMODINSTRUMENTATION=1 -DmxInstrument=1
!ENDIF
C_DEFINES = $(C_DEFINES) -DkRX65NVersion=24
C_INCLUDES = $(DIRECTORIES) $(INC_DIRS) $(XS_DIRS) -I$(LIB_DIR) -I$(TMP_DIR)
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
	-Wl,-Map=$(BIN_DIR)\main.map,--cref
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

# VPATH += $(SDK_DIRS) $(XS_DIRS)
#
!IF "$(DEBUG)"=="1"
LAUNCH = debug
!ELSE
LAUNCH = release
!ENDIF

.PHONY: all	

APP_ARCHIVE = $(BIN_DIR)\libxsar.a
LIB_ARCHIVE = $(LIB_DIR)\libxslib.a

all: $(LAUNCH)

clean:
	echo # Clean project lib, bin and tmp
	echo $(BIN_DIR)
	del /s/q/f $(BIN_DIR)\*.* > NUL
	rmdir /s/q $(BIN_DIR)
	echo $(TMP_DIR)
	del /s/q/f $(TMP_DIR)\*.* > NUL
	rmdir /s/q $(TMP_DIR)
	echo $(LIB_DIR)
	if exist $(LIB_DIR) del /s/q/f $(LIB_DIR)\*.* > NUL
	if exist $(LIB_DIR) rmdir /s/q $(LIB_DIR)
	echo $(IDF_BUILD_DIR)
	if exist $(IDF_BUILD_DIR) del /s/q/f $(IDF_BUILD_DIR)\*.* > NUL
	if exist $(IDF_BUILD_DIR) rmdir /s/q $(IDF_BUILD_DIR)
	echo $(PROJ_DIR)
	if exist del /s/q/f $(PROJ_DIR)\*.* > NUL
	if exist rmdir /s/q $(PROJ_DIR)

precursor: projDir $(BLE) $(SDKCONFIG_H) $(LIB_DIR) $(BIN_DIR)\xs_esp32.a


debug: $(LIB_DIR) $(LIB_ARCHIVE) $(APP_ARCHIVE) $(BIN_DIR)\main.bin
	@echo # invoke debugger
#	robocopy $(BIN_DIR) E:\ main.bin
#	-tasklist /nh /fi "imagename eq serial2xsbug.exe" | (find /i "serial2xsbug.exe" > nul) && taskkill /f /t /im "serial2xsbug.exe" >nul 2>&1
#	tasklist /nh /fi "imagename eq xsbug.exe" | find /i "xsbug.exe" > nul || (start $(BUILD_DIR)\bin\win\release\xsbug.exe)

release: $(LIB_DIR) $(LIB_ARCHIVE) $(APP_ARCHIVE) $(BIN_DIR)\main.bin
	@echo # build release binnary done.
#	robocopy $(BIN_DIR) E:\ main.bin

$(LIB_DIR):
	if not exist $(LIB_DIR)\$(NULL) mkdir $(LIB_DIR)
	echo typedef struct { const char *date, *time, *src_version, *env_version;} _tBuildInfo; extern _tBuildInfo _BuildInfo; > $(LIB_DIR)\buildinfo.h

delAr:
	@del $(APP_ARCHIVE)
	@del $(LIB_ARCHIVE)

$(APP_ARCHIVE): $(TMP_DIR)\mc.xs.o $(TMP_DIR)\mc.resources.o $(OBJECTS) $(LIB_DIR)\xsHost.o $(LIB_DIR)\xsPlatform.o $(TMP_DIR)\main.o
	@echo # archive $(APP_ARCHIVE)
	$(AR) $(AR_OPTIONS) $@ $(TMP_DIR)\mc.xs.o $(LIB_DIR)\xsHost.o $(LIB_DIR)\xsPlatform.o $(TMP_DIR)\mc.resources.o $(TMP_DIR)\main.o

$(LIB_ARCHIVE): $(XS_OBJ) $(SDK_OBJ)
	@echo # archive $(LIB_ARCHIVE)
#	$(AR) $(AR_OPTIONS) $@ $(TMP_DIR)\mc.xs.o $(LIB_DIR)\xsHost.o $(LIB_DIR)\xsPlatform.o $(TMP_DIR)\mc.resources.o $(LIB_DIR)\main.o

$(BIN_DIR)\main.bin: $(APP_ARCHIVE) $(LIB_ARCHIVE)
	@echo # ld main.bin
	echo #include "buildinfo.h" > $(LIB_DIR)\buildinfo.c
	echo _tBuildInfo _BuildInfo = {"$(BUILD_DATE)","$(BUILD_TIME)","$(SRC_GIT_VERSION)","$(ESP_GIT_VERSION)"}; >> $(LIB_DIR)\buildinfo.c
	$(CPP) $(C_DEFINES) $(C_INCLUDES) $(CPP_FLAGS) $(LIB_DIR)\buildinfo.c -o $(LIB_DIR)\buildinfo.o
	$(LD) -L$(BIN_DIR) $(LD_FLAGS) -Wl,--start-group $(LIB_DIR)\buildinfo.o $(LD_STD_CPP) $(LD_STD_LIBS) -lxslib -lxsar -Wl,--end-group -L$(LIB_DIR) -o $(TMP_DIR)\main.elf
	rx-elf-objdump -t $(TMP_DIR)\main.elf > $(BIN_DIR)\main.sym
	rx-elf-objcopy -O binary $(TMP_DIR)\main.elf $(BIN_DIR)\main.bin

{$(XS_DIR)\sources\}.c{$(LIB_DIR)\}.o:
	@echo # cc $(@F) $(FULLPLATFORM)
	$(CC) $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) $? -o $@
	$(AR) $(AR_OPTIONS) $(LIB_ARCHIVE) $@

$(LIB_DIR)\e_fmod.o: $(PLATFORM_DIR)\lib\fmod\e_fmod.c
	@echo # cc $(@F)
	$(CC) $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) $? -o $@
	$(AR) $(AR_OPTIONS) $(LIB_ARCHIVE) $@

$(LIB_DIR)\rtctime.o: $(PLATFORM_DIR)\lib\rtc\rtctime.c
	@echo # cc $(@F)
	$(CC) $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) $? -o $@
	$(AR) $(AR_OPTIONS) $(LIB_ARCHIVE) $@

$(LIB_DIR)\tinyprintf.o: $(PLATFORM_DIR)\lib\tinyprintf\tinyprintf.c
	@echo # cc $(@F)
	$(CC) $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) $? -o $@
	$(AR) $(AR_OPTIONS) $(LIB_ARCHIVE) $@

$(LIB_DIR)\tinyuart.o: $(PLATFORM_DIR)\lib\tinyuart\tinyuart.c
	@echo # cc $(@F)
	$(CC) $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) $? -o $@
	$(AR) $(AR_OPTIONS) $(LIB_ARCHIVE) $@

$(LIB_DIR)\xsHost.o: $(XS_DIR)\platforms\gr_rose\xsHost.c
	@echo # cc $(@F)
	$(CC) $? $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o $@

$(LIB_DIR)\xsPlatform.o: $(XS_DIR)\platforms\gr_rose\xsPlatform.c
	@echo # cc $(@F)
	$(CC) $? $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS) -o $@

$(TMP_DIR)\mc.xs.o: $(TMP_DIR)\mc.xs.c
	$(CC) $? $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS_NODATASECTION) -o $@

$(TMP_DIR)\main.o: $(BUILD_DIR)\devices\gr_rose\main.cpp
	@echo # cc $(@F)
	$(CPP) $? $(C_DEFINES) $(C_INCLUDES) $(CPP_INCLUDES) $(CPP_FLAGS) -o $@

$(TMP_DIR)\mc.xs.c: $(MODULES) $(MANIFEST)
	@echo # xsl modules
	$(XSL) -b $(MODULES_DIR) -o $(TMP_DIR) $(PRELOADS) $(STRIPS) $(CREATION) -u / $(MODULES)

$(TMP_DIR)\mc.resources.c: $(DATA) $(RESOURCES) $(MANIFEST)
	@echo # mcrez resources
	$(MCREZ) $(DATA) $(RESOURCES) -o $(TMP_DIR) -p gr_rose -r mc.resources.c
	
$(TMP_DIR)\mc.resources.o: $(TMP_DIR)\mc.resources.c
	$(CC) $? $(C_DEFINES) $(C_INCLUDES) $(C_FLAGS_NODATASECTION) -o $@


