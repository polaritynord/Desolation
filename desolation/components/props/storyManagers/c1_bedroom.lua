local c1Bedroom = ENGINE_COMPONENTS.scriptComponent.new()

function c1Bedroom:load()
    self.keyHintTimer = 0
    self.moveAroundHintGiven = false
    self.initiationTimer = 0
    self.textIndex = 0
    self.wakeupComplete = false
    --Setup UI
    local ui = CurrentScene.gameOver.UIComponent
    ui.blackScreen = ui:newRectangle(
        {
            size = {960, 540};
        }
    )
    ui.infoText = ui:newTextLabel(
        {
            text = "";
            font = "block-blueprint";
            position = {20, 40};
        }
    )
end

function c1Bedroom:update(delta)
    CurrentScene.cursor.hideCursor = not self.wakeupComplete and not GamePaused
    if GamePaused then return end
    --Temporary skipping key
    if love.keyboard.isDown("space") then
        self.wakeupComplete = true
    end
    local ui = CurrentScene.gameOver.UIComponent
    --TODO Might want to hide the cursor here
    if self.wakeupComplete then
        ui.blackScreen.color[4] = ui.blackScreen.color[4] - 3*delta
        --After waking up
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
    else
        CurrentScene.player.moveVelocity = {0, 0}
        --Before waking up (initiation process)
        self.initiationTimer = self.initiationTimer + delta
        --Turn the white screen to full black
        if self.initiationTimer > 1 then
            ui.blackScreen.color[1] = ui.blackScreen.color[1] - 5*delta
            if ui.blackScreen.color[1] < 0 then ui.blackScreen.color[1] = 0 end
            ui.blackScreen.color[2] = ui.blackScreen.color[1]
            ui.blackScreen.color[3] = ui.blackScreen.color[1]
        end
        --Make text gradually appear
        for i, text in ipairs(Loca.story.wakeupText) do
            if self.initiationTimer >= Loca.story.wakeupTextTimes[i] and self.textIndex < i then
                self.textIndex = self.textIndex + 1
                ui.infoText.text = ui.infoText.text .. text
                SoundManager:restartSound(Assets.mapSounds.console_process, Settings.vol_world)
            end
        end
        --After reaching the end, wait for a little, then get rid of the text. After waiting just a little more, make
        --the black screen dissapear and start game.
        local lastTextTime = Loca.story.wakeupTextTimes[#Loca.story.wakeupTextTimes]
        if self.initiationTimer > lastTextTime+2 then
            ui.infoText.text = ""
        end
        if self.initiationTimer > lastTextTime+3.4 then
            self.wakeupComplete = true
        end
    end
end

return c1Bedroom