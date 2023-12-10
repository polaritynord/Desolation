local assets = require("assets")
local interfaceManager = require("ui.interfaceManager")
local gameUi = {}

function gameUi:load()
    self.hud = interfaceManager:newCanvas()
    self.hud:newImage(assets.images.ui.healthBar, {97, 465}, {2.35,2.35}, 0, "x+")
end

function gameUi:update()

end

function gameUi:draw()
    
end

return gameUi