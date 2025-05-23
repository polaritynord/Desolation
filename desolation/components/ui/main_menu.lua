local clickEvents = require("desolation.button_clickevents")
local moonshine = require("engine.lib.moonshine")

local mainMenu = ENGINE_COMPONENTS.scriptComponent.new()

function mainMenu:loadShaders()
    if not Settings.shiny_menu then return end
    CurrentScene.uiShader = moonshine.chain(960, 540, moonshine.effects.glow)
    CurrentScene.uiShader.glow.strength = 5
    CurrentScene.uiShader.glow.min_luma = 0.1
    CurrentScene.gameShader.chain(moonshine.effects.gaussianblur)
    CurrentScene.gameShader.gaussianblur.sigma = 2.8
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
    ui.campaignButton = ui:newTextButton(
        {
            position = {70, 200};
            buttonText = Loca.mainMenu.campaign;
            buttonTextSize = 30;
            clickEvent = clickEvents.campaignButtonClick;
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
            clickEvent = clickEvents.aboutButtonClick;
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
    --Controller UI (TODO: NOT DONE WITH THIS AT ALL. GOT SIDETRACKED. RETURN LATER.)
    ui.controllerSelection = 1
    ui.controllerArrow = ui:newImage(
        {
            source = Assets.images.controller_selection;
            position = {50, 215};
            scale = {-0.8, 0.8};
            color = {1, 1, 1, 0};
        }
    )
    ui.controllerAxisMoved = false
    --initial loading stuff
    if CurrentScene.mapCreator ~= nil then
        CurrentScene.mapCreator.script:loadMap("desolation/assets/maps/" .. Settings.menu_background .. ".json")
    end
    --Cool shader stuff
    self:loadShaders()
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
    --Controller selection code
    if InputManager.inputType ~= "joystick" then return end
    if InputManager:getAxis(2) > 0.5 and not ui.controllerAxisMoved then
        ui.controllerAxisMoved = true
        ui.controllerSelection = ui.controllerSelection + 1
    end
    if InputManager:getAxis(2) < -0.5 and not ui.controllerAxisMoved then
        ui.controllerAxisMoved = true
        ui.controllerSelection = ui.controllerSelection - 1
    end
    if math.abs(InputManager:getAxis(2)) < 0.5 then ui.controllerAxisMoved = false end
    ui.controllerArrow.position[2] = 215 + 40*(ui.controllerSelection-1)
end

return mainMenu