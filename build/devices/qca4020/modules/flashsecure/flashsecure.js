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

class FlashSecure @ "xs_flashsecure_destructor" {
	constructor(name) @ "xs_flashsecure"

	// sector and offsets are relative to area opened in constructor
	erase(sector) @ "xs_flashsecure_erase";
	read(offset, byteLength, buffer) @ "xs_flashsecure_read";
	write(offset, byteLength, buffer) @ "xs_flashsecure_write";
	get byteLength()  @ "xs_flashsecure_byteLength";
	get blockSize()  @ "xs_flashsecure_blockSize";
}
Object.freeze(FlashSecure.prototype);

export default FlashSecure;