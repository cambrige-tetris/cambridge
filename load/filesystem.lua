local binser = require 'libs.binser'

---@param filename string
---@param backup boolean|nil
function loadFromFile(filename, backup)
	local file_data = love.filesystem.read(filename)
	if file_data == nil then
		--Gets backup just in case.
		file_data = love.filesystem.read(filename..".backup")
		-- if no backup
		if file_data == nil then
			return {} -- new object
		end
	end
	local result, save_data = pcall(binser.deserialize, file_data)
	if result == false or save_data == nil then
		return {} -- new object
	elseif backup == true then
		love.filesystem.write(filename..".backup", file_data) -- backup creation if sucessful
	end
	return save_data[1]
end

function saveToFile(filename, data)
	local is_successful, message = love.filesystem.write(filename..".tmp", data) --temporary file.
	assert(is_successful, "Failed to save file: "..filename..". Error message: "..(message or "nil"))
	love.filesystem.remove(filename..".tmp") --cleanup.
	assert(love.filesystem.write(filename, data))
end

function copyFile(source_path, destination_path)
	local file = love.filesystem.read(source_path)
	assert(love.filesystem.write(destination_path, file))
end

---@param source_directory string
---@param destination_directory string
---@param override_warning boolean
function copyDirectoryRecursively(source_directory, destination_directory, override_warning)
	local directory_items = love.filesystem.getDirectoryItems(source_directory)
	if not love.filesystem.getInfo(destination_directory, "directory") then
		love.filesystem.createDirectory(destination_directory)
	end
	for _, path in pairs(directory_items) do
		local source_path = source_directory.."/"..path
		local destination_path = destination_directory.."/"..path
		if love.filesystem.getInfo(source_path, "directory") then
			copyDirectoryRecursively(source_path, destination_path, override_warning)
		end
		if love.filesystem.getInfo(source_path, "file") then
			local msgbox_choice = 2
			if love.filesystem.getInfo(destination_path, "file") and override_warning then
				msgbox_choice = love.window.showMessageBox(love.window.getTitle(), "This file ("..path..") already exists! Do you want to override it?", {"No", "Yes", }, "info", false)
			end
			if msgbox_choice == 2 then
				copyFile(source_path, destination_path)
			end
		end
	end
end
