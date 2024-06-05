local gameplayMenu = ENGINE_COMPONENTS.scriptComponent.new()

function gameplayMenu:load()
    local gameplay = self.parent
    local settings = gameplay.parent

    local ui = gameplay.UIComponent
    ui.cameraSwayText = ui:newTextLabel(
        {
            text = "Camera Sway: ";
            position = {0, 200};
            size = 30;
        }
    )
    ui.cameraSwayBox = ui:newCheckbox(
        {
            position = {400, 215};
            toggled = Settings.camera_sway;
        }
    )
    ui.screenShakeText = ui:newTextLabel(
        {
            text = "Screen Shake: ";
            position = {0, 240};
            size = 30;
        }
    )
    ui.screenShakeBox = ui:newCheckbox(
        {
            position = {400, 255};
            toggled = Settings.screen_shake;
        }
    )
    ui.alwaysSprintText = ui:newTextLabel(
        {
            text = "Always Sprint: ";
            position = {0, 280};
            size = 30;
        }
    )
    ui.alwaysSprintBox = ui:newCheckbox(
        {
            position = {400, 295};
            toggled = Settings.always_sprint;
        }
    )
    ui.curvedHudText = ui:newTextLabel(
        {
            text = "Curved HUD: ";
            position = {0, 320};
            size = 30;
        }
    )
    ui.curvedHudBox = ui:newCheckbox(
        {
            position = {400, 335};
            toggled = Settings.curved_hud;
        }
    )
    --[[
    ui.sensivityText = ui:newTextLabel(
        {
            text = "Sensivity: ";
            position = {0, 200};
            size = 30;
        }
    )
    ui.sensivitySlider = ui:newSlider(
        {
            position = {300, 205};
            baseColor = {0.5, 0.5, 0.5, 1};
            value = (Settings.sensivity-1)/3;
        }
    )
    ]]--

    ui.returnButton = ui:newTextButton(
        {
            buttonText = Loca.settingsReturnButton;
            buttonTextSize = 30;
            position = {0, 440};
            clickEvent = function() settings.menu = nil end;
        }
    )
end

function gameplayMenu:update(delta)
    local gameplay = self.parent
    local settings = gameplay.parent
    local ui = gameplay.UIComponent

    --UI Offsetting & canvas enabling
    gameplay.position[1] = 950 + MenuUIOffset
    ui.enabled = settings.menu == "gameplay"
    --Transparency animation
    if ui.enabled then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end

    if not ui.enabled then return end
    Settings.camera_sway = ui.cameraSwayBox.toggled
    Settings.screen_shake = ui.screenShakeBox.toggled
    Settings.always_sprint = ui.alwaysSprintBox.toggled
    Settings.curved_hud = ui.curvedHudBox.toggled
end

return gameplayMenu