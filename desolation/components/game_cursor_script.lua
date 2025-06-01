local coreFuncs = require "coreFuncs"
local gameCursorScript = ENGINE_COMPONENTS.scriptComponent.new()

function gameCursorScript:load()
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
        }
    )
    ui.controllerSelection = 1
    ui.controllerCurrentMenu = CurrentScene.mainMenu.UIComponent --Dynamically change this later.
    ui.controllerAxisPressed = false
    ui.controllerArrowsPressed = false
    ui.controllerInteractPressed = false
end

function gameCursorScript:update(delta)
    local ui = self.parent.UIComponent
    --Smoothly hide the controller notification
    ui.controllerNotif.color[4] = ui.controllerNotif.color[4] + (-ui.controllerNotif.color[4])*4*delta
    --CONTROLLER ARROW CODE DOWN HERE:
    --Hide and return if keyboard is being used:
    if InputManager.inputType == "keyboard" then
        ui.controllerArrow.color[4] = 0
    else
        ui.controllerArrow.color[4] = 1
        --Use arrow keys to change selection
        if InputManager:isPressed("menu_down") and not ui.controllerArrowsPressed then
            ui.controllerArrowsPressed = true
            ui.controllerSelection = ui.controllerSelection + 1
            SoundManager:playSound(Assets.defaultSounds["button_hover"], Settings.vol_sfx)
            if ui.controllerSelection > #ui.controllerCurrentMenu.controllerButtons then ui.controllerSelection = 1 end
        end
        if InputManager:isPressed("menu_up") and not ui.controllerArrowsPressed then
            ui.controllerArrowsPressed = true
            ui.controllerSelection = ui.controllerSelection - 1
            SoundManager:playSound(Assets.defaultSounds["button_hover"], Settings.vol_sfx)
            if ui.controllerSelection < 1  then ui.controllerSelection = #ui.controllerCurrentMenu.controllerButtons end
        end
        if not InputManager:isPressed("menu_down") and not InputManager:isPressed("menu_up") then ui.controllerArrowsPressed = false end
        --Update the position of the arrow
        local selectedButton = ui.controllerCurrentMenu.controllerButtons[ui.controllerSelection]
        ui.controllerArrow.position[1] = selectedButton.position[1]-25
        ui.controllerArrow.position[2] = ui.controllerArrow.position[2] + (selectedButton.position[2]+16-ui.controllerArrow.position[2])*12*delta
        --Selected button code
        selectedButton:hoverEvent()
        if InputManager:isPressed("interact") and not ui.controllerInteractPressed then
            ui.controllerInteractPressed = true
            SoundManager:playSound(Assets.defaultSounds["button_click"], Settings.vol_sfx)
            selectedButton:clickEvent()
        end
        if not InputManager:isPressed("interact") then ui.controllerInteractPressed = false end
    end
    --ACTUAL CURSOR STUFF DOWN HERE:
    --Hide cursor if the joystick is being used
    love.mouse.setVisible(InputManager.inputType ~= "joystick")
    if CurrentScene.name ~= "Game" then return end
    if GamePaused then
        love.mouse.setCursor(Assets.cursors.default)
    else
        if CurrentScene.player.reloading then
            love.mouse.setCursor(Assets.cursors.reload)
        else
            love.mouse.setCursor(Assets.cursors.combat)
        end
    end
end

return gameCursorScript