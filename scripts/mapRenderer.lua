local assets = require("assets")
local coreFuncs = require("coreFuncs")
local weaponItem = require("scripts.weaponItem")

local mapRenderer = {
    weaponItems = {};
}

function mapRenderer:load()
    self.weaponItems[#self.weaponItems+1] = weaponItem.new()
end

function mapRenderer:update()
    if GamePaused then return end
end

function mapRenderer:draw()
    --Placeholder tile
    local src = assets.images.tiles.prototypeGreen
    local width = src:getWidth() ;  local height = src:getHeight()
    local pos = coreFuncs.getRelativePosition({0,0}, Camera)
    love.graphics.draw(
        src, pos[1], pos[2], self.rotation,
        2*Camera.zoom, 2*Camera.zoom, width/2, height/2
    )
    --Weapon items
    for i, v in ipairs(self.weaponItems) do
        v:draw()
    end
end

return mapRenderer