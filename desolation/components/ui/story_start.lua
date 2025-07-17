local particleFuncs = require("desolation.particle_funcs")
local storyStart = ENGINE_COMPONENTS.scriptComponent.new()

function storyStart:startSpeak(text, emphasises)
    self.speechTimer = 0
    self.weirdFontTimer = 0
    self.emphasisIndexes = emphasises or {}
    self.speechText = text or "I WOKE YOU UP FOR A REASON"
    self.speechIndex = 1
end

function storyStart:load()
    local ui = self.parent.UIComponent
    ui.speechTextLabel = ui:newTextLabel(
        {
            text = "";
            size = 30;
            font = "white-rabbit";
            begin = "center";
            position = {0, 270};
        }
    )
    self.speechIndex = 1
    self.speechText = ""
    self.emphasisIndexes = {} --{INDEX, DURATION}
    self.weirdFontTimer = 0
    self.speechTimer = 0
    self.particleTimer = 0
    --Create some particles for startup
    for _ = 1, 500 do
        particleFuncs.createStoryStartParticles(self.parent.particleComponent)
    end
    CurrentScene.camera.position = {480, 270}
    self:startSpeak()
end

function storyStart:update(delta)
    local ui = self.parent.UIComponent
    --Background particles
    local particleCooldown = 0.05
    if self.particleTimer > particleCooldown then
        particleFuncs.createStoryStartParticles(self.parent.particleComponent)
        self.particleTimer = 0
    end
    self.particleTimer = self.particleTimer + delta
    --Speech
    local speed = 0.07
    if self.speechTimer > speed and self.speechIndex <= self.speechText:len() then
        --skip spaces
        if string.sub(self.speechText, self.speechIndex, self.speechIndex) == " " then
            ui.speechTextLabel.text = ui.speechTextLabel.text .. string.sub(self.speechText, self.speechIndex, self.speechIndex)
            self.speechIndex = self.speechIndex + 1
        end
        ui.speechTextLabel.text = ui.speechTextLabel.text .. string.sub(self.speechText, self.speechIndex, self.speechIndex)
        self.speechTimer = 0
        self.speechIndex = self.speechIndex + 1
        --check if emphasis needs to be done
        for _, emphasis in ipairs(self.emphasisIndexes) do
            if emphasis[1] == self.speechIndex then
                self.speechTimer = self.speechTimer - emphasis[2]
            end
        end
        --play sound
        SoundManager:restartSound(Assets.sounds.speak_sfx, Settings.vol_sfx)
    end
    --Switch to weird font every now and then (TODO Improve)
    if self.weirdFontTimer > 1 then
        ui.speechTextLabel.font = "pryonkalsov"
        if self.weirdFontTimer > 1.1 then
            ui.speechTextLabel.font = "white-rabbit"
            self.weirdFontTimer = 0
        end
    end
    self.speechTimer = self.speechTimer + delta
    self.weirdFontTimer = self.weirdFontTimer + delta
end

return storyStart