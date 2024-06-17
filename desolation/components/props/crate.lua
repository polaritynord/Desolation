local object = require("engine.object")
local coreFuncs = require("coreFuncs")
local itemEventFuncs = require("desolation.components.item.item_event_funcs")
local itemScript = require("desolation.components.item.item_script")
local particleFuncs = require("desolation.particle_funcs")
local physicsProp = require("desolation.components.props.physics_prop")

local crateScript = table.new(physicsProp)

function crateScript:bulletHitEvent(bullet)
    local crate = self.parent
    crate.health = crate.health - bullet.damage
    crate.velocity[1] = 100*math.cos(bullet.rotation)
    crate.velocity[2] = 100*math.sin(bullet.rotation)
    crate.rotVelocity = math.uniform(-5, 5)
    --sound effect
    local source = Assets.mapSounds["hit_crate" .. math.random(1, 2)]
    source:setVolume(Settings.vol_master * Settings.vol_world)
    source:stop() ; source:play()
    --if crate is fully destroyed:
    if crate.health <= 0 then
        crate.destroyed = true
        crate.collidable = false
        --particle effects
        local comp = CurrentScene.bullets.particleComponent
        particleFuncs.createCrateWoodParticles(comp, crate.position)
        --summon loots (if exists)
        if crate.loot == nil then return end
        local mapCreator = CurrentScene.mapCreator
        for _, loot in ipairs(crate.loot) do
            --Create object data
            local itemInstance = object.new(CurrentScene.items)
            itemInstance.name = loot
            itemInstance:addComponent(table.new(itemScript))
            itemInstance.scale = mapCreator.itemData[itemInstance.name].scale
            itemInstance.pickupEvent = itemEventFuncs[mapCreator.itemData[itemInstance.name].pickupEvent]
            itemInstance.script:load()
            --randomize position & rotation
            itemInstance.position = table.new(crate.position)
            itemInstance.velocity = math.uniform(250, 400)
            itemInstance.rotation = math.uniform(0, math.pi)
            itemInstance.realRot = itemInstance.rotation
            CurrentScene.items:addChild(itemInstance)
        end
    end
end

function crateScript:load()
    local crate = self.parent
    self:setup()
    --load image if nonexistant
    if Assets.mapImages["prop_crate"] == nil then
        Assets.mapImages["prop_crate"] = love.graphics.newImage("desolation/assets/images/props/crate.png")
    end
    --load hit sounds
    for i = 1, 2 do
        if Assets.mapSounds["hit_crate" .. i] == nil then
            Assets.mapSounds["hit_crate" .. i] = love.audio.newSource("desolation/assets/sounds/hit_crate" .. i .. ".wav", "static")
        end
    end
    crate.imageComponent = ENGINE_COMPONENTS.imageComponent.new(crate, Assets.mapImages["prop_crate"])
    crate.scale = {2.5+coreFuncs.boolToNum(crate.name == "crate_big"), 2.5+coreFuncs.boolToNum(crate.name == "crate_big")}
end

function crateScript:update(delta)
    if GamePaused then return end
    self:physicsUpdate(delta)
end

return crateScript