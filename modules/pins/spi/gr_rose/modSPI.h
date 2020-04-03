/*
 * Copyright (c) 2016-2017  Moddable Tech, Inc.
 *
 *   This file is part of the Moddable SDK Runtime.
 *
 *   The Moddable SDK Runtime is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU Lesser General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   The Moddable SDK Runtime is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Lesser General Public License for more details.
 *
 *   You should have received a copy of the GNU Lesser General Public License
 *   along with the Moddable SDK Runtime.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#ifndef __MODSPI_H__
#define __MODSPI_H__

#include "stdint.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct modSPIConfigurationRecord modSPIConfigurationRecord;
typedef struct modSPIConfigurationRecord *modSPIConfiguration;

typedef void (*modSPIChipSelectCallback)(uint8_t active, modSPIConfiguration config);

struct modSPIConfigurationRecord {
	uint32_t hz;
	uint8_t spiPort;
	uint8_t csPort;
	uint8_t csPin;
	modSPIChipSelectCallback doChipSelect;
	uint32_t reserved;
	uint8_t sync;
};

typedef struct modSPIConfigurationRecord modSPIConfigurationRecord;
typedef struct modSPIConfigurationRecord *modSPIConfiguration;

extern void modSPIConfigP(modSPIConfiguration config, uint32_t hz, uint8_t spiPort,
	uint8_t csPort, uint8_t csPin, modSPIChipSelectCallback doChipSelect);
#define modSPIConfig(config, HZ, SPI_PORT, CS_PORT, CS_PIN, DOCHIPSELECT) \
	modSPIConfigP(&config, HZ, SPI_PORT, CS_PORT, CS_PIN, DOCHIPSELECT)

extern void modSPIInit(modSPIConfiguration config);
extern void modSPIUninit(modSPIConfiguration config);
extern void modSPITxRx(modSPIConfiguration config, uint8_t *data, uint16_t count);
extern void modSPITx(modSPIConfiguration config, uint8_t *data, uint16_t count);
extern void modSPITxSwap16(modSPIConfiguration config, uint8_t *data, uint16_t count);
extern void modSPITxRGB332To16BE(modSPIConfiguration config, uint8_t *data, uint16_t count);
extern void modSPITxGray256To16BE(modSPIConfiguration config, uint8_t *data, uint16_t count);
extern void modSPITxGray16To16BE(modSPIConfiguration config, uint8_t *data, uint16_t count);
extern void modSPITxCLUT16To16BE(modSPIConfiguration config, uint8_t *data, uint16_t count, uint16_t *colors);
extern void modSPIFlush(void);
extern void modSPIActivateConfiguration(modSPIConfiguration config);
#define modSPISetSync(config, _sync) (config)->sync = (_sync)

#ifdef __cplusplus
}
#endif

#endif
