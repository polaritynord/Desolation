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
end

function gameCursorScript:update(delta)
    local ui = self.parent.UIComponent
    --Smoothly hide the controller notification
    ui.controllerNotif.color[4] = ui.controllerNotif.color[4] + (-ui.controllerNotif.color[4])*4*delta
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