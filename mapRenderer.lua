local assets = require("assets")
local coreFuncs = require("coreFuncs")

local mapRenderer = {}

function mapRenderer:load()
    
end

function mapRenderer:update()

end

function mapRenderer:draw()
    --Placeholder tile
    local src = assets.images.tiles.prototypeGreen
    local width = src:getWidth() ;  local height = src:getHeight()
    local pos = coreFuncs.getRelativePosition({0,0}, Camera)
    love.graphics.draw(
        src, pos[1], pos[2], self.rotation,
        2, 2, width/2, height/2
    )
end

return mapRenderer