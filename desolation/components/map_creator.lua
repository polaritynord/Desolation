local imageComponent = require("engine.components.image_component")
local object = require("engine.object")
local ammoItemScript = require("desolation.components.item_script")

local mapCreator = {}

function mapCreator:load()
    GamePaused = false
    --Create the placeholder tile
    local tile = object.new(self)
    tile.imageComponent = imageComponent.new(tile, Assets.images.tiles.prototypeGreen)
    tile.transformComponent.scale = {x=2, y=2}
    tile.imageComponent.layer = 3
    self.parent:addChild(tile)
    --Ammunition item test
    local ammo = object.new(self)
    ammo.script = table.new(ammoItemScript)
    ammo.script.parent = ammo
    ammo.script:load()
    CurrentScene.items:addChild(ammo)
end

return mapCreator