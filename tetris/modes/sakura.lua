require 'funcs'

local GameMode = require 'tetris.modes.gamemode'
local Piece = require 'tetris.components.piece'

local SakuraRandomizer = require 'tetris.randomizers.sakura'
local History6RollsRandomizer = require 'tetris.randomizers.history_6rolls_35bag'

local SakuraGame = GameMode:extend()

SakuraGame.name = "Sakura A3"
SakuraGame.hash = "SakuraA3"
SakuraGame.tagline = "Clear away the Gem Blocks as fast as possible!"

local b = {
	["r"] = { skin = "2tie", colour = "R" },
	["o"] = { skin = "2tie", colour = "O" },
	["y"] = { skin = "2tie", colour = "Y" },
	["g"] = { skin = "2tie", colour = "G" },
	["c"] = { skin = "2tie", colour = "C" },
	["b"] = { skin = "2tie", colour = "B" },
	["m"] = { skin = "2tie", colour = "M" },
	["R"] = { skin = "gem", colour = "R" },
	["O"] = { skin = "gem", colour = "O" },
	["Y"] = { skin = "gem", colour = "Y" },
	["G"] = { skin = "gem", colour = "G" },
	["C"] = { skin = "gem", colour = "C" },
	["B"] = { skin = "gem", colour = "B" },
	["M"] = { skin = "gem", colour = "M" },
}

local effects = {
	[4] = "mirror",
	[8] = "xray",
	[12] = "color",
	[13] = "mirror",
	[16] = "roll",
	[23] = "big"
}

