local ExitScene = Scene:extend()
require 'load.save'

ExitScene.title = "Exit Game"

function ExitScene:new()
	love.event.quit()
end

function ExitScene:update()
	love.event.quit()
end

function ExitScene:render()
end

function ExitScene:changeOption(rel)
end

function ExitScene:onInputPress(e)
end

return ExitScene

