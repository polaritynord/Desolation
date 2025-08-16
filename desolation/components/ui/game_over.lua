local gameOver = ENGINE_COMPONENTS.scriptComponent.new()
local json = require("engine.lib.json")
local buttonEvents = require("desolation.button_clickevents")

function gameOver:load()
    local ui = self.parent.UIComponent
    ui.rectangle = ui:newRectangle(
        {
            size = {960, 540};
            color = {0, 0, 0, 1};
        }
    )
    ui.title = CurrentScene.gameOver.UIComponent:newTextLabel(
        {
            size = 96;
            begin = "center";
            text = Loca.infiniteMode.gameOverTitle;
            position = {130, 80};
            color = {1, 1, 1, 0};
            font = "disposable-droid-bold";
        }
    )
    ui.mainMenuButton = CurrentScene.gameOver.UIComponent:newTextButton(
        {
            position = {230, 360};
            buttonText = "MAIN MENU";
            buttonTextSize = 36;
            textFont = "disposable-droid-bold";
            hoverEvent = buttonEvents.fadeIn;
            unhoverEvent =  buttonEvents.fadeOut;
            clickEvent = function ()
                love.filesystem.write("settings.json", json.encode(Settings))
                love.filesystem.write("achievements.json", json.encode(Achievements))
                local scene = LoadScene("desolation/assets/scenes/main_menu2.json")
                SetScene(scene)
            end
        }
    )
    ui.replayButton = CurrentScene.gameOver.UIComponent:newTextButton(
        {
            position = {570, 360};
            buttonText = "TRY AGAIN";
            buttonTextSize = 36;
            textFont = "disposable-droid-bold";
            hoverEvent = buttonEvents.fadeIn;
            unhoverEvent =  buttonEvents.fadeOut;
        }
    )
    ui.title.wrapLimit = 700
end

function gameOver:update(delta)
    local player = CurrentScene.player
    local ui = self.parent.UIComponent
    if player.health > 0 then
        local mapCreator = CurrentScene.mapCreator
        if mapCreator.changingMapTo == nil then
            --opening black fade away
            ui.rectangle.color[4] = ui.rectangle.color[4] - delta
            if ui.rectangle.color[4] < 0 then ui.rectangle.color[4] = 0 end
        else
            --black fade in
            ui.rectangle.color[4] = ui.rectangle.color[4] + delta
            if ui.rectangle.color[4] > 1.2 then
                local temp = CurrentScene.mapCreator.mapTransitionPlayer
                local scene = LoadScene("desolation/assets/scenes/game.json")
                SetScene(scene)
                scene.mapCreator.mapTransitionPlayer = temp
                scene.mapCreator.script:loadMap(mapCreator.changingMapTo, false)
                --Save progress
                if not CurrentScene.mapCreator.saveableMap then return end
                CurrentScene.mapCreator.script:saveProgress()
                CurrentScene.keyHints.UIComponent.progressSaveText.color[4] = 1
                --SoundManager:restartSound(Assets.defaultSounds.save, Settings.vol_sfx)
            end
        end
    else
        --game over screen background
        ui.rectangle.color = {1, 0, 0, ui.rectangle.color[4]}
        ui.rectangle.color[4] = ui.rectangle.color[4] + (0.8-ui.rectangle.color[4])*8*delta
        ui.title.color[4] = ui.title.color[4] + 0.6*delta
    end
end

return gameOver