
-- Barbie: Magic Genie Adventure (GBC) tools
-- Author: RetroEdit
-- Date: 2023-07-25
-- Version: 0.2.0
-- Designed with BizHawk 2.8

local PIX_FONT_X, PIX_FONT_Y = 4, 7
local SCREEN_PIX_WIDTH = math.floor(client.bufferwidth() / PIX_FONT_X)
local SCREEN_PIX_HEIGHT = math.floor(client.bufferheight() / PIX_FONT_Y)
local function pix(x, y, s, fg, bg)
	gui.pixelText(x * PIX_FONT_X, y * PIX_FONT_Y, s, fg, bg, "gens")
end

local function pix_row(x, y, fg, bg)
	return function (s)
		pix(x, y, s, fg, bg)
		x = x + string.len(s)
	end
end

local curr_char = {prev_x=0, prev_y=0}

local frames, prev_frames = 0, 0
local prev_active = false

-- Bad design, but this is specific to the Pegasus minigame
local PEGASUS = false
local curr_char2 = {prev_x=0, prev_y=0}
local prev_active2 = false

event.onexit(function() gui.clearGraphics() end)

while true do
	gui.clearGraphics()
	frames = emu.framecount()

	-- local value = memory.readbyte(0xC485, "System Bus")
	local screen_id = memory.readbyte(0xC0E7, "System Bus")
	pix(SCREEN_PIX_WIDTH - 2, 0, string.format("%2X", screen_id), 0xFFFFFFFF, 0x5F000000)

	-- if not (screen_id >= 2 and screen_id <= 5) then
	if screen_id <= 1 then
		prev_active = false
	else
		pix(SCREEN_PIX_WIDTH - 20, 3, "    x   dx    y   dy", 0xFFFF69B4, 0x5F000000)
		local char_row = pix_row(SCREEN_PIX_WIDTH - 20, 4, 0xFFFF69B4, 0x5F000000)
		local x = memory.read_u16_le(0xC0BF, "System Bus")
		local y = memory.read_u16_le(0xC0C8, "System Bus")
		local diff_x, diff_y = x - curr_char.prev_x, y - curr_char.prev_y
		curr_char.prev_x, curr_char.prev_y = x, y
		if not prev_active or prev_frames + 1 ~= frames then
			diff_x, diff_y = "    ?", "    ?"
		else
			diff_x = string.format('%5s', diff_x)
			diff_y = string.format('%5s', diff_y)
		end
		char_row(string.format('%5u', x))
		char_row(diff_x)
		char_row(string.format('%5u', y))
		char_row(diff_y)
		prev_active = true
	end

	if PEGASUS then
		pix(SCREEN_PIX_WIDTH - 14, 6, "   x dx   y dy", 0xFFFF69B4, 0x5F000000)
		local char_row = pix_row(SCREEN_PIX_WIDTH - 14, 7, 0xFFFF69B4, 0x5F000000)
		local x = memory.readbyte(0xC6C0, "System Bus")
		-- I think this is the real y coord, even though it's camera-relative
		local y = memory.readbyte(0xC6BF, "System Bus")
		local diff_x, diff_y = x - curr_char2.prev_x, y - curr_char2.prev_y
		curr_char2.prev_x, curr_char2.prev_y = x, y
		if not prev_active2 or prev_frames + 1 ~= frames then
			diff_x, diff_y = "  ?", "  ?"
		else
			diff_x = string.format('%3s', diff_x)
			diff_y = string.format('%3s', diff_y)
		end
		char_row(string.format('%4u', x))
		char_row(diff_x)
		char_row(string.format('%4u', y))
		char_row(diff_y)
		prev_active2 = true
	end

	prev_frames = frames
	emu.frameadvance()
end
