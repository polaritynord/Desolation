local particleFuncs = require("desolation.particle_funcs")
local storyStart = ENGINE_COMPONENTS.scriptComponent.new()

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
    self.speechText = "HELLO, AIDEN WILLIAMS."
    self.emphasisIndexes = {{7, 0.5}, {13, 0.3}} --{INDEX, DURATION}
    self.speechTimer = 0
    self.particleTimer = 0
    --Create some particles for startup
    for i = 1, 500 do
        particleFuncs.createStoryStartParticles(self.parent.particleComponent)
    end
    CurrentScene.camera.position = {480, 270}
end

function storyStart:update(delta)
    local ui = self.parent.UIComponent
    --Background particles
    local particleCooldown = 0.1
    if self.particleTimer > particleCooldown then
        particleFuncs.createStoryStartParticles(self.parent.particleComponent)
        self.particleTimer = 0
    end
    self.particleTimer = self.particleTimer + delta
    --Speech
    local speed = 0.07
    if self.speechTimer > speed then
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
    end
    self.speechTimer = self.speechTimer + delta
end

return storyStart