local maps = {
	[1] = {
		[22] = {nil, nil, b.O, b.R, nil, nil, b.M, b.m, nil, nil},
		[23] = {nil, b.G, b.c, b.c, b.c, b.c, b.c, b.c, b.Y, nil},
		[24] = {nil, b.C, b.y, b.y, b.y, b.y, b.y, b.y, b.B, nil},
	},
	[2] = {
		[20] = {nil, nil, nil, nil, b.G, b.b, b.b, b.M, nil, nil},
		[21] = {nil, nil, nil, nil, b.c, b.c, b.c, b.c, nil, nil},
		[22] = {nil, nil, nil, nil, nil, b.R, b.Y, b.O, nil, nil},
		[23] = {nil, b.B, b.c, b.c, b.c, b.c, b.c, b.c, b.c, nil},
		[24] = {nil, b.b, b.b, b.b, b.b, b.b, b.b, b.b, b.C, nil},
	},
	[3] = {
		[20] = {nil, nil, nil, b.R, b.m, b.o, b.M, nil, nil, nil},
		[21] = {nil, nil, nil, nil, b.o, b.O, nil, nil, nil, nil},
		[22] = {nil, nil, nil, nil, b.G, b.Y, nil, nil, nil, nil},
		[23] = {nil, b.m, b.o, b.m, b.o, b.m, b.o, b.m, b.o, nil},
		[24] = {nil, b.B, b.m, b.o, b.m, b.o, b.m, b.o, b.C, nil},
	},
	[4] = {
		[21] = {nil, nil, b.O, b.g, b.g, b.g, b.g, nil, nil, nil},
		[22] = {nil, nil, nil, b.R, b.M, b.b, b.b, nil, nil, nil},
		[23] = {b.G, nil, b.Y, b.g, b.g, b.g, b.g, b.g, nil, nil},
		[24] = {b.b, b.C, b.b, b.b, b.b, b.b, b.b, b.b, b.B, nil},
	},
	[5] = {
		[16] = {nil, b.B, b.c, b.y, b.c, b.G, b.c, b.y, b.C, nil},
		[22] = {nil, nil, b.c, b.y, b.c, b.y, b.c, b.y, nil, nil},
		[23] = {nil, b.O, b.y, b.c, b.y, b.c, b.y, b.c, b.Y, nil},
		[24] = {nil, b.R, b.c, b.y, b.c, b.y, b.c, b.y, b.M, nil},
	},
	[6] = {
		[21] = {nil, nil, nil, nil, b.O, b.Y, nil, nil, nil, nil},
		[22] = {nil, nil, b.R, nil, b.b, b.y, nil, b.M, nil, nil},
		[23] = {nil, nil, nil, nil, b.y, b.b, nil, nil, nil, nil},
		[24] = {nil, b.G, b.y, b.b, b.C, b.y, b.b, b.y, b.B, nil},
	},
	[7] = {
		[20] = {nil, b.C, b.G, nil, b.r, b.g, b.r, b.g, nil, nil},
		[21] = {nil, nil, nil, nil, b.R, b.M, b.g, b.r, nil, nil},
		[22] = {b.r, nil, nil, nil, b.r, b.g, b.O, b.Y, nil, nil},
		[23] = {b.g, b.r, b.g, b.r, b.g, b.r, b.g, b.r, nil, nil},
		[24] = {b.r, b.g, b.r, b.g, b.r, b.g, b.r, b.g, b.B, nil},
	},
	[8] = {
		[15] = {nil, nil, nil, b.B, b.m, b.m, b.m, b.m, b.m, b.C},
		[16] = {nil, nil, nil, nil, nil, nil, nil, nil, nil, b.m},
		[17] = {nil, nil, nil, nil, nil, nil, nil, nil, nil, b.m},
		[18] = {nil, b.Y, b.y, b.y, b.y, b.y, b.y, b.y, b.y, b.G},
		[21] = {b.b, b.b, b.b, b.b, b.b, b.b, b.O, nil, nil, nil},
		[22] = {b.b, nil, nil, nil, nil, nil, nil, nil, nil, nil},
		[23] = {b.M, nil, nil, nil, nil, nil, nil, nil, nil, nil},
		[24] = {b.o, b.o, b.o, b.o, b.o, b.o, b.o, b.o, b.R, nil},
	},
	[9] = {
		[18] = {nil, nil, nil, b.Y, b.m, b.m, b.m, b.m, nil, nil},
		[19] = {nil, nil, nil, b.c, b.c, b.c, b.c, b.G, nil, nil},
		[20] = {b.m, b.m, b.m, b.O, b.M, b.R, nil, nil, nil, nil},
		[21] = {b.c, b.c, b.c, b.c, b.c, b.c, b.c, b.c, nil, nil},
		[22] = {b.m, b.m, b.m, b.m, b.m, b.m, b.m, b.m, nil, nil},
		[23] = {b.c, b.c, b.c, b.c, b.c, b.c, b.c, b.c, b.C, nil},
		[24] = {b.m, b.m, b.m, b.m, b.m, b.m, b.m, b.m, b.B, nil},
	},
	[10] = {
		[18] = {nil, nil, nil, b.C, b.g, b.g, b.B, nil, nil, nil},
		[19] = {nil, nil, b.G, b.g, b.g, b.g, b.g, b.Y, nil, nil},
		[20] = {nil, b.M, b.g, b.g, b.g, b.g, b.g, b.g, b.O, nil},
		[21] = {nil, nil, nil, nil, b.c, nil, nil, nil, nil, nil},
		[22] = {nil, nil, nil, nil, b.c, nil, nil, nil, nil, nil},
		[23] = {nil, nil, nil, nil, b.c, nil, b.o, nil, nil, nil},
		[24] = {nil, nil, nil, nil, b.R, b.o, b.o, nil, nil, nil},
	},
	[11] = {
		[18] = {nil, nil, nil, nil, b.o, b.o, nil, nil, nil, nil},
		[19] = {nil, nil, nil, nil, b.R, nil, nil, nil, nil, nil},
		[20] = {nil, nil, nil, nil, b.r, b.O, nil, nil, nil, nil},
		[21] = {nil, nil, nil, nil, nil, b.M, nil, nil, nil, nil},
		[22] = {nil, nil, nil, nil, b.o, b.o, nil, nil, nil, nil},
		[23] = {nil, nil, nil, nil, b.G, b.Y, nil, nil, nil, nil},
		[24] = {b.C, b.g, b.g, nil, b.o, b.o, nil, b.g, b.g, b.B},
	},
	[12] = {
		[21] = {nil, nil, nil, nil, nil, nil, nil, b.g, b.g, b.Y},
		[22] = {nil, nil, b.r, b.G, b.r, nil, nil, nil, b.O, b.g},
		[23] = {nil, b.r, b.C, b.r, b.B, b.r, nil, nil, nil, b.M},
		[24] = {b.r, b.r, b.r, b.R, b.r, b.r, b.r, nil, nil, nil},
	},
	[13] = {
		[20] = {b.c, nil, nil, nil, nil, nil, nil, nil, nil, b.B},
		[21] = {b.c, b.c, nil, nil, nil, nil, nil, nil, b.C, b.c},
		[22] = {b.c, b.c, b.c, nil, nil, nil, nil, b.G, b.c, b.c},
		[23] = {b.b, b.b, b.b, b.b, nil, nil, b.Y, b.b, b.b, b.b},
		[24] = {nil, b.M, b.b, b.b, b.b, b.O, b.b, b.b, b.R, nil},
	},
	[14] = {
		[20] = {nil, nil, nil, b.y, b.r, b.y, nil, nil, nil, nil},
		[21] = {b.R, nil, nil, b.Y, b.y, b.r, b.G, nil, nil, nil},
		[22] = {nil, nil, nil, b.y, b.r, b.y, b.r, b.y, b.r, b.B},
		[23] = {nil, nil, nil, nil, nil, nil, nil, b.O, b.y, b.r},
		[24] = {nil, nil, nil, nil, nil, nil, b.M, b.y, b.r, b.C},
	},
	[15] = {
		[17] = {nil, nil, b.b, nil, nil, nil, nil, b.b, nil, nil},
		[18] = {nil, nil, b.b, b.y, b.b, b.b, b.y, b.b, nil, nil},
		[19] = {nil, nil, nil, b.y, b.b, b.b, b.y, nil, nil, nil},
		[20] = {nil, nil, nil, nil, b.O, b.Y, nil, nil, nil, nil},
		[22] = {nil, nil, nil, nil, b.M, b.R, nil, nil, nil, nil},
		[23] = {nil, nil, nil, b.G, b.y, b.y, b.C, nil, nil, nil},
		[24] = {nil, nil, b.B, b.y, b.y, b.y, b.y, b.y, nil, nil},
	},
	[16] = {
		[18] = {nil, nil, b.O, nil, nil, nil, nil, b.B, nil, nil},
		[19] = {nil, nil, b.c, nil, nil, b.G, nil, b.c, nil, nil},
		[20] = {nil, nil, b.c, nil, b.C, b.R, nil, b.c, nil, nil},
		[21] = {nil, nil, b.c, nil, nil, nil, nil, b.c, nil, nil},
		[22] = {nil, nil, b.Y, b.c, b.c, b.c, b.c, b.M, nil, nil},
	},
	[17] = {
		[15] = {b.O, nil, nil, b.g, nil, nil, b.m, nil, nil, b.Y},
		[16] = {nil, nil, nil, b.g, nil, nil, b.m, nil, nil, nil},
		[17] = {nil, nil, nil, b.g, nil, nil, b.R, nil, nil, nil},
		[18] = {nil, nil, nil, b.g, nil, nil, b.m, nil, nil, nil},
		[19] = {nil, nil, nil, b.M, nil, nil, b.m, nil, nil, nil},
		[20] = {nil, nil, nil, b.g, nil, nil, b.m, nil, nil, nil},
		[21] = {nil, nil, nil, b.g, nil, nil, b.G, nil, nil, nil},
		[22] = {nil, nil, nil, b.g, nil, nil, b.m, nil, nil, nil},
		[23] = {nil, nil, nil, b.g, nil, nil, b.m, nil, nil, nil},
		[24] = {nil, b.m, b.m, b.m, b.B, b.C, b.g, b.g, b.g, nil},
	},
	[18] = {
		[19] = {nil, nil, nil, b.y, b.B, b.y, b.y, nil, nil, nil},
		[20] = {nil, nil, b.y, nil, nil, nil, nil, b.y, nil, nil},
		[21] = {nil, b.o, nil, nil, b.C, b.R, nil, nil, b.O, nil},
		[22] = {nil, b.M, nil, nil, b.Y, b.G, nil, nil, b.o, nil},
		[23] = {nil, b.r, b.o, nil, nil, nil, nil, b.o, b.r, nil},
		[24] = {nil, b.r, b.r, b.o, b.o, b.o, b.o, b.r, b.r, nil},
	},
	[19] = {
		[15] = {nil, nil, nil, nil, nil, nil, b.O, nil, nil, nil},
		[16] = {nil, nil, nil, nil, nil, b.o, nil, nil, nil, nil},
		[17] = {nil, nil, nil, nil, b.o, b.r, b.o, nil, nil, nil},
		[18] = {nil, b.o, nil, nil, b.o, b.r, b.r, b.o, nil, nil},
		[19] = {nil, b.o, b.o, nil, nil, b.R, b.r, b.r, nil, nil},
		[20] = {nil, nil, b.M, b.r, nil, b.r, b.r, b.r, b.r, nil},
		[21] = {nil, nil, b.r, b.r, b.r, b.r, b.y, b.G, b.o, b.o},
		[22] = {nil, b.r, b.o, b.y, b.Y, b.y, b.y, b.y, b.y, b.o},
		[23] = {nil, b.o, b.o, b.y, b.y, b.c, b.c, b.c, b.c, b.C},
		[24] = {nil, nil, b.o, b.y, b.b, b.b, b.B, b.b, b.b, b.b},
	},
	[20] = {
		[20] = {nil, nil, b.B, b.b, b.b, b.b, b.b, b.b, nil, nil},
		[21] = {b.c, nil, nil, b.C, b.c, b.c, b.c, nil, nil, b.c},
		[22] = {b.g, b.g, nil, nil, b.G, b.g, nil, nil, b.g, b.g},
		[23] = {b.y, b.y, b.o, nil, nil, nil, nil, b.Y, b.y, b.y},
		[24] = {b.r, b.r, b.r, b.R, nil, nil, b.M, b.r, b.r, b.r},
	},
	[21] = {
		[16] = {nil, nil, b.g, b.g, b.g, b.g, b.g, nil, nil, nil},
		[17] = {nil, b.g, b.g, b.g, b.g, b.g, b.g, b.B, b.g, nil},
		[18] = {b.g, b.g, b.g, b.g, b.g, b.g, b.g, b.g, b.C, nil},
		[19] = {b.g, nil, nil, b.g, b.o, b.o, b.g, nil, nil, b.g},
		[20] = {nil, b.R, nil, b.g, b.o, b.o, nil, b.M, nil, b.G},
		[21] = {nil, nil, nil, nil, b.o, b.o, nil, nil, nil, nil},
		[22] = {nil, nil, nil, nil, b.o, b.o, nil, nil, nil, nil},
		[23] = {nil, nil, nil, nil, b.o, b.o, nil, nil, nil, nil},
		[24] = {nil, nil, nil, nil, b.Y, b.O, nil, nil, nil, nil},
	},
	[22] = {
		[15] = {nil, nil, b.b, nil, nil, nil, nil, b.b, nil, nil},
		[16] = {nil, b.b, b.O, b.b, nil, nil, b.b, b.Y, b.b, nil},
		[17] = {nil, nil, b.b, nil, nil, nil, nil, b.b, nil, nil},
		[20] = {nil, nil, nil, nil, b.R, b.M, nil, nil, nil, nil},
		[23] = {nil, nil, nil, b.b, b.C, b.G, b.b, nil, nil, nil},
		[24] = {nil, nil, nil, b.b, b.b, b.B, b.b, nil, nil, nil},
	},
	[23] = {
		[13] = {nil, nil, nil, nil, nil, nil, nil, nil, b.c, b.m},
		[14] = {nil, nil, nil, nil, nil, nil, nil, nil, b.y, b.g},
		[15] = {b.G, b.B, nil, nil, nil, nil, nil, nil, nil, nil},
		[16] = {b.r, b.O, nil, nil, nil, nil, nil, nil, nil, nil},
		[23] = {nil, nil, nil, nil, b.C, b.M, nil, nil, nil, nil},
		[24] = {nil, nil, nil, nil, b.R, b.Y, nil, nil, nil, nil},
	},
	[24] = {
		[20] = {b.g, b.g, b.g, b.g, b.G, nil, nil, nil, nil, nil},
		[21] = {nil, nil, nil, nil, nil, b.O, b.y, b.y, b.y, b.Y},
		[23] = {b.M, b.r, b.r, b.r, b.R, nil, nil, nil, nil, nil},
		[24] = {nil, nil, nil, nil, nil, b.M, b.r, b.r, b.r, b.R},
	},
	[25] = {
		[18] = {nil, nil, nil, nil, nil, b.B, nil, nil, nil, nil},
		[19] = {nil, nil, nil, b.G, nil, nil, nil, b.C, nil, nil},
		[20] = {nil, nil, nil, nil, nil, b.Y, nil, nil, nil, nil},
		[21] = {nil, nil, nil, b.M, nil, nil, nil, b.O, nil, nil},
		[22] = {nil, nil, nil, nil, nil, b.R, nil, nil, nil, nil},
	},
	[26] = {
		[13] = {nil, nil, nil, nil, b.r, b.r, nil, nil, nil, nil},
		[14] = {nil, nil, nil, nil, b.o, b.o, nil, nil, nil, nil},
		[15] = {nil, nil, nil, nil, b.o, b.o, nil, nil, nil, nil},
		[16] = {nil, nil, nil, nil, b.o, b.o, nil, nil, nil, nil},
		[17] = {nil, nil, nil, b.O, b.o, b.o, b.Y, nil, nil, nil},
		[18] = {nil, nil, b.o, b.c, b.c, b.c, b.c, b.o, nil, nil},
		[19] = {nil, nil, b.o, b.c, b.c, b.c, b.c, b.o, nil, nil},
		[20] = {nil, nil, b.o, nil, nil, b.G, nil, b.o, nil, nil},
		[21] = {nil, nil, b.o, nil, b.M, b.R, nil, b.o, nil, nil},
		[22] = {nil, nil, b.o, b.b, b.b, b.b, b.B, b.o, nil, nil},
		[23] = {nil, nil, b.o, b.C, b.b, b.b, b.b, b.o, nil, nil},
		[24] = {nil, nil, b.o, b.o, b.o, b.o, b.o, b.o, nil, nil},
	},
	[27] = {
		[15] = {nil, b.C, b.o, b.g, b.g, b.g, b.g, b.g, b.B, nil},
		[16] = {b.g, nil, b.y, b.o, b.g, b.g, b.g, b.g, nil, b.y},
		[17] = {b.g, b.g, nil, b.y, b.o, b.g, b.g, nil, b.y, b.o},
		[18] = {b.g, b.g, b.g, nil, b.y, b.o, nil, b.y, b.o, b.g},
		[19] = {b.g, b.g, b.g, b.o, nil, b.G, b.y, b.o, b.g, b.g},
		[20] = {b.g, b.g, b.o, b.o, b.Y, nil, b.o, b.g, b.g, b.g},
		[21] = {b.g, b.o, b.y, nil, b.o, b.O, nil, b.g, b.g, b.g},
		[22] = {b.o, b.y, nil, b.g, b.g, b.o, b.y, nil, b.g, b.g},
		[23] = {b.y, nil, b.g, b.g, b.g, b.g, b.o, b.y, nil, b.g},
		[24] = {nil, b.M, b.g, b.g, b.g, b.g, b.g, b.o, b.R, nil},
	},
}

