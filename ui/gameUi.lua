local assets = require("assets")
local interfaceManager = require("ui.interfaceManager")
local gameUi = {}

function gameUi:load()
    self.hud = interfaceManager:newCanvas()
    self.hud:newImage(assets.images.ui.healthBar, {97, 465}, {2.35,2.35}, 0, "x+")
    --Health counter
    self.hud.healthText = self.hud:newTextLabel(
        "100", {50, 495}, 40, "x+", "left", "bedstead-bold", {1,1,1,1}
    )
    --Armor counters
    self.hud.armorText = self.hud:newTextLabel(
        "100", {44, 452}, 25, "x+", "left", "bedstead-bold", {1,1,1,1}
    )
end

function gameUi:update()

end

function gameUi:draw()
    
end

return gameUi