local coreFuncs = require "coreFuncs"
local robotLocationMarkers = require("desolation.components.robot_location_markers")
local object = require("engine.object")
local itemEventFuncs = require("desolation.components.item.item_event_funcs")
local infiniteScoreNotifs = require("desolation.components.infinite_score_notifs")
local openareaManager = ENGINE_COMPONENTS.scriptComponent.new()

function openareaManager:determineCratePos()
    local playerPos = CurrentScene.player.position
    local cratePos = {
        math.uniform(-2200, 2200), math.uniform(-1200, 1200)
    }
    while true do
        local d = coreFuncs.pointDistance(cratePos, playerPos)
        if d > 300 then
            local temp = true
            for _, prop in ipairs(CurrentScene.props.tree) do
                if coreFuncs.pointDistance(prop.position, cratePos) < 150 then
                    temp = false
                end
            end
            if coreFuncs.pointDistance(CurrentScene.player.position, cratePos) < 400 then
                temp = false
            end
            if temp then return cratePos end
        end
        cratePos = {
            math.uniform(-2200, 2200), math.uniform(-1200, 1200)
        }
    end
end

function openareaManager:setRandomCrateData()
    local cratePos = self:determineCratePos()
    local crateType = "crate"
    if math.random(0, 6) <= 3 then
        crateType = "crate_big"
    end
    local propData = {
        crateType, cratePos, math.uniform(0, math.pi*2),
        {
            {"loot", {}}
        }
    }
    local s = math.random()
    if s < 0.25 then
        propData[4][1][2][#propData[4][1][2]+1] = "medkit"
    elseif s >= 0.25 and s < 0.45 then
        propData[4][1][2][#propData[4][1][2]+1] = "battery"
    else
        propData[4][1][2][#propData[4][1][2]+1] = coreFuncs.infiniteModeAmmoType(CurrentScene.wave)
    end
    return propData
end

function openareaManager:determineRobotPos()
    local playerPos = CurrentScene.player.position
    local robotPos = {
        math.uniform(-2200, 2200), math.uniform(-1200, 1200)
    }
    while true do
        local d = coreFuncs.pointDistance(robotPos, playerPos)
        if d > 600 then
            local temp = true
            for _, prop in ipairs(CurrentScene.props.tree) do
                if coreFuncs.pointDistance(prop.position, robotPos) < 70 then
                    temp = false
                end
            end
            if temp then return robotPos end
        end
        robotPos = {
            math.uniform(-2200, 2200), math.uniform(-1200, 1200)
        }
    end
end

function openareaManager:setupUI()
    local ui = CurrentScene.hud.UIComponent
    ui.infinite = {}

    ui.infinite.waveName = ui:newTextLabel(
        {
            text = "--- WAVE " .. CurrentScene.wave .. " ---";
            position = {-10, 100};
            begin = "center";
            size = 48;
            color = {1, 1, 1, 0};
        }
    )
    ui.infinite.waveDesc = ui:newTextLabel(
        {
            text = "ELIMINATE ALL ROBOTS";
            position = {-10, 140};
            begin = "center";
            color = {1, 1, 1, 0};
        }
    )
    ui.infinite.scoreCounter = ui:newTextLabel(
        {
            text = "";
            position = {12, 10};
            size = 48;
            font = "disposable-droid-bold";
        }
    )
    ui.infinite.oldScore = CurrentScene.score
    ui.infinite.scoreDesc = ui:newTextLabel(
        {
            text = "";
            size = 24;
            font = "disposable-droid-bold";
            position = {12, 48};
        }
    )
    --Game over statistics
    self.statsTitle = CurrentScene.gameOver.UIComponent:newTextLabel(
        {
            size = 48;
            text = Loca.infiniteMode.gameOverTitle;
            position = {100, 80};
            color = {1, 1, 1, 0};
            font = "disposable-droid-bold";
        }
    )
    self.statsText = CurrentScene.gameOver.UIComponent:newTextLabel(
        {
            size = 30;
            position = {120, 140};
            color = {1, 1, 1, 0};
        }
    )
end

function openareaManager:load()
    self.waveTimer = 9
    self.wavePrep = true
    self.newWaveSoundPlayed = true
    self.clearWaveSoundPlayed = true
    self.spawnedEnemies = 0
    self.enemySpawnCount = 0
    self.spawnCooldown = 0
    self.spawnTimer = 0
    self.survivalTimer = 0
    self:setupUI()
    --Add robot markers object to scene
    local obj = object.new(CurrentScene.hud)
    obj:addComponent(ENGINE_COMPONENTS.imageComponent.new(obj))
    obj:addComponent(table.new(robotLocationMarkers))
    obj.script:load()
    CurrentScene.hud:addChild(obj)
    --Add score notifications object to scene
    obj = object.new(CurrentScene.hud)
    obj.name = "scoreNotifs"
    obj:addComponent(ENGINE_COMPONENTS.imageComponent.new(obj))
    obj:addComponent(table.new(infiniteScoreNotifs))
    obj.script:load()
    CurrentScene.hud:addChild(obj)
    --Spawn beginning crates
    for _ = 1, CurrentScene.amounts.crate do
        local propData = self:setRandomCrateData()
        CurrentScene.mapCreator.script:spawnProp(propData)
    end
    --Spawn beginning barrels
    for _ = 1, CurrentScene.amounts.barrel do
        local cratePos = self:determineCratePos()
        local propData = {
            "barrel", cratePos, math.uniform(0, math.pi*2), {}
        }
        CurrentScene.mapCreator.script:spawnProp(propData)
    end
    --Spawn beginning explosive barrels
    for _ = 1, CurrentScene.amounts.expBarrel do
        local cratePos = self:determineCratePos()
        local propData = {
            "explosive_barrel", cratePos, math.uniform(0, math.pi*2), {}
        }
        CurrentScene.mapCreator.script:spawnProp(propData)
    end
    CurrentScene.camera.script.playerManualZoom = 0.8
    CurrentScene.camera.zoom = 4
    CurrentScene.camera.script.zoomSmoothness = 2.3
    CurrentScene.shotsMissed = 0
    CurrentScene.shots = 0
    CurrentScene.kills = 0
    CurrentScene.barrelsExploded = 0
    CurrentScene.cratesBroken = 0
    SetGlobal("p_speed", 200)
end

function openareaManager:update(delta)
    if GamePaused then return end
    local ui = CurrentScene.hud.UIComponent

    self.waveTimer = self.waveTimer + delta
    if self.wavePrep then
        if self.waveTimer > 10 then
            self.newWaveSoundPlayed = false
            self.wavePrep = false
            self.waveTimer = 0
            self.spawnedEnemies = 0
            self.enemySpawnCount = 4 + (CurrentScene.wave*(CurrentScene.wave-1))/2
            self.spawnCooldown = math.uniform(2.5, 3.2) + CurrentScene.wave*0.07
            ui.infinite.waveName.text = "--- " .. Loca.infiniteMode.wave .. " " .. CurrentScene.wave .. " ---"
            ui.infinite.waveDesc.text = Loca.infiniteMode.eliminateAllRobots
        end
    else
        if self.spawnedEnemies < self.enemySpawnCount then
            self.spawnTimer = self.spawnTimer + delta
            if self.spawnTimer > self.spawnCooldown then
                local robotData = {
                    "robot", self:determineRobotPos()
                }
                CurrentScene.mapCreator.script:spawnNPC(robotData)
                self.spawnTimer = 0
                self.spawnedEnemies = self.spawnedEnemies + 1
            end
        else
            --Wait for player to clear all enemies
            if #CurrentScene.npcs.tree < 1 then
                self.wavePrep = true
                self.waveTimer = 0
                CurrentScene.wave = CurrentScene.wave + 1
                self.clearWaveSoundPlayed = false
                ui.infinite.waveName.text = "--- " .. Loca.infiniteMode.waveClear .. " ---"
                ui.infinite.waveDesc.text = Loca.infiniteMode.wavePrepare
                --Give player some loot (TODO)
                local player = CurrentScene.player
                if player.health < 100 then
                    itemEventFuncs.createHUDNotif("hud_acquire_medkit")
                    player.health = player.health + 30
                    CurrentScene.gameShaders.script.blueOffset = 255
                    if player.health > 100 then player.health = 100 end
                end
                if player.armor < 100 then
                    itemEventFuncs.createHUDNotif("hud_acquire_battery")
                    player.armor = player.armor + 25
                    CurrentScene.gameShaders.script.blueOffset = 255
                    if player.armor > 150 then player.armor = 150 end
                end
                --Score
                CurrentScene.hud.scoreNotifs.script:newNotif(Loca.infiniteMode.notifs.waveClear)
                CurrentScene.score = CurrentScene.score + 50
            end
        end
    end

    --Update UI & sound effects
    if not self.newWaveSoundPlayed then
        self.newWaveSoundPlayed = true
        SoundManager:restartSound(Assets.mapSounds["new_wave"], Settings.vol_sfx)
    end
    if not self.clearWaveSoundPlayed then
        self.clearWaveSoundPlayed = true
        SoundManager:restartSound(Assets.mapSounds["wave_clear"], Settings.vol_sfx)
    end
    --Wave cleared text
    if self.wavePrep then
        if self.waveTimer > 0.4 then
            if self.waveTimer < 7.4 then
                ui.infinite.waveName.color[4] = ui.infinite.waveName.color[4] + 4*delta
            else
                ui.infinite.waveName.color[4] = ui.infinite.waveName.color[4] - 2.5*delta
            end
        end
        --Prepare for next wave
        if self.waveTimer > 2.9 then
            if self.waveTimer < 7.4 then
                ui.infinite.waveDesc.color[4] = ui.infinite.waveDesc.color[4] + 4*delta
            else
                ui.infinite.waveDesc.color[4] = ui.infinite.waveDesc.color[4] - 2.5*delta
            end
        end
    else
        --Wave "x" text
        if self.waveTimer < 7 then
            ui.infinite.waveName.color[4] = ui.infinite.waveName.color[4] + 4*delta
        else
            ui.infinite.waveName.color[4] = ui.infinite.waveName.color[4] - 2.5*delta
        end
        if self.waveTimer > 2.5 then
            if self.waveTimer < 7 then
                ui.infinite.waveDesc.color[4] = ui.infinite.waveDesc.color[4] + 4*delta
            else
                ui.infinite.waveDesc.color[4] = ui.infinite.waveDesc.color[4] - 2.5*delta
            end
        end
    end
    --Make sure alpha is limited to 0 or 1
    if ui.infinite.waveName.color[4] < 0 then ui.infinite.waveName.color[4] = 0 end
    if ui.infinite.waveDesc.color[4] < 0 then ui.infinite.waveDesc.color[4] = 0 end
    if ui.infinite.waveName.color[4] > 1 then ui.infinite.waveName.color[4] = 1 end
    if ui.infinite.waveDesc.color[4] > 1 then ui.infinite.waveDesc.color[4] = 1 end
    --Score counter - set text
    ui.infinite.scoreCounter.text = CurrentScene.score
    --Score counter - update color
    if ui.infinite.scoreCounter.oldScore ~= CurrentScene.score then
        ui.infinite.scoreCounter.color = {1, 0, 0, 1}
    end
    ui.infinite.scoreCounter.color[2] = ui.infinite.scoreCounter.color[2] + (1-ui.infinite.scoreCounter.color[2])*9*delta
    ui.infinite.scoreCounter.color[3] = ui.infinite.scoreCounter.color[3] + (1-ui.infinite.scoreCounter.color[3])*9*delta
    --Score description
    local text = Loca.infiniteMode.highScore .. Achievements.infiniteHighScores[CurrentScene.difficulty] ..
                " (" .. string.upper(Loca.extrasMenu.infiniteDifficulties[CurrentScene.difficulty]) .. ")\n" ..
                Loca.infiniteMode.wave .. " " .. CurrentScene.wave
    ui.infinite.scoreDesc.text = text
    --Set high score
    if CurrentScene.score > Achievements.infiniteHighScores[CurrentScene.difficulty] then
        Achievements.infiniteHighScores[CurrentScene.difficulty] = CurrentScene.score
    end
    ui.infinite.scoreCounter.oldScore = CurrentScene.score

    --***If the player is dead***
    if CurrentScene.player.health > 0 then
        self.survivalTimer = self.survivalTimer + delta
        return
    end
    --Update stats
    --Convert survival seconds to XX:XX:XX format
    local timeSurvived = math.floor(self.survivalTimer/60) .. Loca.infiniteMode.minute .. math.floor(math.fmod(self.survivalTimer, 60)) .. Loca.infiniteMode.second
    local accuracy = math.floor((CurrentScene.shots-CurrentScene.shotsMissed)/CurrentScene.shots*100) .. "%"
    self.statsText.text = Loca.infiniteMode.statsScore .. CurrentScene.score .. "\n" ..
                        Loca.infiniteMode.statsTime .. timeSurvived .. "\n" .. Loca.infiniteMode.statsAccuracy .. accuracy .. "\n" ..
                        Loca.infiniteMode.statsWaves .. (CurrentScene.wave-1) .. "\n" .. Loca.infiniteMode.statsKills .. CurrentScene.kills .. "\n" ..
                        Loca.infiniteMode.statsBarrels .. CurrentScene.barrelsExploded .. "\n" .. Loca.infiniteMode.statsCrates .. CurrentScene.cratesBroken
    self.statsText.color[4] = self.statsText.color[4] + delta
    self.statsTitle.color[4] = self.statsTitle.color[4] + delta
    --Hide away score counter
    ui.infinite.scoreCounter.color[4] = 0
    ui.infinite.scoreDesc.color[4] = 0
end

return openareaManager