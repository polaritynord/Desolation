local imageComponent = require("engine.components.image_component")
local object = require("engine.object")
local itemScript = require("desolation.components.item.item_script")
local itemUpdateFuncs = require("desolation.components.item.item_event_funcs")

local mapCreator = ENGINE_COMPONENTS.scriptComponent.new()

function mapCreator:load()
    GamePaused = false
    --Create the placeholder tile
    local tile = object.new(self)
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
end

return mapCreator