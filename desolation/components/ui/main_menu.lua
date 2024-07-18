local clickEvents = require("desolation.button_clickevents")
local moonshine = require("engine.lib.moonshine")

local mainMenu = ENGINE_COMPONENTS.scriptComponent.new()

function mainMenu:load()
    local ui = self.parent.UIComponent
    --[[
    ui.background = ui:newImage(
        {
            source = Assets.images.ui.menuBackground;
            scale = {0.7, 0.7};
            position = {480, 270};
        }
    )
    ]]--
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
            buttonText = Loca.mainMenu.campaign;
            buttonTextSize = 30;
        }
    )
    ui.extrasButton = ui:newTextButton(
        {
            position = {70, 240};
            buttonText = Loca.mainMenu.extra;
            buttonTextSize = 30;
            clickEvent = clickEvents.extrasButtonClick;
        }
    )
    ui.achievementsButton = ui:newTextButton(
        {
            position = {70, 280};
            buttonText = Loca.mainMenu.achievements;
            buttonTextSize = 30;
            clickEvent = clickEvents.achievementsButtonClick;
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
    ui.aboutButton = ui:newTextButton(
        {
            position = {70, 360};
            buttonText = Loca.mainMenu.about;
            buttonTextSize = 30;
        }
    )
    ui.changelogButton = ui:newTextButton(
        {
            position = {70, 400};
            buttonText = Loca.mainMenu.changelog;
            buttonTextSize = 30;
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
            font = "disposable-droid"
        }
    )
    --ui.blackCover = ui:newRectangle(
    --    {
    --        color = {1, 1, 1, 0};
    --        size = {960, 540};
    --    }
    --)
    --initial loading stuff
    if CurrentScene.mapCreator ~= nil then
        CurrentScene.mapCreator.script:loadMap("desolation/assets/maps/" .. Settings.menu_background .. ".json")
    end
    CurrentScene.uiShader = moonshine.chain(960, 540, moonshine.effects.glow)
    CurrentScene.gameShader.chain(moonshine.effects.gaussianblur)
    CurrentScene.gameShader.gaussianblur.sigma = 2.8
    CurrentScene.uiShader.glow.strength = 5
    CurrentScene.uiShader.glow.min_luma = 0.1
end

function mainMenu:update(delta)
    SoundManager:playSound(Assets.sounds["loop_menu"], Settings.vol_music)
    --Other stuff
    local ui = self.parent.UIComponent
    --UI Ofsetting
    self.parent.position[1] = MenuUIOffset
    ui.polarity.position[1] = 920 - MenuUIOffset
    ui.version.position[1] = 5 - MenuUIOffset
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