local object = require("engine.object")
local itemScript = require("desolation.components.item.item_script")
local itemUpdateFuncs = require("desolation.components.item.item_event_funcs")
local json = require("engine.lib.json")

local mapCreator = ENGINE_COMPONENTS.scriptComponent.new()

function mapCreator:loadMap(path)
    local creator = self.parent
    --read & convert to lua table
    local data = love.filesystem.read(path)
    data = json.decode(data)
    creator.mapData = {tiles={}}
    --load tiles
    if data.tiles ~= nil then
        for _, v in ipairs(data.tiles) do
            local tile = object.new(CurrentScene.tiles)
            --maybe set name?
            tile.imageComponent = ENGINE_COMPONENTS.imageComponent.new(tile, Assets.images.tiles[v[1]])
            tile.imageComponent.layer = 3
            tile.scale = {2, 2}
            tile.position = {v[2]*1024, v[3]*1024}
            CurrentScene.tiles:addChild(tile)
        end
    end
end

function mapCreator:load()
    local obj = self.parent
    GamePaused = false
    obj.mapData = nil
    --[[Create the placeholder tile
    local tile = object.new(self)
    tile.name = "tile"
    tile.imageComponent = imageComponent.new(tile, Assets.images.tiles.prototypeGreen)
    tile.scale = {2, 2}
    tile.imageComponent.layer = 3
    self.parent:addChild(tile)
    --Ammo test
    local ammo = object.new(CurrentScene.items)
    ammo.position = {220, 100}
    ammo.name = "ammo_light"
    ammo:addComponent(table.new(itemScript))
    ammo.pickupEvent = itemUpdateFuncs.ammoPickup
    ammo.script:load()
    ammo.imageComponent.source = Assets.images.items.ammoLight
    CurrentScene.items:addChild(ammo)
    ]]--
end

function mapCreator:update(delta)
    if GamePaused then return end
    --self.parent.tile.imageComponent.color = {Settings.brightness, Settings.brightness, Settings.brightness, 1}
end

return mapCreator