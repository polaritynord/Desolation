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
            position = {320, 100};
            scale = {2.5, 2.5};
        }
    )
    ui.campaignButton = ui:newTextButton(
        {
            position = {70, 200};
            buttonText = Loca.campaignButton;
            buttonTextSize = 30;
        }
    )
    ui.extrasButton = ui:newTextButton(
        {
            position = {70, 240};
            buttonText = Loca.extraButton;
            buttonTextSize = 30;
            clickEvent = clickEvents.extrasButtonClick;
        }
    )
    ui.achievementsButton = ui:newTextButton(
        {
            position = {70, 280};
            buttonText = Loca.achievementsButton;
            buttonTextSize = 30;
        }
    )
    ui.settingsButton = ui:newTextButton(
        {
            position = {70, 320};
            buttonText = Loca.settingsButton;
            buttonTextSize = 30;
            clickEvent = clickEvents.settingsButtonClick;
        }
    )
    ui.aboutButton = ui:newTextButton(
        {
            position = {70, 360};
            buttonText = Loca.aboutButton;
            buttonTextSize = 30;
        }
    )
    ui.changelogButton = ui:newTextButton(
        {
            position = {70, 400};
            buttonText = Loca.changelogButton;
            buttonTextSize = 30;
        }
    )
    ui.quitButton = ui:newTextButton(
        {
            position = {70, 440};
            buttonText = Loca.quitButton;
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
    ui.blackCover = ui:newRectangle(
        {
            color = {0, 0, 0, 1};
            size = {960, 540};
        }
    )
end

function mainMenu:update(delta)
    local ui = self.parent.UIComponent
    --UI Ofsetting
    self.parent.transformComponent.x = MenuUIOffset
    ui.polarity.position[1] = 920 - MenuUIOffset
    ui.version.position[1] = 5 - MenuUIOffset
    --Change alpha of black cover
    if ui.blackCover.color[4] > 0 then
        ui.blackCover.color[4] = ui.blackCover.color[4] - 1.5*delta
    end
    --Are you sure text
    if ui.quitButton.buttonText == Loca.quitConfirmation then
        ui.quitButton.confirmTimer = ui.quitButton.confirmTimer - delta
        if ui.quitButton.confirmTimer < 0 then
            ui.quitButton.buttonText = Loca.quitButton
            ui.quitButton.textFont = "disposable-droid"
        end
    end
end

return mainMenu