local font_3x5_glyphs = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_" ..
	"`abcdefghijklmnopqrstuvwxyz{|}~™АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя"
local font_8x11_glyphs = " 0123456789:;.,ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz?!/\\^@$%<=>()*-+[]_&"

custom_fonts = {}

function loadFont(filename, glyphs, ...)
	if applied_packs_path and type(filename) == "string" and love.filesystem.getInfo(applied_packs_path..filename) then
		filename = applied_packs_path..filename
	end
	return love.graphics.newImageFont(filename, glyphs, ...)
end

function loadStandardFonts()
	font_3x5 = loadFont(
		"res/fonts/3x5-ext.png",
		font_3x5_glyphs,
		-1
	)

	font_3x5_2 = loadFont(
		"res/fonts/3x5_double-ext.png",
		font_3x5_glyphs,
		-2
	)

	font_3x5_3 = loadFont(
		"res/fonts/3x5_medium-ext.png",
		font_3x5_glyphs,
		-3
	)

	font_3x5_4 = loadFont(
		"res/fonts/3x5_large-ext.png",
		font_3x5_glyphs,
		-4
	)

	-- this would be font_8x11 with the other one as 8x11_2
	-- but that would break compatibility :(
	font_8x11_small = loadFont(
		"res/fonts/8x11.png",
		font_8x11_glyphs,
		1
	)

	font_8x11 = loadFont(
		"res/fonts/8x11_medium.png",
		font_8x11_glyphs,
		1
	)
end
loadStandardFonts()