local moonshine = require("engine.lib.moonshine")

local gameShaders = {}

function gameShaders:updateVignette(chain)
    --enable & disable
    if Settings.vignette then
        chain.enable("vignette")
    else
        chain.disable("vignette")
        return
    end
    local player = CurrentScene.player
    --change color based on health
    if player.health < 50 then
        chain.vignette.color = {255*(100-player.health)/100, 0, 0}
    else
        chain.vignette.color = {0, 0, 0}
    end
    --change opacity
    chain.vignette.opacity = 0.3/CurrentScene.camera.zoom
end

function gameShaders:load()
    CurrentScene.gameShader = moonshine.chain(960, 540, moonshine.effects.vignette)
end

function gameShaders:update(delta)
    -- TODO there is this one weird bug where the component updates for
    -- 1 frame more after scene changes, causing the game to crash!
    -- i simply hardcoded to make it ignore it but might research more later
    if CurrentScene.name ~= "Game" then return end
    local chain = CurrentScene.gameShader
    self:updateVignette(chain)
end

return gameShaders