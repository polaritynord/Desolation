local coreFuncs = require "coreFuncs"
local radioScript = ENGINE_COMPONENTS.scriptComponent.new()

function radioScript:load()
    local radio = self.parent
    radio.imageComponent = ENGINE_COMPONENTS.imageComponent.new(radio, Assets.mapImages["prop_radio"])
    radio.scale = {1.7, 1.7}
    radio.distanceToPlayer = 1000
    radio.playing = false
    radio.playerPressing = false
end

function radioScript:update(delta)
    local radio = self.parent
    local player = CurrentScene.player
    if player == nil then return end
    radio.distanceToPlayer = coreFuncs.pointDistance(radio.position, player.position)
    if radio.distanceToPlayer > 80 then return end
    if InputManager:isPressed("interact") and not radio.playerPressing then
        SoundManager:restartSound(Assets.mapSounds["wake_up"], Settings.vol_world, nil, false)
    end
    radio.playerPressing = InputManager:isPressed("interact")
end

return radioScript