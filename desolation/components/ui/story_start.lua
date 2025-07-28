local particleFuncs = require("desolation.particle_funcs")
local storyStart = ENGINE_COMPONENTS.scriptComponent.new()

function storyStart:startSpeak(text)
    self.speechTimer = 0
    self.weirdFontTimer = 0
    self.speechText = text or "I WOKE YOU UP FOR A REASON"
    self.speechIndex = 1
end

function storyStart:load()
    local ui = self.parent.UIComponent
    ui.speechTextLabel = ui:newTextLabel(
        {
            text = "";
            size = 30;
            font = "press-start";
            begin = "center";
            position = {225, 270};
            wrapLimit = 500;
        }
    )
    --god i suck at naming variables
    self.currentStringIndex = 1
    self.speechIndex = 1
    self.speechText = ""
    self.emphasisIndexes = {} --{INDEX, DURATION}
    self.weirdFontTimer = 0
    self.speechTimer = 0
    self.particleTimer = 0
    self.reachedSpeechEnd = false
    self.bgColor = 0
    --Create some particles for startup
    for _ = 1, 500 do
        particleFuncs.createStoryStartParticles(self.parent.particleComponent)
    end
    CurrentScene.camera.position = {480, 270}
    self:startSpeak(Loca.story.beginningSpeech[self.currentStringIndex])
end

function storyStart:update(delta)
    local ui = self.parent.UIComponent
    local particleComp = self.parent.particleComponent
    --Background particles
    local particleCooldown = 0.05
    if self.particleTimer > particleCooldown then
        particleFuncs.createStoryStartParticles(particleComp)
        self.particleTimer = 0
    end
    self.particleTimer = self.particleTimer + delta
    if self.currentStringIndex >= #Loca.story.beginningSpeech then
        local speed = 0.2
        self.bgColor = self.bgColor + speed*delta
        --Load into game scene
        if self.bgColor > 1.08 then
            local scene = LoadScene("desolation/assets/scenes/game.json")
            SetScene(scene)
            scene.mapCreator.script:loadMap("c1_bedroom")
            love.graphics.setBackgroundColor(0, 0, 0)
            return
        end
        love.graphics.setBackgroundColor(self.bgColor, self.bgColor, self.bgColor)
        ui.speechTextLabel.color = {particleComp.color[1], particleComp.color[2], particleComp.color[3], 1}
    end
    --Temporary skipping key
    if love.keyboard.isDown("space") then
        self.bgColor = 2
        self.currentStringIndex = 21
    end
    --Speech
    local speed = 0.07
    if self.speechTimer > speed and not self.reachedSpeechEnd then
        --reset text if a new string is being spoken
        if self.speechIndex == 1 then
            ui.speechTextLabel.text = ""
        end
        --skip spaces
        if string.sub(self.speechText, self.speechIndex, self.speechIndex) == " " then
            ui.speechTextLabel.text = ui.speechTextLabel.text .. string.sub(self.speechText, self.speechIndex, self.speechIndex)
            self.speechIndex = self.speechIndex + 1
        end
        ui.speechTextLabel.text = ui.speechTextLabel.text .. string.sub(self.speechText, self.speechIndex, self.speechIndex)
        self.speechTimer = 0
        --check if emphasis needs to be done
        if Loca.story.begSpeechEmphasises[self.currentStringIndex] ~= nil then
            for _, emphasis in ipairs(Loca.story.begSpeechEmphasises[self.currentStringIndex]) do
                if emphasis[1] == self.speechIndex then
                    self.speechTimer = self.speechTimer - emphasis[2]
                end
            end
        end
        self.speechIndex = self.speechIndex + 1
        --check if it reached the end of string
        if self.speechIndex > self.speechText:len()+1 then
            self.currentStringIndex = self.currentStringIndex + 1
            --Check if the very end of speech is attained
            if self.currentStringIndex > #Loca.story.beginningSpeech then
                self.reachedSpeechEnd = true
            else
                --Move on to the next one
                self:startSpeak(Loca.story.beginningSpeech[self.currentStringIndex])
                --ui.speechTextLabel.text = ""
                self.speechTimer = -1
            end
        end
        --play sound
        SoundManager:restartSound(Assets.sounds.speak_sfx, Settings.vol_sfx)
    end
    --Switch to weird font every now and then (TODO Improve)
    --if self.weirdFontTimer > 1 then
    --    ui.speechTextLabel.font = "pryonkalsov"
    --    if self.weirdFontTimer > 1.1 then
    --        ui.speechTextLabel.font = "white-rabbit"
    --        self.weirdFontTimer = 0
    --    end
    --end
    self.speechTimer = self.speechTimer + delta
    self.weirdFontTimer = self.weirdFontTimer + delta
end

return storyStart