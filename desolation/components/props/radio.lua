local coreFuncs = require "coreFuncs"
local radioScript = ENGINE_COMPONENTS.scriptComponent.new()

function radioScript:load()
    local radio = self.parent
    --load image if nonexistant
    if Assets.mapImages["prop_radio"] == nil then
        Assets.mapImages["prop_radio"] = love.graphics.newImage("desolation/assets/images/props/radio.png")
    end
    --load sound if nonexistant
    if Assets.mapSounds["wakeup"] == nil then
        Assets.mapSounds["wakeup"] = love.audio.newSource("desolation/assets/sounds/ost/wakeup.wav", "stream")
    end
    radio.imageComponent = ENGINE_COMPONENTS.imageComponent.new(radio, Assets.mapImages["prop_radio"])
    radio.scale = {1.7, 1.7}
    radio.distanceToPlayer = 1000
    radio.playing = false
    radio.playerPressing = false
end

function radioScript:update(delta)
    local radio = self.parent
    local player = CurrentScene.player
    radio.distanceToPlayer = coreFuncs.pointDistance(radio.position, player.position)
    if radio.distanceToPlayer > 80 then return end
    if InputManager:isPressed("interact") and not radio.playerPressing then
        radio.playing = not radio.playing
        if radio.playing then
            Assets.mapSounds["wakeup"]:setVolume(Settings.vol_master * Settings.vol_world)
            Assets.mapSounds["wakeup"]:stop() ; Assets.mapSounds["wakeup"]:play()
        else Assets.mapSounds["wakeup"]:stop() end
    end
    radio.playerPressing = InputManager:isPressed("interact")
end

return radioScript