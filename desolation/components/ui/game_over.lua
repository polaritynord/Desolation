local gameOver = ENGINE_COMPONENTS.scriptComponent.new()
local json = require("engine.lib.json")
local coreFuncs = require("coreFuncs")

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
            position = {230, 400};
            buttonText = "MAIN MENU";
            buttonTextSize = 36;
            textFont = "disposable-droid-bold";
            clickEvent = function ()
                --TODO add saving progress to story mode (adjust the text label too maybe)
                love.filesystem.write("settings.json", json.encode(Settings))
                love.filesystem.write("achievements.json", json.encode(Achievements))
                local scene = LoadScene("desolation/assets/scenes/main_menu2.json")
                SetScene(scene)
            end;
            color = {1, 1, 1, 0};
            hoverEvent = function () end;
            unhoverEvent = function () end;
        }
    )
    ui.replayButton = CurrentScene.gameOver.UIComponent:newTextButton(
        {
            position = {570, 400};
            buttonText = "TRY AGAIN";
            buttonTextSize = 36;
            textFont = "disposable-droid-bold";
            clickEvent = function ()
                --If infinite mode, restart the game with the same configurations
                --TODO add the story time resetting here as well (and playground)
                if CurrentScene.difficulty == nil then
                    if CurrentScene.mapCreator.prettyMapName == "Playground" then
                        local scene = LoadScene("desolation/assets/scenes/game.json")
                        SetScene(scene)
                        scene.mapCreator.script:loadMap("playground_old")
                    end
                else
                    --INFINITE GAME MODE
                    local scene = LoadScene("desolation/assets/scenes/game.json")
                    scene.difficulty = CurrentScene.difficulty
                    scene.amounts = CurrentScene.amounts
                    scene.regenerateProps = CurrentScene.regenerateProps
                    scene.score = 0
                    scene.wave = 1
                    SetScene(scene)
                    scene.mapCreator.script:loadMap("infinite_openarea")
                end
            end;
            color = {1, 1, 1, 0};
            hoverEvent = function () end;
            unhoverEvent = function () end;
        }
    )
    ui.title.wrapLimit = 700
    ui.controllerButtons = {ui.mainMenuButton, ui.replayButton}
end

function gameOver:update(delta)
    local player = CurrentScene.player
    if player == nil then return end --NOTE not the best way to fix the error I faced
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
        if ui.title.color[4] > 1.3 then
            ui.mainMenuButton.color[4] = ui.mainMenuButton.color[4] + (0.5+coreFuncs.boolToNum(ui.mainMenuButton.mouseHovering)*0.5-ui.mainMenuButton.color[4])*8*delta
            ui.replayButton.color[4] = ui.replayButton.color[4] + (0.5+coreFuncs.boolToNum(ui.replayButton.mouseHovering)*0.5-ui.replayButton.color[4])*8*delta
        end
    end
    ui.mainMenuButton.enabled = player.health <= 0 and ui.title.color[4] > 1.3
    ui.replayButton.enabled = ui.mainMenuButton.enabled
end

return gameOver