local STAGE_TRANSITION_TIME = 300

function SakuraGame:new(secret_inputs)
	self.super:new()

	self.randomizer = (
		(
			secret_inputs.rotate_left and secret_inputs.rotate_right
		) and History6RollsRandomizer() or SakuraRandomizer()
	)
	for key, value in pairs(secret_inputs) do
		if value == true and key ~= "rotate_left" and key ~= "rotate_right" then
			self.secret_erasure = true
		end
	end

	self.current_map = 1
	self.time_limit = 10800
	self.cleared_frames = STAGE_TRANSITION_TIME
	self.stage_frames = 0
	self.time_extend = 0
	self.time_penalty = 0
	self.skip_delay = 3
	self.maps_cleared = 0
	self.map_20_time = 0
	self.stage_pieces = 0
	self.mirror_time = 0
	self.skip_hold_time = 0
	self.flash_frames = 0
	self.grid:applyMap(maps[self.current_map])

	self.lock_drop = true
	self.lock_hard_drop = true
	self.enable_hold = true
	self.next_queue_length = 3
end

function SakuraGame:checkRequirements()
	if self.maps_cleared >= 14 + 2 * (self.current_map - 20) and
	self.map_20_time <= frameTime(8,00) - frameTime(0,30) * (self.current_map - 20)
	then
		return false
	end
	return true
