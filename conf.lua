function love.conf(t)
	t.identity = "cambridge"

	t.console = true

	t.window.title = "Cambridge"
	t.window.width = 640
	t.window.height = 480
	t.window.icon = "res/img/cambridge_icon.png"
	t.window.vsync = false
	t.window.resizable = true

	---for mobile systems
	t.externalstorage = true
end
