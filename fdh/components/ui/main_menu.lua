local clickEvents = require("fdh.button_clickevents")

local mainMenu = {}

function mainMenu:load()
    local ui = self.parent.UIComponent
    ui.background = ui:newImage(
        {
            source = Assets.images.ui.menuBackground;
            scale = {0.7, 0.7};
            position = {ScreenWidth/2, ScreenHeight/2};
        }
    )
    ui.title = ui:newImage(
        {
            source = Assets.images.logo;
            position = {180, 100};
            scale = {0.6, 0.6};
        }
    )
    ui.campaignButton = ui:newTextButton(
        {
            position = {70, 200};
            buttonText = "Campaign";
            buttonTextSize = 30;
        }
    )
    ui.extrasButton = ui:newTextButton(
        {
            position = {70, 240};
            buttonText = "Extra Gamemodes";
            buttonTextSize = 30;
        }
    )
    ui.achievementsButton = ui:newTextButton(
        {
            position = {70, 280};
            buttonText = "Achievements";
            buttonTextSize = 30;
        }
    )
    ui.settingsButton = ui:newTextButton(
        {
            position = {70, 320};
            buttonText = "Settings";
            buttonTextSize = 30;
        }
    )
    ui.aboutButton = ui:newTextButton(
        {
            position = {70, 360};
            buttonText = "About";
            buttonTextSize = 30;
        }
    )
    ui.changelogButton = ui:newTextButton(
        {
            position = {70, 400};
            buttonText = "Changelog";
            buttonTextSize = 30;
        }
    )
    ui.quitButton = ui:newTextButton(
        {
            position = {70, 440};
            buttonText = "Quit";
            buttonTextSize = 30;
            clickEvent = clickEvents.quitButtonClick;
        }
    )
end

function mainMenu:update(delta)
    --local ui = self.parent.UIComponent
end

return mainMenu