end

function SakuraGame:getGravity()
	if self.level < 8   then return 4/256
elseif self.level < 19  then return 5/256
elseif self.level < 35  then return 6/256
elseif self.level < 40  then return 8/256
elseif self.level < 50  then return 10/256
elseif self.level < 60  then return 12/256
elseif self.level < 70  then return 16/256
elseif self.level < 80  then return 32/256
elseif self.level < 90  then return 48/256
elseif self.level < 100 then return 64/256
elseif self.level < 108 then return 4/256
elseif self.level < 119 then return 5/256
elseif self.level < 125 then return 6/256
elseif self.level < 131 then return 8/256
elseif self.level < 139 then return 12/256
elseif self.level < 149 then return 32/256
elseif self.level < 156 then return 48/256
elseif self.level < 164 then return 80/256
elseif self.level < 174 then return 112/256
elseif self.level < 180 then return 128/256
elseif self.level < 200 then return 144/256
elseif self.level < 212 then return 16/256
elseif self.level < 221 then return 48/256
elseif self.level < 232 then return 80/256
elseif self.level < 244 then return 112/256
elseif self.level < 256 then return 144/256
elseif self.level < 267 then return 176/256
elseif self.level < 277 then return 192/256
elseif self.level < 287 then return 208/256
elseif self.level < 295 then return 224/256
elseif self.level < 300 then return 240/256
else return 20 end
end

