/*  $Id: hunk.qc,v 1.9 2003/07/19 00:58:58 slotzero Exp $

    Copyright (C) 2001, 2002  David 'Slot Zero' Roberts.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/

//-------------------------------------------------------------------
// HUNK MANIPULATION FUNCTIONS
//-------------------------------------------------------------------


entity (float type, float offset)
Get_Hunk =
{
	local entity hunk;

	if (!HUNK_CONTEXT_MAX)
		return world;

	hunk = *AddInt(AddInt(&progs, %-16), type);
	if (*hunk[%0] != *HUNK_SENTINAL)
		dprint ("Write_Hunk(): hunk != HUNK_SENTINAL\n");

	return *AddInt(&hunk, 4 * offset);
};

string (entity hunk)
Read_Hunk_e =
{
	return @AddInt(&hunk, PQUAKEC_TO_PSTRING);
};

string (float type, float offset)
Read_Hunk =
{
	local entity hunk;

	hunk = Get_Hunk (type, offset);

	return @AddInt(&hunk, PQUAKEC_TO_PSTRING);
};

float (float type, float offset)
Read_Hunk_Float =
{
	local entity hunk;

	hunk = Get_Hunk (type, offset);
	if (!hunk)
	{
		dprint ("Read_Hunk_Float: hunk is null\n");
		return 0;
	}

	return hunk[%0];
};

void (entity hunk, string s)
Write_Hunk_e =
{
	strcpy (@AddInt(&hunk, PQUAKEC_TO_PSTRING), s);
};

void (float type, float offset, string s)
Write_Hunk =
{
	local entity hunk;

	hunk = Get_Hunk (type, offset);
	Write_Hunk_e (hunk, s);
};

void (float type, float offset, float f)
Write_Hunk_Float =
{
	local entity hunk;

	hunk = Get_Hunk (type, offset);
	if (!hunk)
		return dprint ("Write_Hunk_Float: hunk is null\n");

	hunk[%0] = f;
};

string (entity hunk, float bytes)
Read_Hunk_Max_e =
{
	local float i, pdata, dword;
	local string data;

	data = allocate_string_size (bytes);
	pdata = AddInt (&data, PSTRING_TO_PQUAKEC);

	dword	= floor (bytes / 4) * %1;
	while (bytes > 3)
		bytes = bytes - 4;

	for (i = %0; i < dword; i = i + %1)
		(*pdata)[i] = hunk[i];

 	if (bytes)
	{
		bytes = NegInt ((4 - bytes) * %1);
		hunk = *AddInt (&hunk, bytes);
		pdata = AddInt (pdata, bytes);
		(*pdata)[i] = hunk[i];
		bytes = NegInt (bytes);
		hunk = *AddInt (&hunk, bytes);
		pdata = AddInt (pdata, bytes);
 	}

	return (@AddInt (pdata, PQUAKEC_TO_PSTRING));
};

string (float type, float offset, float bytes)
Read_Hunk_Max =
{
	local entity hunk;

	hunk = Get_Hunk (type, offset);

	return Read_Hunk_Max_e (hunk, bytes);
};

// This will always force a null termination.  The actual
// size of bytes is bytes + one (data\0).
void (entity hunk, string data, float bytes)
Write_Hunk_Max_E =
{
	if (!hunk)
		return dprint ("Write_Hunk_Max_E(): hunk is null\n");

	if (bytes < 1)
		return dprint ("Write_Hunk_Max_E(): bytes < 1\n");

	data = substr (data, 0, (bytes));
	strcpy (@AddInt(&hunk, PQUAKEC_TO_PSTRING), data);
};

// When bytes is less than four, a null termination is written which
// increases the actual size of bytes by one (1=2, 2=3, 3=4, 4=4, 5=5).
// If bytes is larger than data, only data (including termination) is
// written.  To write a string without termination, bytes must be equal
// to the length of data and over 3 bytes.
void (entity hunk, string data, float bytes)
Write_Hunk_Max_e =
{
	local float i, pdata, dword;

	if (!hunk)
		return dprint ("Write_Hunk_Max_e(): hunk is null\n");

	i = strlen (data);
	if (bytes > i)
		bytes = i + 1;

	dword	= floor (bytes / 4) * %1;
	if (!dword)
		return Write_Hunk_Max_E (hunk, data, bytes);

	pdata = AddInt (&data, PSTRING_TO_PQUAKEC);

	while (bytes > 3)
		bytes = bytes - 4;

	for (i = %0; i < dword; i = i + %1)
		hunk[i] = (*pdata)[i];

 	if (bytes)
	{
		bytes = NegInt ((4 - bytes) * %1);
		hunk = *AddInt (&hunk, bytes);
		pdata = AddInt (pdata, bytes);
		hunk[i] = (*pdata)[i];
		bytes = NegInt (bytes);
		hunk = *AddInt (&hunk, bytes);
		pdata = AddInt (pdata, bytes);
 	}
};

void (float type, float offset, string data, float bytes)
Write_Hunk_Max =
{
	local entity hunk;

	hunk = Get_Hunk (type, offset);
	Write_Hunk_Max_e (hunk, data, bytes);
};