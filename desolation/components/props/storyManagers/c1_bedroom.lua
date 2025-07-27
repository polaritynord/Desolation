local c1Bedroom = ENGINE_COMPONENTS.scriptComponent.new()

function c1Bedroom:load()
    self.keyHintTimer = 0
    self.moveAroundHintGiven = false
end

function c1Bedroom:update(delta)
    self.keyHintTimer = self.keyHintTimer + delta
    if self.keyHintTimer > 2 and not self.moveAroundHintGiven and InputManager.inputType == "keyboard" then
        local keyHintsScript = CurrentScene.keyHints.script
        --Look around hint
        keyHintsScript:addHintToQueue(nil, Loca.customKeyHintDescriptions.useMouse)
        --Movement hint (WASD by default)
        local moveUpKey = InputManager:getKeys("move_up")[1]:upper()
        local moveDownKey = InputManager:getKeys("move_down")[1]:upper()
        local moveRightKey = InputManager:getKeys("move_right")[1]:upper()
        local moveLeftKey = InputManager:getKeys("move_left")[1]:upper()
        keyHintsScript:addHintToQueue(
            moveUpKey .. moveLeftKey .. moveDownKey .. moveRightKey,
            Loca.customKeyHintDescriptions.moveAround
        )
        self.moveAroundHintGiven = true
    end
end

return c1Bedroom