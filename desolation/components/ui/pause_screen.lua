local json = require("engine.lib.json")

local clickEvents = require("desolation.button_clickevents")

local pauseScreen = ENGINE_COMPONENTS.scriptComponent.new()

function pauseScreen:load()
    local ui = self.parent.UIComponent

    ui.background = ui:newRectangle({color={0, 0, 0, 0.6}})
    ui.title = ui:newImage(
        {
            source = Assets.images.logo;
            position = {320, 100};
            scale = {2.5, 2.5};
        }
    )
    ui.continueButton = ui:newTextButton(
        {
            position = {70, 200};
            buttonText = Loca.pauseScreen.continue;
            buttonTextSize = 30;
            clickEvent = function ()
                GamePaused = false
                CurrentScene.settings.menu = nil
                CurrentScene.settings.open = false
            end;
        }
    )
    ui.settingsButton = ui:newTextButton(
        {
            position = {70, 240};
            buttonText = Loca.mainMenu.settings;
            buttonTextSize = 30;
            clickEvent = clickEvents.settingsButtonClick;
        }
    )
    ui.menuButton = ui:newTextButton(
        {
            position = {70, 280};
            buttonText = Loca.pauseScreen.mainMenu;
            buttonTextSize = 30;
            clickEvent = function ()
                love.filesystem.write("settings.json", json.encode(Settings))
                local scene = LoadScene("desolation/assets/scenes/main_menu.json")
                SetScene(scene)
            end
        }
    )
    ui.quitButton = ui:newTextButton(
        {
            position = {70, 320};
            buttonText = Loca.mainMenu.quit;
            buttonTextSize = 30;
            clickEvent = clickEvents.quitButtonClick;
        }
    )
    ui.quitButton.confirmTimer = 0
end

function pauseScreen:update(delta)
    local ui = self.parent.UIComponent
    --Set enabled state
    ui.enabled = GamePaused
    --UI Offsetting
    self.parent.position[1] = MenuUIOffset
    --Smooth alpha transitioning
    local smoothness = 7
    if GamePaused then
        ui.alpha = ui.alpha + (1 - ui.alpha) * smoothness * delta
        --Scale background to fit screen
        ui.background.size = {ScreenWidth+500, ScreenHeight}
    else
        ui.alpha = 0.4
    end
    --Are you sure text
    if ui.quitButton.buttonText == Loca.mainMenu.quitConfirmation then
        ui.quitButton.confirmTimer = ui.quitButton.confirmTimer - delta
        if ui.quitButton.confirmTimer < 0 then
            ui.quitButton.buttonText = Loca.mainMenu.quitButton
            ui.quitButton.textFont = "disposable-droid"
        end
    end
end

return pauseScreen