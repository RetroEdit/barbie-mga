
-- Barbie: Magic Genie Adventure (GBC) light mod
--
-- Lights up Dragon nursery to full brightness.
-- Note: this modifies how the game behaves,
-- so it may not always be deterministic for TAS purposes
-- It might be possible to do this without event.on_bus_exec;
-- or even, with more work, without game mods at all.
--
-- Author: RetroEdit
-- Date: 2023-07-27
-- Tested on BizHawk 2.8 and 2.9.1

local function string_split(s, sep)
	local result = {}
	for part in string.gmatch(s, "([^" .. sep .. "]+)") do
		table.insert(result, part)
	end
	return result
end

bizhawk_version = string_split(client.getversion(), ".")
for k,v in pairs(bizhawk_version) do
	bizhawk_version[k] = tonumber(v)
end
if bizhawk_version[3] == nil then
	bizhawk_version[3] = 0
end
if bizhawk_version[1] <= 2 and bizhawk_version[2] <= 9 then
	event.on_bus_exec = event.onmemoryexecute
end

-- Skip ring check for Fiera's ring.
event.on_bus_exec(
	function(addr, val, flag)
		-- console.log(string.format("%6X: %04X", emu.framecount(), 0x2DE0))
		-- console.log(emu.getregisters())
		emu.setregister("A", 3)
	end,
	0x2DE0
)

-- Override background palette 1 fade-to buffer
event.on_bus_exec(
	function(addr, val, flag)
		if memory.readbyte(0xC36A) == 0x16 then
			memory.write_bytes_as_array(
				0xC385,
				-- {0x1C, 0x00, 0x19, 0x00, 0x16, 0x00, 0x00, 0x00}
				{0x1F, 0x00, 0x1B, 0x00, 0x18, 0x00, 0x00, 0x00}
			)
		end
	end,
	0x1662
)

-- Keep the script and callbacks loaded.
while true do
	emu.frameadvance()
end
