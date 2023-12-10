local assets = require("assets")
local interfaceManager = require("ui.interfaceManager")
local gameUi = {}

function gameUi:load()
    self.hud = interfaceManager:newCanvas()
    self.hud:newImage(assets.images.player.body, {400, 400}, {1,1}, 0)
end

function gameUi:update()

end

function gameUi:draw()
    
end

return gameUi