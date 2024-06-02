local gameplayMenu = {}

function gameplayMenu:load()
    local gameplay = self.parent
    local settings = gameplay.parent
    local ui = gameplay.UIComponent

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
    Settings.sensivity = (ui.sensivitySlider.value*3)+1
end

return gameplayMenu