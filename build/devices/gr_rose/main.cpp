/*
 * Copyright (c) 2016-2018  Moddable Tech, Inc.
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

#define __XS6PLATFORMMINIMAL__

#include <Arduino.h>
#include "FreeRTOS.h"
#include "task.h"
#include "xs.h"
#include "xsHost.h"
#include "modTimer.h"

extern "C" {
	extern void fx_putc(void *refcon, char c);
	extern void mc_setup(xsMachine *the);
	extern uint16_t setupPacketwValue;
}

/*
	Wi-Fi configuration and xsbug IP address
		
	IP address either:
		0,0,0,0 - no xsbug connection
		127,0,0,7 - xsbug over serial
		w,x,y,z - xsbug over TCP (address of computer running xsbug)
*/

#define XSDEBUG_NONE 0,0,0,0
#define XSDEBUG_SERIAL 127,0,0,7
#ifndef DEBUG_IP
	#define DEBUG_IP XSDEBUG_SERIAL
#endif

#ifdef mxDebug
	unsigned char gXSBUG[4] = {DEBUG_IP};

	xsMachine *gThe;		// root virtual machine
#endif

#if !defined(DEBUGGER_SPEED) || (DEBUGGER_SPEED == 0)
#define DEBUGGER_SPEED 115200
#endif

void setup()
{
	// LEDs
	pinMode(PIN_LED1, OUTPUT);
	pinMode(PIN_LED2, OUTPUT);

	digitalWrite(PIN_LED1, HIGH);

	Serial.begin(DEBUGGER_SPEED);

#ifdef mxDebug
	int i = 0;
	while((setupPacketwValue & 0x0002) == 0) {
		i++;
		if (i >= 1000){
			i = 0;
			digitalWrite(PIN_LED2, !digitalRead(PIN_LED2));
		}
		vTaskDelay(1);
	}

	digitalWrite(PIN_LED1, LOW);
	digitalWrite(PIN_LED2, LOW);

	gThe = ESP_cloneMachine(0, 0, 0, NULL);

	mc_setup(gThe);
#else
	mc_setup(ESP_cloneMachine(0, 0, 0, NULL));
#endif
}

void loop(void)
{
#if mxDebug
	fxReceiveLoop();
#endif

	modTimersExecute();

	if (0 == modMessageService()) {
		int delayMS = modTimersNext();
		if (delayMS)
			modDelayMilliseconds(delayMS);
	}
}

/*
	Required functions provided by application
	to enable serial port for diagnostic information and debugging
*/

void modLog_transmit(const char *msg)
{
	uint8_t c;

#ifdef mxDebug
	if (gThe) {
		while (c = c_read8(msg++))
			fx_putc(gThe, c);
		fx_putc(gThe, 0);
	}
	else
#endif
	{
		while (c = c_read8(msg++))
			ESP_putc(c);
		ESP_putc(13);
		ESP_putc(10);
	}
}

void ESP_putc(int c)
{
	Serial.write(c);
}

void ESP_put(uint8_t *c, int count)
{
	while (count--)
		Serial.write(*c++);
}

int ESP_getc(void)
{
	return Serial.read();
}

uint8_t ESP_isReadable()
{
	return Serial.available();
}

uint8_t ESP_setBaud(int baud)
{
	Serial.begin(baud);
	return 0;
}

extern "C" void gr_rose_schedule(void)
{
}
