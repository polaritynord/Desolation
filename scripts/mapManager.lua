local assets = require("assets")
local coreFuncs = require("coreFuncs")
local weaponItem = require("scripts.weaponItem")
local player = require("scripts.player")
local camera = require("scripts.camera")


local mapRenderer = {
    humanoids = {};
    props = {};
    tiles = {};
    weaponItems = {};
}

function mapRenderer:load()
    Player = player.new()
    self.humanoids[#self.humanoids+1] = Player
    Camera = camera.new()
    Player:load()
    --self.weaponItems[#self.weaponItems+1] = weaponItem.new()
end

function mapRenderer:update(delta)
    if GamePaused then return end
    --Humanoids
    for _, v in ipairs(self.humanoids) do
        v:update(delta)
    end

    --Weapon items
    for _, v in ipairs(self.weaponItems) do
        v:update(delta)
    end
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
    for _, v in ipairs(self.weaponItems) do
        v:draw()
    end

    --Humanoids
    for _, v in ipairs(self.humanoids) do
        v:draw()
    end
end

return mapRenderer