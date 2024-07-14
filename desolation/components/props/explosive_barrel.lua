local physicsProp = require("desolation.components.props.physics_prop")

local crateScript = table.new(physicsProp)

function crateScript:bulletHitEvent(bullet)
    local source = Assets.mapSounds["hit_barrel" .. math.random(1, 3)]
    source:setVolume(Settings.vol_master * Settings.vol_world)
    source:stop() ; source:play()
end

function crateScript:destroyEvent(prop)
    --remove self so this shit doesnt crash the game
    table.removeValue(CurrentScene.props.tree, prop)
    local mapCreator = CurrentScene.mapCreator.script
    mapCreator:createExplosion(prop.position, 400, 10)
    --(Infinite mode)
    if not CurrentScene.regenerateProps then return end
    local cratePos = CurrentScene.props["openarea_manager"].script:determineCratePos()
    local propData = {
        "explosive_barrel", cratePos, math.uniform(0, math.pi*2), {}
    }
    CurrentScene.mapCreator.script:spawnProp(propData)
    CurrentScene.barrelsExploded = CurrentScene.barrelsExploded + 1
end

function crateScript:load()
    local barrel = self.parent
    self:setup()
    --load hit sounds
    for i = 1, 3 do
        if Assets.mapSounds["hit_barrel" .. i] == nil then
            Assets.mapSounds["hit_barrel" .. i] = love.audio.newSource("desolation/assets/sounds/hit_barrel" .. i .. ".wav", "static")
        end
    end
    barrel.imageComponent = ENGINE_COMPONENTS.imageComponent.new(barrel, Assets.mapImages["prop_explosive_barrel"])
    barrel.scale = {2.5, 2.5}
end

function crateScript:update(delta)
    if GamePaused then return end
    self:physicsUpdate(delta)
end

return crateScript