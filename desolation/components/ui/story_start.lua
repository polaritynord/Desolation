local particleFuncs = require("desolation.particle_funcs")
local storyStart = ENGINE_COMPONENTS.scriptComponent.new()

function storyStart:load()
    local ui = self.parent.UIComponent
    ui.speechText = ui:newTextLabel(
        {
            text = "HELLO, AIDEN WILLIAMS.\nPLEASE DO NOT PANIC. YOU'RE STILL ASLEEP.";
            size = 30;
            font = "white-rabbit";
            begin = "center";
        }
    )
    self.speechTimer = 0
    self.particleTimer = 0
    --Create some particles for startup
    for i = 1, 50 do
        particleFuncs.createStoryStartParticles(self.parent.particleComponent)
    end
end

function storyStart:update(delta)
    --Background particles
    local particleCooldown = 0.1
    if self.particleTimer > particleCooldown then
        particleFuncs.createStoryStartParticles(self.parent.particleComponent)
        self.particleTimer = 0
    end
    self.particleTimer = self.particleTimer + delta
end

return storyStart