function SakuraGame:onLineClear(cleared_row_count)
	self.level = self.level + cleared_row_count
	for i = 13, 24 do
		for j = 1, 10 do
			local block = self.grid.grid[i][j]
			if block and block.skin == "gem" and block.colour == "X" then
				self.time_limit = self.time_limit + 60
			end
		end
	end
end

function SakuraGame:onPieceEnter()
	if self.level % 100 ~= 99 and not self.clear and self.stage_frames ~= 0 then
		self.level = self.level + 1
	end
	if effects[self.current_map] == "mirror" and self.stage_pieces % 3 == 0 and self.stage_pieces ~= 0 then
		self.mirror_time = 30
		-- self.grid:mirror()
	end
	self.stage_pieces = self.stage_pieces + 1
	self.skip_delay = 3
end

function SakuraGame:advanceOneFrame(inputs, ruleset)
	local has_gem_blocks = self.grid:hasGemBlocks()
	if inputs.generic_1 and not self.skipped and has_gem_blocks and self.current_map <= 20 then
		self.skip_hold_time = self.skip_hold_time + 1
		if self.skip_hold_time >= 90 and self.time_limit > frameTime(0,30) then
			self.skipped = true
			self.time_extend = 0
			self.time_penalty = frameTime(0,30)
		end
	else
		self.skip_hold_time = 0
	end
	self.flash_frames = self.flash_frames + 1
	if self.ready_frames == 0 then
		if self.mirror_time > 0 then
			self.mirror_time = self.mirror_time - 1
			if self.mirror_time == 0 then
				self.grid:mirror()
			end
			return false
		end
		if self.lcd > 0 then
			if     self.stage_frames <= frameTime(0,10) then self.time_extend = 600
			elseif self.stage_frames <= frameTime(0,20) then self.time_extend = 300
			else self.time_extend = 0 end
		end

		if not has_gem_blocks or 
		(self.skipped and self.skip_delay <= 0) or
		(self.stage_frames >= 3600 and self.piece == nil
		and self.current_map <= 20) then
			self.lcd = 0
			self.are = 0
			if self.stage_frames >= 3600 then self.time_extend = 0 end
			self.piece = nil
			if inputs.generic_1 and not self.prev_inputs.generic_1 then
				self.cleared_frames = 0
				if self.time_extend > 0 then
					self.time_limit = self.time_limit + self.time_extend
					self.time_extend = 0
				end
				if self.time_penalty > 0 then
					self.time_limit = self.time_limit - self.time_penalty
					self.time_penalty = 0
				end
			end
			self.prev_inputs.generic_1 = inputs.generic_1
			-- transition to next map
			if self.cleared_frames > 0 then
				self.cleared_frames = self.cleared_frames - 1
				if self.time_extend > 0 then
					self.time_limit = self.time_limit + 3
					self.time_extend = self.time_extend - 3
				end
				if self.time_penalty > 0 then
					self.time_limit = self.time_limit - 15
					self.time_penalty = self.time_penalty - 15
				end
				return false
			end

			self.hold_queue = nil
			if not has_gem_blocks then self.maps_cleared = self.maps_cleared + 1 end
			self.stage_frames = -1
			self.level = 0
			self.grid:clear()
			if (self.current_map == 20) then self.map_20_time = self.frames end
			if self.current_map >= 20 and self:checkRequirements() then
				self.clear = true
				self.completed = true
				return false
			else
				self.current_map = self.current_map + 1
				self.big_mode = effects[self.current_map] == "big"
				self.half_block_mode = effects[self.current_map] == "big"
				self.ready_frames = 100
				self.stage_pieces = 0
				self.grid:applyMap(maps[self.current_map])
			end
			self.skipped = false

			-- this is necessary to fix timer
			self.frames = self.frames - 1
			self.time_limit = self.time_limit + 1
		end

		self.frames = self.frames + 1
		self.stage_frames = self.stage_frames + 1
		self.time_limit = math.max(self.time_limit - 1, 0)
		if self.time_limit <= 0 and self.piece == nil then
			self.game_over = true
		end

		if self.piece ~= nil then
			self.skip_delay = self.skip_delay - 1
		end
		if self.piece ~= nil and
		   effects[self.current_map] == "roll" and
		   self.stage_pieces % 4 == 0
		   then
			self.piece.colour = "F"
			if self.stage_frames % 30 == 0 then
				ruleset:attemptRotate(
					{[config.gamesettings.world_reverse == 3 or
					(ruleset.world and config.gamesettings.world_reverse == 2)
					and "rotate_left" or "rotate_right"] = true},
					self.piece, self.grid, false
				)
			end
		end
	else
		self.cleared_frames = STAGE_TRANSITION_TIME
		if not self.prev_inputs.hold and inputs.hold then
			playSE("ihs")
			self.hold_queue = table.remove(self.next_queue, 1)
			table.insert(self.next_queue, self:getNextPiece(ruleset))
		end
	end
	return true
