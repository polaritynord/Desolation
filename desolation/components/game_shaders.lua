local moonshine = require("engine.lib.moonshine")

local gameShaders = {}

function gameShaders:updateVignette(chain, delta)
    --enable & disable
    if Settings.vignette then
        chain.enable("vignette")
    else
        chain.disable("vignette")
        return
    end
    local player = CurrentScene.player
    --change color based on health
    if player.health < 30 then
        self.pulseTimer = self.pulseTimer + delta
        local a = (255*(100-player.health)/100) * math.sin(self.pulseTimer*7)*0.5
        self.pulse = a--self.pulse + (a-self.pulse)*10*delta
    else
        self.pulseTimer = 0
        self.pulse = 0
    end
    --change opacity
    chain.vignette.color = {self.pulse, 0, self.blueOffset}
    chain.vignette.opacity = 0.3/CurrentScene.camera.zoom
    self.blueOffset = self.blueOffset + (-self.blueOffset)*4*delta
end

function gameShaders:load()
    CurrentScene.gameShader = moonshine.chain(960, 540, moonshine.effects.vignette)
    --CurrentScene.uiShader = moonshine.chain(960, 540, moonshine.effects.crt)
    self.pulseTimer = 0
    self.pulse = 0
    self.blueOffset = 0
    self.vignetteColor = {0, 0, 0}
end

function gameShaders:update(delta)
    -- TODO there is this one weird bug where the component updates for
    -- 1 frame more after scene changes, causing the game to crash!
    -- i simply hardcoded to make it ignore it but might research more later
    if CurrentScene.name ~= "Game" or GamePaused then return end
    self:updateVignette(CurrentScene.gameShader, delta)
    --TODO it may be nice to have seperate shaders for uicomponents in the future
    --self:updateCrt(CurrentScene.uiShader)
end

return gameShaders