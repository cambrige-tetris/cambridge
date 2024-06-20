---@return any
function copy(t)
	-- returns top-layer shallow copy of t
	if type(t) ~= "table" then return t end
	local target = {}
	for k, v in next, t do target[k] = v end
	setmetatable(target, getmetatable(t))
	return target
end

---@return any
function deepcopy(t)
    -- returns infinite-layer deep copy of t
	if type(t) ~= "table" then return t end
	local target = {}
	for k, v in next, t do
		target[deepcopy(k)] = deepcopy(v)
	end
	setmetatable(target, deepcopy(getmetatable(t)))
	return target
end

---@param tbl table
function strTrueValues(tbl)
	-- returns a concatenation of all the keys in tbl with value true, separated with spaces
	local str = ""
	for k, v in pairs(tbl) do
		if v == true then
			str = str .. k .. " "
		end
	end
	return str
end

---@param min integer
---@param sec integer|nil
---@param hth integer|nil
function frameTime(min, sec, hth)
	-- returns a time in frames from a time in minutes-seconds-hundredths format
	if min == nil then min = 0 end
	if sec == nil then sec = 0 end
	if hth == nil then hth = 0 end
	return min*3600 + sec*60 + math.ceil(hth * 0.6)
end

---@param v1 table
---@param v2 table
function vAdd(v1, v2)
	-- returns the sum of vectors v1 and v2
	return {
		x = v1.x + v2.x,
		y = v1.y + v2.y
	}
end

---@param v table
function vNeg(v)
	-- returns the opposite of vector v
	return {
		x = -v.x,
		y = -v.y
	}
end

---@param frames number
function formatTime(frames)
	-- returns a mm:ss:hh (h=hundredths) representation of the time in frames given 
	if frames < 0 then return formatTime(0) end
	local min, sec, hund
	min  = math.floor(frames/3600)
	sec  = math.floor(frames/60) % 60
	hund = math.floor(frames/.6) % 100
	if frames == 15641 then
		hund = math.ceil(frames/.6) % 100
	end
	local str = string.format("%02d:%02d.%02d", min, sec, hund)
	return str
end

function formatBigNum(number)
	-- returns a string representing a number with commas as thousands separator (e.g. 12,345,678)
	local s
	if type(number) == "number" then
		s = string.format("%d", number)
	elseif type(number) == "string" then
		if not tonumber(number) then
			return
		else
			s = number
		end
	else
		return
	end
	local pos = Mod1(string.len(s), 3)
	return string.sub(s, 1, pos)
		.. string.gsub(string.sub(s, pos+1), "(...)", ",%1")
end

---@param n number
---@param m number
function Mod1(n, m)
	-- returns a number congruent to n modulo m in the range [1;m] (as opposed to [0;m-1])
	return ((n-1) % m) + 1
end

---@param table table
---@param element any
---@return boolean
function table.contains(table, element)
	for _, value in pairs(table) do
	  	if value == element then
			return true
	  	end
	end
	return false
end