end

function SakuraGame:onGameComplete() end

function SakuraGame:getStageString()
	if self.current_map > 20 then
		return "EX STAGE ".. self.current_map - 20
	else
		return "STAGE " .. self.current_map
	end
end

function SakuraGame:getStageShort()
	
	if self.current_map > 20 then
		return "EX".. self.current_map - 20
	else
		return tostring(self.current_map)
	end
end

local function colourXRay(game, block, x, y, age)
	local r, g, b, a = .5,.5,.5
	if ((game.stage_frames - x) % 60 < 1)
	or game.stage_frames == 0
	or game.cleared_frames ~= STAGE_TRANSITION_TIME
	or game.stage_pieces % 2 == 0
	then
		a = 1
	else
		a = 1 - age / 4
	end
	return r, g, b, a, a
end

local function colourColor(game, block, x, y, age)
	local r, g, b, a = .5,.5,.5
	if game.stage_frames == 0 or game.cleared_frames ~= STAGE_TRANSITION_TIME then
		a = 1
	else
		a = (game.stage_frames/30 + ((24-y) + math.abs(x-5.5))/10) % 1
	end
	return r, g, b, a, 0
end

local function lerp(a,b,t) return a * (1-t) + b * t end
function SakuraGame:drawGrid()
	if self.mirror_time > 0 then
		--custom grid draw method
		local grid = self.grid
		for y = 5, grid.height do
			for x = 1, grid.width do
				if blocks[grid.grid[y][x].skin] and blocks[grid.grid[y][x].skin][grid.grid[y][x].colour] then
					local lerp_x = lerp(x*16, 176-x*16, math.min(math.max(1 - self.mirror_time / 15, 0), 1))
					love.graphics.setColor(0.5, 0.5, 0.5, 1)
					drawSizeIndependentImage(blocks[grid.grid[y][x].skin][grid.grid[y][x].colour], 48+lerp_x, y*16, 0, 16, 16)
				end
			end
		end
	elseif effects[self.current_map] == "xray" then
		self.grid:drawCustom(colourXRay, self)
	elseif effects[self.current_map] == "color" then
		self.grid:drawCustom(colourColor, self)
	else
		self.grid:draw()
	end
	if self.piece ~= nil and self.level < 100 then
		self:drawGhostPiece()
	end
