local buttonEvents = require("desolation.button_clickevents")

local gameplayMenu = ENGINE_COMPONENTS.scriptComponent.new()

function gameplayMenu:load()
    local gameplay = self.parent
    local settings = gameplay.parent

    local ui = gameplay.UIComponent
    ui.cameraSwayText = ui:newTextLabel(
        {
            text = Loca.gameplayMenu.cameraSway;
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
            text = Loca.gameplayMenu.screenShake;
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
            text = Loca.gameplayMenu.alwaysSprint;
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
            text = Loca.gameplayMenu.curvedHud;
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
    ui.sprintTypeText = ui:newTextLabel(
        {
            text = "Sprint Type: ";
            position = {0, 360};
            size = 30;
        }
    )
    ui.sprintTypeButton = ui:newTextButton(
        {
            position = {370, 360};
            buttonText = string.upper(Settings.sprint_type);
            buttonTextSize = 30;
            hoverEvent = buttonEvents.redHover;
            unhoverEvent = buttonEvents.redUnhover;
            clickEvent = function()
                if Settings.sprint_type == "hold" then
                    Settings.sprint_type = "toggle"
                else Settings.sprint_type = "hold" end
            end
        }
    )
    ui.sensivityText = ui:newTextLabel(
        {
            text = "Sensivity: ";
            position = {0, 400};
            size = 30;
        }
    )
    ui.sensivitySlider = ui:newSlider(
        {
            position = {300, 405};
            baseColor = {0.5, 0.5, 0.5, 1};
            value = (Settings.sensivity-1)/3;
        }
    )

    ui.returnButton = ui:newTextButton(
        {
            buttonText = Loca.settings.returnButton;
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
    Settings.sensivity = ui.sensivitySlider.value+1
    ui.sprintTypeButton.buttonText = string.upper(Settings.sprint_type)
end

return gameplayMenu