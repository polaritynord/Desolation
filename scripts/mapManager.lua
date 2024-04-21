local assets = require("assets")
local coreFuncs = require("coreFuncs")
local weaponItem = require("scripts.weaponItem")
local particleProp = require("scripts.props.particleProp")
local camera = require("scripts.camera")


local mapManager = {
    humanoids = {};
    props = {};
    tiles = {};
    weaponItems = {};
    particleCount = 0;
}

function mapManager:load()
    self:resetTree()
    Camera = camera.new()
    --Some prop tests over here
    --self.testParticles = self:newProp(particleProp.new())
    --self.testParticles.propUpdate = function (prop, delta)
    --    prop:newParticle(
    --        {
    --            position = {200, -152};
    --            type = "rect";
    --            --size = {6, 3};
    --        }
    --    )
    --end
end

function mapManager:resetTree()
    self.humanoids = {}
    self.props = {}
    self.tiles = {}
    self.weaponItems = {}
end

function mapManager:newHumanoid(humanoid)
    self.humanoids[#self.humanoids+1] = humanoid
    return humanoid
end

function mapManager:newProp(prop)
    self.props[#self.props+1] = prop
    return prop
end

function mapManager:newWeaponItem(item)
    self.weaponItems[#self.weaponItems+1] = item
    return item
end

function mapManager:update(delta)
    if GamePaused then return end
    local particleCount = 0
    --Humanoids
    for _, v in ipairs(self.humanoids) do
        v:update(delta)
    end

    --Weapon items
    for i, v in ipairs(self.weaponItems) do
        v:update(delta, i)
    end

    --Props
    for _, v in ipairs(self.props) do
        if v.update then v:update(delta) end
        if v.propUpdate then v:propUpdate(v, delta) end
        --Add up particle count to total
        if v.particles then
            particleCount = particleCount + #v.particles
        end
    end

    self.particleCount = particleCount
end

function mapManager:draw()
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

    --Props
    for _, v in ipairs(self.props) do
        if v.draw then v:draw() end
    end
end

return mapManager