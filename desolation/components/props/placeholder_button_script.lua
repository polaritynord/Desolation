local coreFuncs = require("coreFuncs")
local buttonEvents = require("desolation.button_clickevents")
local placeholderButtonScript = ENGINE_COMPONENTS.scriptComponent.new()

function placeholderButtonScript:load()
    local button = self.parent
    button.imageComponent = ENGINE_COMPONENTS.imageComponent.new(button, Assets.mapImages["prop_placeholder_button"])
    self.keyPressed = false
    self.buttonPressed = false
end

function placeholderButtonScript:update(delta)
    if GamePaused then return end
    local button = self.parent
    if button.pressEvent == nil or self.buttonPressed then return end
    --Measure distance to player
    local distance = coreFuncs.pointDistance(CurrentScene.player.position, button.position)
    if distance > 85 then return end
    if InputManager:isPressed("interact") and not self.keyPressed then
        buttonEvents[button.pressEvent](button)
        if button.onePressOnly then
            self.buttonPressed = true
        end
    end
    self.keyPressed = InputManager:isPressed("interact")
end

return placeholderButtonScript