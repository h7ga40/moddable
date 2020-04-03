/*
 * Copyright (c) 2016-2019  Moddable Tech, Inc.
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

#include "modSPI.h"

#include <Arduino.h>
#include "SPI.h"

#include "string.h"

#include "xsHost.h"
#include "commodettoBitmap.h"

typedef uint16_t(*modSPIBufferLoader)(uint8_t *data, uint16_t bytes, uint16_t *bitsOut);

static modSPIConfiguration gConfig;

// SPI_BUFFER_SIZE can be larger than 64... tested up to 512
#define SPI_BUFFER_SIZE (256)
static uint32_t gSPITransactionBuffer[SPI_BUFFER_SIZE / sizeof(uint32_t)];

void modSPIConfigP(modSPIConfiguration config, uint32_t hz, uint8_t spiPort,
	uint8_t csPort, uint8_t csPin, modSPIChipSelectCallback doChipSelect)
{
	config->hz = hz;
	config->spiPort = spiPort;
	config->csPort = csPort;
	config->csPin = csPin;
	config->doChipSelect = doChipSelect;
}

void modSPIInit(modSPIConfiguration config)
{
	if (config->spiPort != 1)
		return;

	SPI.begin();

	(config->doChipSelect)(0, config);
}

void modSPIUninit(modSPIConfiguration config)
{
	if (config == gConfig)
		modSPIActivateConfiguration(NULL);

	SPI.end();
}

void modSPIActivateConfiguration(modSPIConfiguration config)
{
	modSPIFlush();

	if (config == gConfig)
		return;

	if (gConfig)
		(gConfig->doChipSelect)(0, gConfig);

	gConfig = config;
	if (gConfig)
		(gConfig->doChipSelect)(1, gConfig);
}


// data must be long aligned
uint16_t modSpiLoadBufferAsIs(uint8_t *data, uint16_t bytes, uint16_t *bitsOut)
{
	uint32_t *from = (uint32_t *)data, *to = gSPITransactionBuffer;
	uint8_t longs;
	uint16_t result = bytes;

	*bitsOut = bytes << 3;

	while (bytes >= 64) {
		*to++ = *from++;
		*to++ = *from++;
		*to++ = *from++;
		*to++ = *from++;
		*to++ = *from++;
		*to++ = *from++;
		*to++ = *from++;
		*to++ = *from++;
		*to++ = *from++;
		*to++ = *from++;
		*to++ = *from++;
		*to++ = *from++;
		*to++ = *from++;
		*to++ = *from++;
		*to++ = *from++;
		*to++ = *from++;
		bytes -= 64;
	}

	longs = (bytes + 3) >> 2;
	while (longs--)
		*to++ = *from++;

	return result;
}

uint16_t modSpiLoadBufferSwap16(uint8_t *data, uint16_t bytes, uint16_t *bitsOut)
{
	uint32_t *from = (uint32_t *)data;
	uint32_t *to = gSPITransactionBuffer;
	const uint32_t mask = 0x00ff00ff;
	uint32_t twoPixels;
	uint16_t result = bytes;
	uint8_t longs;

	*bitsOut = bytes << 3;

	while (bytes >= 64) {
		twoPixels = *from++; *to++ = ((twoPixels & mask) << 8) | ((twoPixels >> 8) & mask);
		twoPixels = *from++; *to++ = ((twoPixels & mask) << 8) | ((twoPixels >> 8) & mask);
		twoPixels = *from++; *to++ = ((twoPixels & mask) << 8) | ((twoPixels >> 8) & mask);
		twoPixels = *from++; *to++ = ((twoPixels & mask) << 8) | ((twoPixels >> 8) & mask);
		twoPixels = *from++; *to++ = ((twoPixels & mask) << 8) | ((twoPixels >> 8) & mask);
		twoPixels = *from++; *to++ = ((twoPixels & mask) << 8) | ((twoPixels >> 8) & mask);
		twoPixels = *from++; *to++ = ((twoPixels & mask) << 8) | ((twoPixels >> 8) & mask);
		twoPixels = *from++; *to++ = ((twoPixels & mask) << 8) | ((twoPixels >> 8) & mask);
		twoPixels = *from++; *to++ = ((twoPixels & mask) << 8) | ((twoPixels >> 8) & mask);
		twoPixels = *from++; *to++ = ((twoPixels & mask) << 8) | ((twoPixels >> 8) & mask);
		twoPixels = *from++; *to++ = ((twoPixels & mask) << 8) | ((twoPixels >> 8) & mask);
		twoPixels = *from++; *to++ = ((twoPixels & mask) << 8) | ((twoPixels >> 8) & mask);
		twoPixels = *from++; *to++ = ((twoPixels & mask) << 8) | ((twoPixels >> 8) & mask);
		twoPixels = *from++; *to++ = ((twoPixels & mask) << 8) | ((twoPixels >> 8) & mask);
		twoPixels = *from++; *to++ = ((twoPixels & mask) << 8) | ((twoPixels >> 8) & mask);
		twoPixels = *from++; *to++ = ((twoPixels & mask) << 8) | ((twoPixels >> 8) & mask);
		bytes -= 64;
	}

	longs = (bytes + 3) >> 2;
	while (longs--) {
		twoPixels = *from++; *to++ = ((twoPixels & mask) << 8) | ((twoPixels >> 8) & mask);
	}

	return result;

}

uint16_t modSpiLoadBufferRGB565LEtoRGB444(uint8_t *data, uint16_t bytes, uint16_t *bitsOut)
{
	uint16_t *from = (uint16_t *)data;
	uint8_t *to = (uint8_t *)gSPITransactionBuffer;
	uint16_t remain;

	if (bytes > SPI_BUFFER_SIZE)
		bytes = SPI_BUFFER_SIZE;

	*bitsOut = (bytes >> 1) * 12;

	remain = bytes >> 2;
	while (remain--) {
		uint8_t r, g, b;
		uint16_t rgb565 = *from++;
		r = rgb565 >> 12, g = (rgb565 >> 7) & 0x0F, b = (rgb565 >> 1) & 0x0F;
		*to++ = (r << 4) | g;

		rgb565 = *from++;
		r = rgb565 >> 12;
		*to++ = (b << 4) | r;
		g = (rgb565 >> 7) & 0x0F, b = (rgb565 >> 1) & 0x0F;
		*to++ = (g << 4) | b;
	}

	if (bytes & 2) {
		uint8_t r, g, b;
		uint16_t rgb565 = *from;
		r = rgb565 >> 12, g = (rgb565 >> 7) & 0x0F, b = (rgb565 >> 1) & 0x0F;
		*to++ = (r << 4) | g;
		*to = b << 4;
	}

	return bytes;		// input bytes consumed
}

uint16_t modSpiLoadBufferRGB332To16BE(uint8_t *data, uint16_t bytes, uint16_t *bitsOut)
{
	uint8_t *from = (uint8_t *)data;
	uint32_t *to = gSPITransactionBuffer;
	uint16_t remain;

	if (bytes > (SPI_BUFFER_SIZE >> 1))
		bytes = SPI_BUFFER_SIZE >> 1;

	*bitsOut = bytes << 4;		// output bits are double input bits

	remain = bytes;
	while (remain >= 2) {
		uint8_t rgb332, r, g, b;
		uint16_t pixela, pixelb;

		rgb332 = *from++;
		r = rgb332 >> 5, g = (rgb332 >> 2) & 0x07, b = rgb332 & 0x03;
		r = (r << 2) | (r >> 2), g |= g << 3, b = (b << 3) | (b << 1) | (b >> 1);
		pixela = (r << 11) | (g << 5) | b;
		pixela = (pixela >> 8) | (pixela << 8);

		rgb332 = *from++;
		r = rgb332 >> 5, g = (rgb332 >> 2) & 0x07, b = rgb332 & 0x03;
		r = (r << 2) | (r >> 2), g |= g << 3, b = (b << 3) | (b << 1) | (b >> 1);
		pixelb = (r << 11) | (g << 5) | b;
		pixelb = (pixelb >> 8) | (pixelb << 8);

		*to++ = (pixelb << 16) | pixela;
		remain -= 2;
	}

	if (remain) {
		uint16_t pixela;
		uint8_t rgb332 = *from++, r, g, b;
		r = rgb332 >> 5, g = (rgb332 >> 2) & 0x07, b = rgb332 & 0x03;
		r = (r << 2) | (r >> 2), g |= g << 3, b = (b << 3) | (b << 1) | (b >> 1);
		pixela = (r << 11) | (g << 5) | b;
		pixela = (pixela >> 8) | (pixela << 8);
		*to++ = (0 << 16) | pixela;
	}

	return bytes;		// input bytes consumed
}

uint16_t modSpiLoadBufferGray256To16BE(uint8_t *data, uint16_t bytes, uint16_t *bitsOut)
{
	uint8_t *from = (uint8_t *)data;
	uint32_t *to = gSPITransactionBuffer;
	uint16_t remain;

	if (bytes > (SPI_BUFFER_SIZE >> 1))
		bytes = SPI_BUFFER_SIZE >> 1;

	*bitsOut = bytes << 4;		// output bits are double input bits

	remain = bytes;
	while (remain >= 2) {
		uint8_t gray;
		uint16_t pixela, pixelb;

		gray = *from++;
		pixela = ((gray >> 3) << 11) | ((gray >> 2) << 5) | (gray >> 3);
		pixela = (pixela >> 8) | (pixela << 8);

		gray = *from++;
		pixelb = ((gray >> 3) << 11) | ((gray >> 2) << 5) | (gray >> 3);
		pixelb = (pixelb >> 8) | (pixelb << 8);

		*to++ = (pixelb << 16) | pixela;
		remain -= 2;
	}

	if (remain) {
		uint8_t gray = *from++;
		uint16_t pixela = ((gray >> 3) << 11) | ((gray >> 2) << 5) | (gray >> 3);
		pixela = (pixela >> 8) | (pixela << 8);
		*to++ = (0 << 16) | pixela;
	}

	return bytes;		// input bytes consumed
}

uint16_t modSpiLoadBufferGray16To16BE(uint8_t *data, uint16_t bytes, uint16_t *bitsOut)
{
	uint8_t *from = (uint8_t *)data;
	uint32_t *to = gSPITransactionBuffer;
	uint16_t i;

	if (bytes > (SPI_BUFFER_SIZE >> 2))
		bytes = SPI_BUFFER_SIZE >> 2;
	*bitsOut = bytes << 5;		// output bits are quadruple input bits

	for (i = 0; i < bytes; i++) {
		uint8_t gray;
		uint8_t twoPixels = *from++;
		uint16_t pixela, pixelb;

		gray = (twoPixels >> 2) & 0x3C;
		gray |= gray >> 4;				// 6 bits of gray
		pixela = gray >> 1;				// 5 bita of gray
		pixela |= (pixela << 11) | (gray << 5);
		pixela = (pixela >> 8) | (pixela << 8);

		gray = (twoPixels << 2) & 0x3C;
		gray |= gray >> 4;
		pixelb = gray >> 1;
		pixelb |= (pixelb << 11) | (gray << 5);
		pixelb = (pixelb >> 8) | (pixelb << 8);

		*to++ = (pixelb << 16) | pixela;
	}

	return bytes;		// input bytes consumed
}

void modSPITxRx(modSPIConfiguration config, uint8_t *data, uint16_t count)
{
	SPISettings settings;

	modSPIActivateConfiguration(config);

	SPI.beginTransaction(settings);

	uint8_t *pos = data, *end = &data[count];
	for (; pos < end; pos++) {
		*pos = SPI.transfer(*pos);
	}

	SPI.endTransaction();
}

void modSPIFlush(void)
{

}

static void modSPITxCommon(modSPIConfiguration config, uint8_t *data, uint16_t count, modSPIBufferLoader loader)
{
	SPISettings settings;

	modSPIActivateConfiguration(config);

	SPI.beginTransaction(settings);

	uint8_t *pos = data, *end = &data[count];
	for (; pos < end; pos++) {
		SPI.transfer(*pos);
	}

	SPI.endTransaction();

	if (config->sync)
		modSPIFlush();
}

void modSPITx(modSPIConfiguration config, uint8_t *data, uint16_t count)
{
	modSPITxCommon(config, data, count, modSpiLoadBufferAsIs);
}

void modSPITxSwap16(modSPIConfiguration config, uint8_t *data, uint16_t count)
{
	modSPITxCommon(config, data, count, modSpiLoadBufferSwap16);
}

void modSPITxRGB565LEtoRGB444(modSPIConfiguration config, uint8_t *data, uint16_t count)
{
	modSPITxCommon(config, data, count, modSpiLoadBufferRGB565LEtoRGB444);
}

void modSPITxRGB332To16BE(modSPIConfiguration config, uint8_t *data, uint16_t count)
{
	modSPITxCommon(config, data, count, modSpiLoadBufferRGB332To16BE);
}

void modSPITxGray256To16BE(modSPIConfiguration config, uint8_t *data, uint16_t count)
{
	modSPITxCommon(config, data, count, modSpiLoadBufferGray256To16BE);
}

void modSPITxGray16To16BE(modSPIConfiguration config, uint8_t *data, uint16_t count)
{
	modSPITxCommon(config, data, count, modSpiLoadBufferGray16To16BE);
}

void modSPITxCLUT16To16BE(modSPIConfiguration config, uint8_t *data, uint16_t count, uint16_t *colors)
{
//	gCLUT16 = colors;
//	modSPITxCommon(config, data, count, modSpiLoadBufferCLUT16to16BE);
	printf("need to implement CLUT16to16BE\n");
}
