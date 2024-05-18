local clickEvents = require("fdh.button_clickevents")

local mainMenu = {}

function mainMenu:load()
    local ui = self.parent.UIComponent
    ui.background = ui:newImage(
        {
            source = Assets.images.ui.menuBackground;
            scale = {0.7, 0.7};
            position = {480, 270};
        }
    )
    ui.title = ui:newImage(
        {
            source = Assets.images.logo;
            position = {210, 100};
            scale = {3.7, 3.7};
        }
    )
    ui.eternal = ui:newTextLabel(
        {
            text = "[ETERNAL HORIZONS]";
            position = {95, 140};
            font = "ticketing";
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
            clickEvent = function ()
                local scene = LoadScene("fdh/assets/scenes/game.json")
                SetScene(scene)
            end
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
    ui.quitButton.confirmTimer = 0
    --Other things
    ui.polarity = ui:newImage(
        {
            source = Assets.images.iconTransparent;
            position = {920, 510};
            scale = {0.5, 0.5};
        }
    )
    ui.version = ui:newTextLabel(
        {
            text = GAME_VERSION_STATE .. " " .. GAME_VERSION;
            position = {5, 512.5};
            font = "disposable-droid"
        }
    )
end

function mainMenu:update(delta)
    local ui = self.parent.UIComponent
    --Are you sure text
    if ui.quitButton.buttonText == "Are You Sure?" then
        ui.quitButton.confirmTimer = ui.quitButton.confirmTimer - delta
        if ui.quitButton.confirmTimer < 0 then
            ui.quitButton.buttonText = "Quit"
        end
    end
end

return mainMenu