local buttonEvents = require("desolation.button_clickevents")

local gameplayMenu = ENGINE_COMPONENTS.scriptComponent.new()

function gameplayMenu:load()
    local gameplay = self.parent
    local settings = gameplay.parent

    local ui = gameplay.UIComponent
    ui.enabled = false
    gameplay.realY = gameplay.position[2]
    gameplay.length = 655

    ui.title = ui:newTextLabel(
        {
            text = Loca.settings.gameplayTitle;
            size = 45;
            position = {0, 140};
            font = "disposable-droid-bold";
        }
    )

    ui.skipIntroText = ui:newTextLabel(
        {
            text = Loca.gameplayMenu.skipIntro;
            position = {0, 200};
            size = 30;
        }
    )
    ui.skipIntroBox = ui:newCheckbox(
        {
            position = {400, 215};
            toggled = Settings.skip_intro;
        }
    )
    ui.cameraSwayText = ui:newTextLabel(
        {
            text = Loca.gameplayMenu.cameraSway;
            position = {0, 240};
            size = 30;
        }
    )
    ui.cameraSwayBox = ui:newCheckbox(
        {
            position = {400, 255};
            toggled = Settings.camera_sway;
        }
    )
    ui.screenShakeText = ui:newTextLabel(
        {
            text = Loca.gameplayMenu.screenShake;
            position = {0, 280};
            size = 30;
        }
    )
    ui.screenShakeBox = ui:newCheckbox(
        {
            position = {400, 295};
            toggled = Settings.screen_shake;
        }
    )
    ui.alwaysSprintText = ui:newTextLabel(
        {
            text = Loca.gameplayMenu.alwaysSprint;
            position = {0, 320};
            size = 30;
        }
    )
    ui.alwaysSprintBox = ui:newCheckbox(
        {
            position = {400, 335};
            toggled = Settings.always_sprint;
        }
    )
    --[[
    ui.curvedHudText = ui:newTextLabel(
        {
            text = Loca.gameplayMenu.curvedHud;
            position = {0, 360};
            size = 30;
        }
    )
    ui.curvedHudBox = ui:newCheckbox(
        {
            position = {400, 375};
            toggled = Settings.curved_hud;
        }
    )
    ]]--
    ui.sprintTypeText = ui:newTextLabel(
        {
            text = Loca.gameplayMenu.sprintType;
            position = {0, 360};
            size = 30;
        }
    )
    ui.sprintTypeButton = ui:newTextButton(
        {
            position = {370, 360};
            buttonText = "";
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
    ui.experimentalPeekingText = ui:newTextLabel(
        {
            position = {0, 400};
            text = "Experimental Peeking: ";
            size = 30;
        }
    )
    ui.experimentalPeekingBox = ui:newCheckbox(
        {
            position = {400, 415};
            toggled = Settings.experimental_peeking;
        }
    )
    ui.itemsPickupText = ui:newTextLabel(
        {
            position = {0, 440};
            text = Loca.gameplayMenu.autoPickupLoot;
            size = 30;
        }
    )
    ui.itemsPickupBox = ui:newCheckbox(
        {
            position = {400, 455};
            toggled = Settings.auto_pick_loot;
        }
    )
    ui.controllerVibrationText = ui:newTextLabel(
        {
            text = "Controller Vibration: ";
            size = 30;
            position = {0, 480};
        }
    )
    ui.controllerVibrationBox = ui:newCheckbox(
        {
            position = {400, 495};
            toggled = Settings.controller_vibration;
        }
    )
    ui.controllerAimAssist = ui:newTextLabel(
        {
            text = Loca.gameplayMenu.controllerAimAssist;
            size = 30;
            position = {0, 520};
        }
    )
    ui.controllerAimAssistBox = ui:newCheckbox(
        {
            position = {400, 535};
            toggled = Settings.controller_aim_assist;
        }
    )
    ui.controllerButtons = {
        ui.cameraSwayBox,
        ui.screenShakeBox,
        ui.alwaysSprintBox,
        ui.sprintTypeButton,
        ui.experimentalPeekingBox,
        ui.itemsPickupBox,
        ui.controllerVibrationBox,
        ui.controllerAimAssistBox
    }
end

function gameplayMenu:update(delta)
    local gameplay = self.parent
    local settings = gameplay.parent
    local ui = gameplay.UIComponent

    --UI Offsetting & canvas enabling
    gameplay.position[1] = 950 + MenuUIOffset
    gameplay.position[2] = gameplay.position[2] + (gameplay.realY-gameplay.position[2])*8*delta
    ui.enabled = settings.menu == "gameplay"
    --Transparency animation
    if ui.enabled then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end

    if not ui.enabled then return end
    settings.preview.skip_intro = ui.skipIntroBox.toggled
    settings.preview.camera_sway = ui.cameraSwayBox.toggled
    settings.preview.screen_shake = ui.screenShakeBox.toggled
    settings.preview.always_sprint = ui.alwaysSprintBox.toggled
    --settings.preview.curved_hud = ui.curvedHudBox.toggled
    settings.preview.sprint_type = Settings.sprint_type
    settings.preview.experimental_peeking = ui.experimentalPeekingBox.toggled
    settings.preview.auto_pick_loot = ui.itemsPickupBox.toggled
    settings.preview.controller_vibration = ui.controllerVibrationBox.toggled
    settings.preview.controller_aim_assist = ui.controllerAimAssistBox.toggled
    ui.sprintTypeButton.buttonText = Loca.gameplayMenu[Settings.sprint_type]
    --quitting when using controller
    if InputManager:isPressed("return") then
        settings.menu = nil
        --UpdateControllerHints("menu_normal")
    end
end

return gameplayMenu