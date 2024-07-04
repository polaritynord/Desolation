local coreFuncs = require "coreFuncs"
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
            if temp then return cratePos end
        end
        cratePos = {
            math.uniform(-2200, 2200), math.uniform(-1200, 1200)
        }
    end
end

function openareaManager:determineRobotPos()
    local playerPos = CurrentScene.player.position
    local robotPos = {
        math.uniform(-2200, 2200), math.uniform(-1200, 1200)
    }
    while true do
        local d = coreFuncs.pointDistance(robotPos, playerPos)
        if d > 300 then
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
            text = "--- WAVE " .. self.wave .. " ---";
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
end

function openareaManager:load()
    self.wave = 1
    self.waveTimer = 14
    self.wavePrep = true
    self.newWaveSoundPlayed = true
    self.clearWaveSoundPlayed = true
    self.spawnedEnemies = 0
    self.enemySpawnCount = 0
    self.spawnCooldown = 0
    self.spawnTimer = 0
    self:setupUI()
    --Spawn beginning crates
    local beginningCrateAmount = 15
    for _ = 1, beginningCrateAmount do
        local cratePos = self:determineCratePos()
        local crateType = "crate"
        if math.random(0, 6) <= 3 then
            crateType = "crate_big"
        end
        local propData = {
            crateType, cratePos, math.uniform(0, math.pi*2),
            {
                {"loot", {"dynamic_loot"}}
            }
        }
        CurrentScene.mapCreator.script:spawnProp(propData)
    end
    --Spawn beginning barrels
    local beginningBarrelAmount = 9
    for _ = 1, beginningBarrelAmount do
        local cratePos = self:determineCratePos()
        local propData = {
            "barrel", cratePos, math.uniform(0, math.pi*2), {}
        }
        CurrentScene.mapCreator.script:spawnProp(propData)
    end
    --Spawn beginning explosive barrels
    local beginningExplosiveBarrelAmount = 6
    for _ = 1, beginningExplosiveBarrelAmount do
        local cratePos = self:determineCratePos()
        local propData = {
            "explosive_barrel", cratePos, math.uniform(0, math.pi*2), {}
        }
        CurrentScene.mapCreator.script:spawnProp(propData)
    end
    CurrentScene.camera.script.playerManualZoom = 0.8
    CurrentScene.camera.zoom = 4
    CurrentScene.camera.script.zoomSmoothness = 2.3
    SetGlobal("p_speed", 200)
end

function openareaManager:update(delta)
    if GamePaused then return end
    local ui = CurrentScene.hud.UIComponent

    self.waveTimer = self.waveTimer + delta
    if self.wavePrep then
        if self.waveTimer > 15 then
            self.newWaveSoundPlayed = false
            self.wavePrep = false
            self.waveTimer = 0
            self.spawnedEnemies = 0
            self.enemySpawnCount = 4 + (self.wave*(self.wave-1))/2
            self.spawnCooldown = 3--TODO
            ui.infinite.waveName.text = "--- WAVE " .. self.wave .. " ---"
            ui.infinite.waveDesc.text = "ELIMINATE ALL ROBOTS"
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
                self.wave = self.wave + 1
                self.clearWaveSoundPlayed = false
                ui.infinite.waveName.text = "WAVE CLEARED"
                ui.infinite.waveDesc.text = "PREPARE FOR THE NEXT WAVE"
            end
        end
    end

    --Update UI & sound effects
    if not self.newWaveSoundPlayed then
        self.newWaveSoundPlayed = true
        love.audio.setVolume(Settings.vol_master * Settings.vol_music)
        Assets.mapSounds["new_wave"]:stop()
        Assets.mapSounds["new_wave"]:play()
    end
    if not self.clearWaveSoundPlayed then
        self.clearWaveSoundPlayed = true
        love.audio.setVolume(Settings.vol_master * Settings.vol_music)
        Assets.mapSounds["wave_clear"]:stop()
        Assets.mapSounds["wave_clear"]:play()
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
end

return openareaManager