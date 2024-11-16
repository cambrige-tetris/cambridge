local FuncScene = Scene:extend()

FuncScene.title = "Report Bugs"

function FuncScene:new()
	self.prev_scene = scene
	love.system.openURL("https://github.com/cambridge-stacker/cambridge/issues")
end

function FuncScene:update()
	scene = self.prev_scene
end

function FuncScene:render()
end

function FuncScene:changeOption(rel)
end

function FuncScene:onInputPress(e)
end
return FuncScene