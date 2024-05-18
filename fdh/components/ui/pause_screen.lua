local clickEvents = require("fdh.button_clickevents")

local pauseScreen = {}

function pauseScreen:load()
    local ui = self.parent.UIComponent

    ui.background = ui:newRectangle({color={0, 0, 0, 0.6}})
    ui.title = ui:newImage(
        {
            source = Assets.images.logo;
            position = {180, 100};
            scale = {0.6, 0.6};
        }
    )
    ui.continueButton = ui:newTextButton(
        {
            position = {70, 200};
            buttonText = "Continue";
            buttonTextSize = 30;
            clickEvent = function () GamePaused = false end;
        }
    )
    ui.settingsButton = ui:newTextButton(
        {
            position = {70, 240};
            buttonText = "Settings";
            buttonTextSize = 30;
        }
    )
    ui.menuButton = ui:newTextButton(
        {
            position = {70, 280};
            buttonText = "Main Menu";
            buttonTextSize = 30;
        }
    )
    ui.menuButton = ui:newTextButton(
        {
            position = {70, 320};
            buttonText = "Quit";
            buttonTextSize = 30;
            clickEvent = clickEvents.quitButtonClick;
        }
    )
end

function pauseScreen:update(delta)
    local ui = self.parent.UIComponent
    --Set enabled state
    ui.enabled = GamePaused
    --Smooth alpha transitioning
    local smoothness = 7
    if GamePaused then
        ui.alpha = ui.alpha + (1 - ui.alpha) * smoothness * delta
        --Scale background to fit screen
        ui.background.size = {ScreenWidth+500, ScreenHeight}
    else
        ui.alpha = 0.4
    end
end

return pauseScreen