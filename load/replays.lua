---@type love.Thread
local io_thread

loaded_replays = false

function loadReplayList()
	replays = {}
	replay_tree = {{name = "All"}}
	dict_ref = {}
	loaded_replays = false
	collectgarbage("collect")

	--proper disposal to avoid some memory problems
	if io_thread then
		io_thread:release()
		love.thread.getChannel( 'replay' ):clear()
		love.thread.getChannel( 'loaded_replays' ):clear()
	end

	io_thread = love.thread.newThread( replay_load_code )
	for key, value in pairs(recursionStringValueExtract(game_modes, "is_directory")) do
		if not dict_ref[value.name] then
			dict_ref[value.name] = #replay_tree + 1
			replay_tree[#replay_tree + 1] = {name = value.name}
		end
	end
	io_thread:start()
end

function insertReplay(replay)
	for key, value in pairs(replay) do
		replay[key] = toFormattedValue(value)
	end
	if replay.highscore_data then
		for key, value in pairs(replay.highscore_data) do
			replay.highscore_data[key] = toFormattedValue(value)
		end
	end
	local mode_name = replay.mode
	replays[#replays+1] = replay
	if dict_ref[mode_name] ~= nil and mode_name ~= "znil" then
		table.insert(replay_tree[dict_ref[mode_name] ], #replays)
	end
	local branch_index = 0
	for index, value in ipairs(replay_tree) do
		if value.name == "All" then
			branch_index = index
			break
		end
	end
	table.insert(replay_tree[branch_index], #replays)
end

function refreshReplayTree()
	replay_tree = {{name = "All"}}
	dict_ref = {}
	for key, value in pairs(recursionStringValueExtract(game_modes, "is_directory")) do
		if not dict_ref[value.name] then
			dict_ref[value.name] = #replay_tree + 1
			replay_tree[#replay_tree + 1] = {name = value.name}
		end
	end
	for ptr, replay in pairs(replays) do
		local mode_name = replay.mode
		if dict_ref[mode_name] ~= nil and mode_name ~= "znil" then
			table.insert(replay_tree[dict_ref[mode_name] ], ptr)
		end
		local branch_index = 0
		for index, value in ipairs(replay_tree) do
			if value.name == "All" then
				branch_index = index
				break
			end
		end
		table.insert(replay_tree[branch_index], ptr)
	end
	sortReplays()
end

function sortReplays()
	if not replay_tree then return end
	local function padnum(d) return ("%03d%s"):format(#d, d) end
	table.sort(replay_tree, function(a,b)
	return tostring(a.name):gsub("%d+",padnum) < tostring(b.name):gsub("%d+",padnum) end)
	for key, submenu in pairs(replay_tree) do
		table.sort(submenu, function(a, b)
			return replays[a]["timestamp"] > replays[b]["timestamp"]
		end)
	end
end

function disposeReplayThread()
	if io_thread then
		io_thread:release()
	end
end

replay_load_code = [[
	function setState(string)
		print(string)
		love.thread.getChannel( 'load_state' ):clear()
		love.thread.getChannel( 'load_state' ):push(string)
	end
	local function toFormattedValue(value)
	
		if type(value) == "table" and value.digits and value.sign then
			local num = ""
			if value.sign == "-" then
				num = "-"
			end
			for id, digit in pairs(value.digits) do
				if not value.dense or id == 1 then
					num = num .. math.floor(digit) -- lazy way of getting rid of .0$
				else
					num = num .. string.format("%07d", digit)
				end
			end
			return num
		end
		return value
	end
	setState("Loading replay file list")
	local replay_file_list = love.filesystem.getDirectoryItems("replays")
	local binser = require "libs.binser"
	require "funcs"
	setState("Loading replay contents")
	for i=1, #replay_file_list do
		local data = love.filesystem.read("replays/"..replay_file_list[i])
		local success, new_replay = pcall(
			function() return binser.deserialize(data)[1] end
		)
		if new_replay == nil or not success then
			love.filesystem.remove("replays/"..replay_file_list[i])
			print ("The replay at replays/"..replay_file_list[i].." is corrupted or has no data, thus, deleted.")
		else
			for key, value in pairs(new_replay) do
				new_replay[key] = toFormattedValue(value)
			end
			if new_replay.highscore_data then 
				for key, value in pairs(new_replay.highscore_data) do
					new_replay.highscore_data[key] = toFormattedValue(value)
				end
			end
			love.thread.getChannel('replay'):push(new_replay)
		end
	end
	love.thread.getChannel( 'loaded_replays' ):push( true )
	print("Loaded replays.")
]]