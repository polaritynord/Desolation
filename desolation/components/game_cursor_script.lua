local coreFuncs = require "coreFuncs"
local gameCursorScript = ENGINE_COMPONENTS.scriptComponent.new()

function gameCursorScript:setCursorImage()
    --Hide cursor if a controller is being used & return
    love.mouse.setVisible(InputManager.inputType ~= "joystick" and CurrentScene.name ~= "Story Start" and not self.parent.hideCursor)
    if not love.mouse.isVisible() then return end
    --Set to default cursor if the game is paused or the player is dead
    local player = CurrentScene.player
    if CurrentScene.name ~= "Game" or GamePaused or (player ~= nil and player.health <= 0) then
        love.mouse.setCursor(Assets.cursors.default)
        return
    end
    --Change cursor based on reloading state
    if player.reloading then
        love.mouse.setCursor(Assets.cursors.reload)
    elseif player.inventory.weapons[player.inventory.slot] ~= nil then
        love.mouse.setCursor(Assets.cursors.combat)
    else
        love.mouse.setCursor(Assets.cursors.unarmed)
    end
end

function gameCursorScript:controllerNavigation(ui, delta)
    --CONTROLLER ARROW CODE DOWN HERE:
    --Update current menu
    if AltMenuOpen then
        --ui.controllerCurrentMenu = nil
        --Absolute shit code regarding the menus here as well:
        local temp = ui.controllerCurrentMenu
        if CurrentScene.name == "Main Menu" then
            --if CurrentScene.campaign.open then ui.controllerCurrentMenu = CurrentScene.campaign.UIComponent end
            if CurrentScene.newGameMenu.open then ui.controllerCurrentMenu = CurrentScene.newGameMenu.UIComponent end
            if CurrentScene.loadGameMenu.open then ui.controllerCurrentMenu = CurrentScene.loadGameMenu.UIComponent end
            if CurrentScene.extras.open then ui.controllerCurrentMenu = CurrentScene.extras.UIComponent end
            if CurrentScene.achievements.open then ui.controllerCurrentMenu = CurrentScene.achievements.UIComponent end
            if CurrentScene.about.open then ui.controllerCurrentMenu = CurrentScene.about.UIComponent end
            if CurrentScene.changelog.open then ui.controllerCurrentMenu = CurrentScene.changelog.UIComponent end
        end
        if CurrentScene.settings and CurrentScene.settings.open then ui.controllerCurrentMenu = CurrentScene.settings.UIComponent end
        if CurrentScene.settings and CurrentScene.settings.open and CurrentScene.settings.menu ~= nil then
            ui.controllerCurrentMenu = CurrentScene.settings[CurrentScene.settings.menu .. "Menu"].UIComponent
        end
        if CurrentScene.extras ~= nil and CurrentScene.extras.open and CurrentScene.extras.selection ~= nil then
            ui.controllerCurrentMenu = CurrentScene.extras[CurrentScene.extras.selection .. "Menu"].UIComponent
        end
        if temp ~= ui.controllerCurrentMenu then ui.controllerSelection = 1 end
    else
        local temp = ui.controllerCurrentMenu
        if CurrentScene.name == "Main Menu" then
            ui.controllerCurrentMenu = CurrentScene.mainMenu.UIComponent
        elseif CurrentScene.name == "Game" then
            if GamePaused then
                ui.controllerCurrentMenu = CurrentScene.pauseScreen.UIComponent
            elseif CurrentScene.gameOver.UIComponent.title.color[4] > 1.3 then
                ui.controllerCurrentMenu = CurrentScene.gameOver.UIComponent
            end
        elseif CurrentScene.name == "Startup" then
            ui.controllerCurrentMenu = CurrentScene.stuff.UIComponent
        else
            ui.controllerCurrentMenu = nil
        end
        if temp ~= ui.controllerCurrentMenu then ui.controllerSelection = 1 end
    end
    --Hide and return if keyboard is being used:
    if InputManager.inputType == "keyboard" or ui.controllerCurrentMenu == nil then
        ui.controllerArrow.color[4] = 0
    else
        ui.controllerArrow.color[4] = 1
        --Use arrow keys to change selection
        if (InputManager:isPressed("menu_down") and not ui.controllerArrowsPressed) or (InputManager:getAxis(2, 0.07) > 0.3 and not ui.controllerAxisPressed) then
            if InputManager:isPressed("menu_down") then ui.controllerArrowsPressed = true end
            if InputManager:getAxis(2, 0.07) > 0.3 then ui.controllerAxisPressed = true end
            ui.controllerSelection = ui.controllerSelection + 1
            SoundManager:playSound(Assets.defaultSounds["button_hover"], Settings.vol_sfx)
            if ui.controllerSelection > #ui.controllerCurrentMenu.controllerButtons then ui.controllerSelection = 1 end
        end
        if (InputManager:isPressed("menu_up") and not ui.controllerArrowsPressed) or (InputManager:getAxis(2, 0.07) < -0.3 and not ui.controllerAxisPressed) then
            if InputManager:isPressed("menu_up") then ui.controllerArrowsPressed = true end
            if InputManager:getAxis(2, 0.07) < -0.3 then ui.controllerAxisPressed = true end
            ui.controllerSelection = ui.controllerSelection - 1
            SoundManager:playSound(Assets.defaultSounds["button_hover"], Settings.vol_sfx)
            if ui.controllerSelection < 1  then ui.controllerSelection = #ui.controllerCurrentMenu.controllerButtons end
        end
        if not InputManager:isPressed("menu_down") and not InputManager:isPressed("menu_up") then ui.controllerArrowsPressed = false end
        if math.abs(InputManager:getAxis(2, 0.07)) < 0.3 then ui.controllerAxisPressed = false end
        local selectedButton = ui.controllerCurrentMenu.controllerButtons[ui.controllerSelection]
        --Slider code
        if selectedButton.imASliderAndYoullAcknowledgeIt then
            if InputManager:isPressed("slider_right") or InputManager:getAxis(1, 0.07) > 0.3 then
                selectedButton.value = selectedButton.value + 1.2*delta
                if selectedButton.value > 1 then selectedButton.value = 1 end
            end
            if InputManager:isPressed("slider_left") or InputManager:getAxis(1, 0.07) < -0.3 then
                selectedButton.value = selectedButton.value - 1.2*delta
                if selectedButton.value < 0 then selectedButton.value = 0 end
            end
        end
        --Update the position of the arrow
        local pos = coreFuncs.getRelativeElementPosition(selectedButton.position, ui.controllerCurrentMenu)
        --Scroll down if too low on the screen
        local y = selectedButton.position[2]+16
        --Fix a positioning issue with checkboxes
        if selectedButton.toggled ~= nil then
            y = y - 15
            pos[1] = pos[1] - 5
        end
        --Scroll down if the arrow is too low on the screen
        local temp = ui.controllerCurrentMenu.parent.realY
        if ui.controllerCurrentMenu.parent.realY and y+ui.controllerCurrentMenu.parent.realY > 500 then
            ui.controllerCurrentMenu.parent.realY = ui.controllerCurrentMenu.parent.realY - 60
        end
        --Scroll up if the arrow is too high on the screen
        if ui.controllerCurrentMenu.parent.realY and y+ui.controllerCurrentMenu.parent.realY < 200 then
            ui.controllerCurrentMenu.parent.realY = ui.controllerCurrentMenu.parent.realY + 60
        end
        --TODO: The scrolling code might not be framerate independent. Meaning it could work
        --slower than intended in lower framerates.
        if ui.controllerCurrentMenu.parent.realY then y = y + ui.controllerCurrentMenu.parent.realY end
        ui.controllerArrow.position[1] = ui.controllerArrow.position[1] + (pos[1]-25-ui.controllerArrow.position[1])*12*delta
        ui.controllerArrow.position[2] = ui.controllerArrow.position[2] + (y-ui.controllerArrow.position[2])*12*delta
        --Selected button code
        if selectedButton.hoverEvent then selectedButton:hoverEvent() end
        if InputManager:isPressed("interact") and not ui.controllerInteractPressed then
            ui.controllerInteractPressed = true
            SoundManager:playSound(Assets.defaultSounds["button_click"], Settings.vol_sfx)
            if selectedButton.clickEvent then selectedButton:clickEvent() end
        end
        if not InputManager:isPressed("interact") then ui.controllerInteractPressed = false end
    end
end

function gameCursorScript:load()
    self.parent.hideCursor = false
    local ui = self.parent.UIComponent
    ui.controllerNotif = ui:newTextLabel(
        {
            text = "Controller Connected";
            size = 40;
            begin = "center";
            position = {-35, 400};
            color = {1, 1, 1, 0};
        }
    )
    ui.controllerArrow = ui:newImage(
        {
            source = Assets.images.controller_selection;
            position = {600, 100};
            scale = {-0.8, 0.8};
            color = {1, 1, 1, 0};
        }
    )
    ui.controllerSelection = 1
    ui.controllerCurrentMenu = nil
    ui.controllerAxisPressed = false
    ui.controllerArrowsPressed = false
    ui.controllerInteractPressed = false
end

function gameCursorScript:update(delta)
    local ui = self.parent.UIComponent
    --Smoothly hide the controller notification
    ui.controllerNotif.color[4] = ui.controllerNotif.color[4] + (-ui.controllerNotif.color[4])*4*delta
    self:controllerNavigation(ui, delta)
    self:setCursorImage()
end

return gameCursorScript