---@param table table
---@return table
function table.keys(table)
	local target = {}
	for key in pairs(table) do
		target[#target+1] = key
	end
	return target
end

---@param table table
function table.numkeys(table)
	local count = 0
	for k in pairs(table) do
		count = count + 1
	end
	return count
end

function equals(x, y)
	if type(x) ~= "table" or type(y) ~= "table" then
		return x == y
	else
		for k in pairs(x) do
			if not equals(x[k], y[k]) then return false end
		end
		for k in pairs(y) do
			if not equals(x[k], y[k]) then return false end
		end
		return true
	end
end

function table.equalvalues(t1, t2)
	if table.numkeys(t1) ~= table.numkeys(t2) then
		return false
	else
		for _, v in pairs(t2) do
			if not table.contains(t1, v) then return false end
		end
		return true
	end
end

---@param x number
---@param min number
---@param max number
function clamp(x, min, max)
	if max < min then
		min, max = max, min
	end
	return x < min and min or (x > max and max or x)
end


---@param image love.Texture
---@param origin_x integer
---@param origin_y integer
---@param draw_width integer
---@param draw_height integer
function drawSizeIndependentImage(image, origin_x, origin_y, r, draw_width, draw_height, offset_x, offset_y, ...)
	offset_x = offset_x or 0
	offset_y = offset_y or 0
	local width, height = image:getDimensions()
	local width_scale_factor = width / draw_width
	local height_scale_factor = height / draw_height
	love.graphics.draw(image, origin_x, origin_y, r, 1/width_scale_factor, 1/height_scale_factor, offset_x*width_scale_factor, offset_y*height_scale_factor, ...)
end

---@param h number
---@param s number
---@param v number
function HSVToRGB(h, s, v)
    if s <= 0 then return v,v,v end
    h = h*6
    local c = v*s
    local x = (1-math.abs((h%2)-1))*c
    local m,r,g,b = (v-c), 0, 0, 0
    if h < 1 then
        r, g, b = c, x, 0
    elseif h < 2 then
        r, g, b = x, c, 0
    elseif h < 3 then
        r, g, b = 0, c, x
    elseif h < 4 then
        r, g, b = 0, x, c
    elseif h < 5 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end
    return r+m, g+m, b+m
end

---@param string string
function rainbowString(string)
	local tbl = {}
	local char = ''
    for i = 1, #string do
        char = string.char(string:byte(i)) or ' '
		local r, g, b = HSVToRGB(((love.timer.getTime() / 4) + i / #string) % 1, 1, 1)
		-- print(r, g, b, a, (love.timer.getTime() + i / 20) % 1)
		table.insert(tbl, {r, g, b, 1})
		table.insert(tbl, char)
    end
	return tbl
end

---@param tbl table
---@param key_check any
---@return table
function recursionStringValueExtract(tbl, key_check)
	local result = {}
	for key, value in pairs(tbl) do
		if type(value) == "table" and (key_check == nil or value[key_check]) then
			local recursion_result = recursionStringValueExtract(value, key_check)
			for k2, v2 in pairs(recursion_result) do
				table.insert(result, v2)
			end
		elseif tostring(value) == "Object" then
			table.insert(result, value)
		end
	end
	return result
end
-- For when you need to convert given coordinate to where it'd be in scaled 640x480 equivalent.
---@param x number
---@param y number
function getScaledDimensions(x, y, screen_x, screen_y)
	if screen_x == nil or screen_y == nil then
		screen_x, screen_y = love.graphics.getDimensions()
	end
	local scale_factor = math.min(screen_x / 640, screen_y / 480)
	return	(x - (screen_x - scale_factor * 640) / 2) / scale_factor,
			(y - (screen_y - scale_factor * 480) / 2) / scale_factor
end

---@param x number
---@param y number
---@param w number
---@param h number
---@return integer
function cursorHighlight(x,y,w,h)
	if mouse_idle > 2 or config.visualsettings.cursor_highlight ~= 1 then
		return 1
	end
	if cursorHoverArea(x,y,w,h) then
		setSystemCursorType("hand")
		return 0
	else
		return 1
	end
end

---@param x number
---@param y number
---@param w number
---@param h number
---@return boolean
function cursorHoverArea(x,y,w,h)
	local mouse_x, mouse_y = getScaledDimensions(love.mouse.getPosition())
	return (mouse_x > x and mouse_x < x+w and mouse_y > y and mouse_y < y+h)
end

---@param a number
---@param b number
---@param t number
---@return number
function math.lerp(a, b, t)
	return a + (b - a) * t
end

---@param a number
---@param b number
---@param decay number
---@param dt number
---@return number
function expDecay(a, b, decay, dt)
	return b+(a-b)*math.exp(-decay*dt)
end

---Interpolates using expDecay if Smooth Scrolling option is enabled in visual settings.
---@param a number
---@param b number
---@return number
function interpolateNumber(a, b, decay, dt)
	if config.visualsettings["smooth_scroll"] == 2 then
		return b
	end
	-- higher -> faster
	decay = decay or 17.260924347109
	dt = dt or love.timer.getDelta()
	return expDecay(a, b, decay, dt)
end

---note: if you input just a string here, it'll output an input. it ignores tables within input table
---@param text table|string
local function getStringFromTable(text)
	if type(text) == "string" then
		return text
	end
	local str_out = ""
	for _, value in ipairs(text) do
		if type(value) == "string" then
			str_out = str_out .. value
		end
	end
	return str_out
end

---Strings with newlines are not recommended
---@param text string|table
---@param x number
---@param y number
---@param limit number
---@param align "center"|"justify"|"left"|"right"
function drawWrappingText(text, x, y, limit, align, ...)
	local cur_font = love.graphics.getFont()
	local text_str = getStringFromTable(text)
	local string_width = cur_font:getWidth(text_str)
	local offset_x = 0
	if string_width > limit then
		local new_canvas = love.graphics.newCanvas(limit, cur_font:getHeight())
		local max_offset = string_width - limit + 4
		offset_x = (0.5 + clamp(math.sin(love.timer.getTime() / (1 + max_offset / 250)) * 2, -1, 1) / 2) * max_offset
		love.graphics.push("all")
		love.graphics.origin()
		love.graphics.setLineWidth(2)
		love.graphics.setCanvas(new_canvas)
		love.graphics.printf(text, -offset_x, 0, math.max(string_width, limit), align)
		if offset_x > 0 then
			love.graphics.line(1, 0, 1, cur_font:getHeight())
		end
		if offset_x < max_offset then
			love.graphics.line(limit - 1, 0, limit - 1, cur_font:getHeight())
		end
		love.graphics.pop()
		love.graphics.draw(new_canvas, x, y, ...)
		new_canvas:release()
	else
		love.graphics.printf(text, x, y, limit, align, ...)
	end
end

---@param input number
---@param edge_distance number
---@param edge_width number
---@return number
function fadeoutAtEdges(input, edge_distance, edge_width)
	input = math.abs(input)
	if input > edge_distance then
		return 1 - (input - edge_distance) / edge_width
	end
	return 1
end
function toFormattedValue(value)
	
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

---@param str string
function stringWrapByLength(str, len)
	local new_str = ""
	if #str > len then
		for i = 1, math.ceil(#str / len) do
			new_str = new_str .. str:sub((i-1)*len+1, i*len+1).."\n"
		end
	else
		return str
	end
	return new_str
end

function displayReplayInfoBox(replay_data)
	local info_string = "Replay file view:\n"
	info_string = info_string .. "Mode: " .. replay_data["mode"] .. " (" .. (replay_data["mode_hash"] or "???") .. ")\n"
	info_string = info_string .. "Ruleset: " .. replay_data["ruleset"] .. " (" .. (replay_data["ruleset_hash"] or "???") .. ")\n"
	info_string = info_string .. os.date("Timestamp: %c\n", replay_data["timestamp"])
	if replay_data.cambridge_version then
		if replay_data.cambridge_version ~= version then
			info_string = info_string .. "Warning! The versions don't match!\nStuff may break, so, start at your own risk.\n"
		end
		info_string = info_string .. "Cambridge version for this replay: "..replay_data.cambridge_version.."\n"
	end
	if replay_data.pause_count and replay_data.pause_time then
		info_string = info_string .. ("Pause count: %d\nTime Paused: %s\n"):format(replay_data.pause_count, formatTime(replay_data.pause_time))
	end
	if replay_data.sha256_table then
		info_string = info_string .. ("SHA256 replay hashes:\nMode: %s\nRuleset: %s\n"):format(replay_data.sha256_table.mode, replay_data.sha256_table.ruleset)
	end
	if replay_data.highscore_data then
		info_string = info_string .. "In-replay highscore data:\n\n"
		for key, value in pairs(replay_data["highscore_data"]) do
			info_string = info_string .. stringWrapByLength((key..": ".. toFormattedValue(value)), 75) .. "\n"
		end
	else
		info_string = info_string .. "Legacy replay\nLevel: "..replay_data["level"]
	end
	love.window.showMessageBox(love.window.getTitle(), info_string, "info")
end

--alias functions
interpolatePos = interpolateNumber
getScaledPos = getScaledDimensions