end

function SakuraGame:drawScoringInfo()
	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setFont(font_3x5)
	love.graphics.print(
		self.das.direction .. " " ..
		self.das.frames .. " " ..
		strTrueValues(self.prev_inputs)
	)

	love.graphics.setFont(font_3x5_2)
	love.graphics.printf("NEXT", 64, 40, 40, "left")
	love.graphics.printf("STAGE", 240, 120, 80, "left")
	love.graphics.printf("TIME LIMIT", 240, 180, 80, "left")
	love.graphics.printf("LEVEL", 240, 320, 40, "left")
	if self.current_map <= 20 then
		love.graphics.printf("STAGE LIMIT", 240, 240, 100, "left")
	end
	if effects[self.current_map] then
		love.graphics.printf("EFFECT: " .. effects[self.current_map], 240, 300, 160, "left")
	end
	if self.used_randomizer.history then
		love.graphics.printf("RANDOM PIECES ACTIVE!", 240, 150, 200, "left")
	end

	love.graphics.setFont(font_3x5_3)
	love.graphics.setColor(
		(self.flash_frames % 4 < 2 and
		self.time_limit <= frameTime(0,10) and
		self.cleared_frames == STAGE_TRANSITION_TIME and
		self.time_limit ~= 0 and
		self.ready_frames == 0) and
		{ 1, 0.3, 0.3, 1 } or
		{ 1, 1, 1, 1 }
	)
	love.graphics.printf(formatTime(self.time_limit), 240, 200, 120, "left")
	love.graphics.setColor(1, 1, 1, 1)
	if self.current_map <= 20 then
		love.graphics.printf(formatTime(3600 - self.stage_frames), 240, 260, 120, "left")
	end
	love.graphics.printf(self.level, 240, 340, 40, "right")
	love.graphics.printf(math.floor((self.level + 100) / 100) * 100, 240, 370, 40, "right")

	love.graphics.setFont(font_8x11)
	love.graphics.printf(formatTime(self.frames), 64, 420, 160, "center")
	love.graphics.printf(self:getStageShort(), 290, 110, 80, "left")
