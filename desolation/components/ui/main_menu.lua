local clickEvents = require("desolation.button_clickevents")
local moonshine = require("engine.lib.moonshine")

local mainMenu = ENGINE_COMPONENTS.scriptComponent.new()

function mainMenu:loadShaders()
    if not Settings.shiny_menu then return end
    CurrentScene.uiShader = moonshine.chain(960, 540, moonshine.effects.glow)
    CurrentScene.uiShader.glow.strength = 5
    CurrentScene.uiShader.glow.min_luma = 0.1
end

function mainMenu:load()
    local ui = self.parent.UIComponent

    ui.title = ui:newImage(
        {
            source = Assets.images.logo;
            position = {320, 100};
            scale = {2.5, 2.5};
        }
    )
    ui.newGameButton = ui:newTextButton(
        {
            position = {70, 200};
            buttonText = Loca.mainMenu.newGame;
            buttonTextSize = 30;
            clickEvent = clickEvents.newGameButtonClick;
        }
    )
    ui.loadGameButton = ui:newTextButton(
        {
            position = {70, 240};
            buttonText = Loca.mainMenu.loadGame;
            buttonTextSize = 30;
            clickEvent = clickEvents.loadGameButtonClick;
        }
    )
    --[[
    ui.campaignButton = ui:newTextButton(
        {
            position = {70, 200};
            buttonText = Loca.mainMenu.campaign;
            buttonTextSize = 30;
            clickEvent = clickEvents.campaignButtonClick;
        }
    )
    ]]--
    ui.extrasButton = ui:newTextButton(
        {
            position = {70, 280};
            buttonText = Loca.mainMenu.extra;
            buttonTextSize = 30;
            clickEvent = clickEvents.extrasButtonClick;
        }
    )
    ui.achievementsButton = ui:newTextButton(
        {
            position = {70, 320};
            buttonText = Loca.mainMenu.achievements;
            buttonTextSize = 30;
            clickEvent = clickEvents.achievementsButtonClick;
        }
    )
    ui.settingsButton = ui:newTextButton(
        {
            position = {70, 360};
            buttonText = Loca.mainMenu.settings;
            buttonTextSize = 30;
            clickEvent = clickEvents.settingsButtonClick;
        }
    )
    ui.changelogButton = ui:newTextButton(
        {
            position = {70, 400};
            buttonText = Loca.mainMenu.changelog;
            buttonTextSize = 30;
            clickEvent = clickEvents.changelogButtonClick;
        }
    )
    ui.quitButton = ui:newTextButton(
        {
            position = {70, 440};
            buttonText = Loca.mainMenu.quit;
            buttonTextSize = 30;
            clickEvent = clickEvents.quitButtonClick;
        }
    )
    ui.controllerButtons = {ui.newGameButton, ui.loadGameButton, ui.extrasButton, ui.achievementsButton, ui.settingsButton, ui.changelogButton, ui.quitButton}
    ui.quitButton.confirmTimer = 0
    --Other things
    ui.polarity = ui:newImage(
        {
            source = Assets.images["nord_transparent"];
            position = {920, 510};
            scale = {0.5, 0.5};
        }
    )
    ui.version = ui:newTextLabel(
        {
            text = GAME_VERSION_STATE .. " " .. GAME_VERSION;
            position = {5, 512.5};
            font = "disposable-droid";
        }
    )
    self.appearCooldown = 0.5
    --initial loading stuff
    if CurrentScene.mapCreator ~= nil then
        CurrentScene.mapCreator.script:loadMap(Settings.menu_background)
    end
    --Cool shader stuff
    self:loadShaders()
    CurrentScene.gameShader.chain(moonshine.effects.gaussianblur)
    CurrentScene.gameShader.gaussianblur.sigma = 2.8
    ui.alpha = 0
end

function mainMenu:update(delta)
    SoundManager:playSound(Assets.sounds["loop_menu"], Settings.vol_music)
    --Other stuff
    local ui = self.parent.UIComponent
    --UI Ofsetting
    self.parent.position[1] = MenuUIOffset
    ui.polarity.position[1] = 920 - MenuUIOffset
    ui.version.position[1] = 5 - MenuUIOffset
    --Slowly increase alpha of all elements & illumination of scene
    if self.appearCooldown <= 0 then
        ui.alpha = ui.alpha + 0.7*delta
        if ui.alpha > 1 then ui.alpha = 1 end
        local ilumSpeed = 0.3
        CurrentScene.illumination[1] = CurrentScene.illumination[1] + ilumSpeed*delta
        CurrentScene.illumination[2] = CurrentScene.illumination[1]
        CurrentScene.illumination[3] = CurrentScene.illumination[1]
        if CurrentScene.illumination[1] > 0.7 then CurrentScene.illumination[1] = 0.7 end
    else
        self.appearCooldown = self.appearCooldown - delta
    end
    --Are you sure text
    if ui.quitButton.buttonText == Loca.mainMenu.quitConfirmation then
        ui.quitButton.confirmTimer = ui.quitButton.confirmTimer - delta
        if ui.quitButton.confirmTimer < 0 then
            ui.quitButton.buttonText = Loca.mainMenu.quit
            ui.quitButton.textFont = "disposable-droid"
        end
    end
    --camera positioning
    local camera = CurrentScene.camera
    --local x = -MenuUIOffset + math.cos((love.timer.getTime()))*10
    local y = math.sin((love.timer.getTime()))*10
    camera.position[1] = -MenuUIOffset--camera.position[1] + (x-camera.position[1])*2.5*delta
    camera.position[2] = camera.position[2] + (y-camera.position[2])*2.5*delta
end

return mainMenu