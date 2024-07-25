local soundManager = {}

function soundManager:playSound(source, volume, position, cameraRelative)
    if source == nil then
        ConsoleLog("Attempt to play sound failed: not loaded!")
        return
    end
    if cameraRelative then
        source:setPosition(position[1], position[2])
        love.audio.setPosition(CurrentScene.camera.position[1], 1, CurrentScene.camera.position[2])
    else
        if position ~= nil then
            source:setPosition(0, 0, 0)
        end
        love.audio.setPosition(0, 0, 0)
    end
    source:setVolume(Settings.vol_master * volume)
    source:play()
end

function soundManager:stopSound(source)
    if source == nil then
        ConsoleLog("Attempt to play sound failed: not loaded!")
        return
    end
    source:stop()
end

function soundManager:pauseSound(source)
    if source == nil then
        ConsoleLog("Attempt to play sound failed: not loaded!")
        return
    end
    source:pause()
end

function soundManager:restartSound(source, volume, position, cameraRelative)
    if source == nil then
        ConsoleLog("Attempt to play sound failed: not loaded!")
        return
    end
    if cameraRelative then
        source:setPosition(position[1], position[2])
        love.audio.setPosition(CurrentScene.camera.position[1], 1, CurrentScene.camera.position[2])
    else
        if position ~= nil then
            source:setPosition(0, 0, 0)
        end
        love.audio.setPosition(0, 0, 0)
    end
    source:setVolume(Settings.vol_master * volume)
    source:stop()
    source:play()
end

return soundManager