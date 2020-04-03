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

#include "xsHost.h"

#include <Arduino.h>
#include "util.h"

#include "modGPIO.h"

int modGPIOInit(modGPIOConfiguration config, const char *port, uint8_t pin, uint32_t mode)
{
	int result;

	if (pin < 0 || pin >= NUM_DIGITAL_PINS) {
		return -1;
	}

	config->pin = pin;

	result = modGPIOSetMode(config, mode);
	if (result) {
		config->pin = INVALID_IO;
		return result;
	}

	return 0;
}

void modGPIOUninit(modGPIOConfiguration config)
{
	resetPinMode(config->pin);
}

int modGPIOSetMode(modGPIOConfiguration config, uint32_t mode)
{
	switch (mode) {
	case kModGPIOInput:
		pinMode(config->pin, INPUT);
		break;
	case kModGPIOInputPullUp:
		pinMode(config->pin, INPUT_PULLUP);
		break;
	case kModGPIOInputPullDown:
		return -1;
	case kModGPIOInputPullUpDown:
		return -1;
	case kModGPIOOutput:
		pinMode(config->pin, OUTPUT);
		break;
	case kModGPIOOutputOpenDrain:
		pinMode(config->pin, OUTPUT_OPENDRAIN);
		break;
	default:
		return -1;
	}

	return 0;
}

uint8_t modGPIORead(modGPIOConfiguration config)
{
	return digitalRead(config->pin);
}

void modGPIOWrite(modGPIOConfiguration config, uint8_t value)
{
	if (value)
		digitalWrite(config->pin, HIGH);
	else
		digitalWrite(config->pin, LOW);
}
