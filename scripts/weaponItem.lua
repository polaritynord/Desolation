local weaponManager = require("scripts.weaponManager")
local coreFuncs = require("coreFuncs")
local assets = require("assets")

local weaponItem = {}

function weaponItem.new(weaponData)
    local instance = {
        position = {0, 0};
        velocity = {0, 0};
        rotation = 0;
        weaponData = weaponData or weaponManager.Pistol.new();
    }

    function instance:update(delta)

    end

    function instance:draw()
        local src = assets.images.weapons[string.lower(self.weaponData.name) .. "Img"]
        local width = src:getWidth() ;  local height = src:getHeight()
        local pos = coreFuncs.getRelativePosition(self.position, Camera)
        love.graphics.draw(
            src, pos[1], pos[2], self.rotation,
            2*Camera.zoom, 2*Camera.zoom, width/2, height/2
        )
    end

    return instance
end

return weaponItem