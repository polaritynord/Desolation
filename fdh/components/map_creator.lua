local imageComponent = require("engine.components.image_component")
local object = require("engine.object")

local mapCreator = {}

function mapCreator:load()
    --Create the placeholder tile
    local tile = object.new(self)
    tile.imageComponent = imageComponent.new(tile, Assets.images.tiles.prototypeGreen)
    tile.transformComponent.scale = {x=2, y=2}
    tile.imageComponent.layer = 3
    self.parent:addChild(tile)
end

return mapCreator