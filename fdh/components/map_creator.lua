local imageComponent = require("engine.components.image_component")
local object = require("engine.object")
local weaponItem = require("fdh.weapon_item")
local weaponManager = require("fdh.weapon_manager")

local mapCreator = {}

function mapCreator:load()
    GamePaused = false
    --Create the placeholder tile
    local tile = object.new(self)
    tile.imageComponent = imageComponent.new(tile, Assets.images.tiles.prototypeGreen)
    tile.transformComponent.scale = {x=2, y=2}
    tile.imageComponent.layer = 3
    self.parent:addChild(tile)
end

return mapCreator