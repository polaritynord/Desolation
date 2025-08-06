local json = require("engine.lib.json")
local coreFuncs = require("coreFuncs")
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
    ui.saveProgressButton = ui:newTextButton(
        {
            position = {70, 240},
            buttonText = Loca.pauseScreen.saveProgress;
            buttonTextSize = 30;
            clickEvent = function ()
                if not CurrentScene.mapCreator.saveableMap then return end
                CurrentScene.mapCreator.script:saveProgress()
                CurrentScene.keyHints.UIComponent.progressSaveText.color[4] = 1
                GamePaused = false
                SoundManager:restartSound(Assets.defaultSounds.save, Settings.vol_sfx)
            end
        }
    )
    ui.loadGameButton = ui:newTextButton(
        {
            position = {70, 280};
            buttonText = Loca.mainMenu.loadGame;
            buttonTextSize = 30;
            clickEvent = function (element)
                if not CurrentScene.mapCreator.saveableMap then return end
                clickEvents.loadGameButtonClick(element)
            end;
        }
    )
    ui.settingsButton = ui:newTextButton(
        {
            position = {70, 320};
            buttonText = Loca.mainMenu.settings;
            buttonTextSize = 30;
            clickEvent = clickEvents.settingsButtonClick;
        }
    )
    ui.menuButton = ui:newTextButton(
        {
            position = {70, 360};
            buttonText = Loca.pauseScreen.mainMenu;
            buttonTextSize = 30;
            clickEvent = function ()
                love.filesystem.write("settings.json", json.encode(Settings))
                love.filesystem.write("achievements.json", json.encode(Achievements))
                local scene = LoadScene("desolation/assets/scenes/main_menu2.json")
                SetScene(scene)
            end
        }
    )
    ui.quitButton = ui:newTextButton(
        {
            position = {70, 400};
            buttonText = Loca.mainMenu.quit;
            buttonTextSize = 30;
            clickEvent = clickEvents.quitButtonClick;
        }
    )
    ui.quitButton.confirmTimer = 0
    ui.controllerButtons = {ui.continueButton, ui.saveProgressButton, ui.loadGameButton, ui.settingsButton, ui.menuButton, ui.quitButton}
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
    --Dim the "save progress" button if not playing a saveable map (aka story)
    ui.saveProgressButton.color[4] = 0.5 + 0.5*coreFuncs.boolToNum(CurrentScene.mapCreator.saveableMap)
    ui.loadGameButton.color[4] = 0.5 + 0.5*coreFuncs.boolToNum(CurrentScene.mapCreator.saveableMap)
end

return pauseScreen