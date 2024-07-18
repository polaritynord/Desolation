local coreFuncs = require "coreFuncs"
local soundManager = {}

function soundManager:playSound(source, volume, position, cameraRelative)
    local pos = position
    if cameraRelative and position ~= nil then
        pos = coreFuncs.getRelativePosition(pos, CurrentScene.camera)
        source:setPosition((pos[1]+480)/960, 1, (pos[2]+270)/540)
    end
    source:setVolume(Settings.vol_master * volume)
    source:play()
end

function soundManager:stopSound(source)
    source:stop()
end

function soundManager:pauseSound(source)
    source:pause()
end

function soundManager:restartSound(source)
    local pos = position
    if cameraRelative then
        pos = coreFuncs.getRelativePosition(pos, CurrentScene.camera)
    end
    source:setVolume(volume)
    source:setPosition(pos[1], 0, pos[2])
    source:stop()
    source:play()
end

return soundManager