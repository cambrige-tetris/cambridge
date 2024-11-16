---@type string[]
local module_sources = {}

---@param tbl table
---@param directory string
---@param blacklisted_string string
function recursivelyLoadRequireFileTable(tbl, directory, blacklisted_string)
	--LOVE 12.0 will warn about require strings having forward slashes in them if this is not done.
	local require_string = string.gsub(directory, "/", ".")
	local list = love.filesystem.getDirectoryItems(directory)
	for index, name in ipairs(list) do
		if love.filesystem.getInfo(directory.."/"..name, "directory") then
			tbl[#tbl+1] = {name = name, is_directory = true}
			recursivelyLoadRequireFileTable(tbl[#tbl], directory.."/"..name, blacklisted_string)
		end
		if name ~= blacklisted_string and name:sub(-4) == ".lua" then
			tbl[#tbl+1] = require(require_string.."."..name:sub(1, -5))
			if not (type(tbl[#tbl]) == "table" and type(tbl[#tbl].__call) == "function") then
				error("Add a return to "..directory.."/"..name..".\nMust be a table with __call function.", 1)
			end
			module_sources[tbl[#tbl]] = love.filesystem.read(directory.."/"..name)
		end
	end
end

---This may return an empty string if a module isn't identified.
function getModuleSource(module)
	return module_sources[module] or ""
end

function unloadModules()
	--module reload.
	module_sources = {}
	for key, value in pairs(package.loaded) do
		if string.sub(key, 1, 7) == "tetris." then
			package.loaded[key] = nil
		end
	end
	collectgarbage("collect")
end

---This shouldn't run more than once on the same table.
---@param init table
function recursivelyTagModules(init, tbl, tag_tbl)
	if not tbl then tbl = init end
	if not tag_tbl then tag_tbl = {} end
	for k, v in pairs(tbl) do
		if type(v) == "table" and v.is_directory == true and not (v.is_tag) then
			recursivelyTagModules(init, v, tag_tbl)
		end
		if type(v) == "table" and type(v.tags) == "table" then
			for k2, v2 in pairs(v.tags) do
				tag_tbl[v2] = tag_tbl[v2] or {name = v2, is_directory = true, is_tag = true}
				table.insert(tag_tbl[v2], v)
			end
		end
	end
	if init ~= tbl then return end

	local sorted_tags = {}
	--#region Sort tag names
	for key, value in pairs(tag_tbl) do
		table.insert(sorted_tags, value)
	end
	local function padnum(d) return ("%03d%s"):format(#d, d) end
	table.sort(sorted_tags, function(a,b)
	return tostring(a.name):gsub("%d+",padnum) < tostring(b.name):gsub("%d+",padnum) end)
	--#endregion

	for key, value in ipairs(sorted_tags) do
		table.insert(init, value)
	end
end

function initModules()
	module_source = {}
	game_modes = {}
	recursivelyLoadRequireFileTable(game_modes, "tetris/modes", "gamemode.lua")
	rulesets = {}
	recursivelyLoadRequireFileTable(rulesets, "tetris/rulesets", "ruleset.lua")

	--sort mode/rule lists
	local function padnum(d) return ("%03d%s"):format(#d, d) end
	table.sort(game_modes, function(a,b)
	return tostring(a.name):gsub("%d+",padnum) < tostring(b.name):gsub("%d+",padnum) end)
	table.sort(rulesets, function(a,b)
	return tostring(a.name):gsub("%d+",padnum) < tostring(b.name):gsub("%d+",padnum) end)
	recursivelyTagModules(game_modes)
	recursivelyTagModules(rulesets)
end