end

function SakuraGame:drawCustom()
	love.graphics.setColor(1, 1, 1, 1)

	if self.ready_frames ~= 0 and not self.clear then
		love.graphics.setFont(font_3x5_4)
		love.graphics.printf(self:getStageString(), 64, 170, 160, "center")

		love.graphics.setFont(font_3x5_3)
		if effects[self.current_map] then
			love.graphics.printf("EFFECT: " .. effects[self.current_map], 64, 270, 160, "center")
		end
	end

	if self.skipped and self.skip_delay <= 0 then
		love.graphics.setFont(font_3x5_2)
		love.graphics.printf("Clear %", 64, 320, 160, "center")
		love.graphics.setFont(font_3x5_3)
		love.graphics.printf(self:getStageString(), 64, 120, 160, "center")
		love.graphics.printf("STAGE SKIP", 64, 170, 160, "center")
		love.graphics.printf("PENALTY", 64, 240, 160, "center")
		love.graphics.printf("-30 SEC", 64, 280, 160, "center")
		local percentage = math.floor(100 * self.maps_cleared / self.current_map)
		love.graphics.printf(percentage.."%", 64, 340, 160, "center")

	elseif self.cleared_frames > 0 and
	(not self.grid:hasGemBlocks() or
	(self.stage_frames >= 3600 and self.piece == nil
	and self.current_map <= 20)) then
		love.graphics.setFont(font_3x5_2)
		love.graphics.printf("TIME LIMIT", 64, 180, 160, "center")
		love.graphics.printf("TIME EXTEND", 64, 240, 160, "center")
		love.graphics.printf("STAGE TIME", 64, 300, 160, "center")

		love.graphics.setFont(font_3x5_3)
		love.graphics.printf(self:getStageString(), 64, 100, 160, "center")
		love.graphics.setColor(
			self.cleared_frames % 4 < 2 and
			{ 1, 1, 0.3, 1 } or
			{ 1, 1, 1, 1 }
		)
		love.graphics.printf(formatTime(self.time_limit), 64, 200, 160, "center")
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.printf(formatTime(self.time_extend), 64, 260, 160, "center")
		love.graphics.printf(formatTime(self.stage_frames), 64, 320, 160, "center")

		love.graphics.setFont(font_3x5_4)
		love.graphics.printf((self.stage_frames >= 3600 and self.current_map <= 20) and "" or "CLEAR!", 64, 130, 160, "center")
	end

	if self.clear then
		love.graphics.setFont(font_3x5_3)
		love.graphics.printf("EXCELLENT!", 64, 180, 160, "center")

		love.graphics.setFont(font_3x5_2)
		if self.current_map ~= 27 and self.game_over_frames > 300 then
			love.graphics.printf("...but let's go\nbetter next time", 64, 220, 160, "center")
		end
	end
end

function SakuraGame:getBackground()
	return math.floor(self.level / 100)
end

function SakuraGame:getHighscoreData()
	return {
		maps = self.maps_cleared,
		current_map = self.current_map,
		frames = self.frames,
	}
end

return SakuraGame