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

function openareaManager:setupUI()
    local ui = CurrentScene.hud.UIComponent
    ui.infinite = {}

    ui.infinite.waveName = ui:newTextLabel(
        {
            text = "--- WAVE " .. self.wave .. " ---";
            position = {-30, 100};
            begin = "center";
            size = 48;
            color = {1, 1, 1, 0};
        }
    )
    ui.infinite.waveDesc = ui:newTextLabel(
        {
            text = "ELIMINATE ALL ROBOTS";
            position = {-30, 140};
            begin = "center";
            color = {1, 1, 1, 0};
        }
    )
end

function openareaManager:load()
    self.wave = 1
    self.waveTimer = 7
    self.wavePrep = true
    self.newWaveSoundPlayed = false
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
    print(self.waveTimer, self.wavePrep)
    --Wave cycle
    self.waveTimer = self.waveTimer + delta
    if self.wavePrep then
        self.newWaveSoundPlayed = false
        if self.waveTimer > 8 then
            self.wavePrep = false
            self.waveTimer = 0
        end
    end
    local ui = CurrentScene.hud.UIComponent
    --Update UI stuff
    if not self.wavePrep then
        if self.waveTimer > 1 then
            --Play sound effect
            if not self.newWaveSoundPlayed then
                self.newWaveSoundPlayed = true
                love.audio.setVolume(Settings.vol_master * Settings.vol_music)
                Assets.mapSounds["new_wave"]:play()
            end
            --Make texts visible
            if self.waveTimer < 7 then
                ui.infinite.waveName.color[4] = ui.infinite.waveName.color[4] + 4*delta
            end
            if self.waveTimer > 3 and self.waveTimer < 7 then
                ui.infinite.waveDesc.color[4] = ui.infinite.waveDesc.color[4] + 4*delta
            end
            --Hide both of the texts
            if self.waveTimer > 7 then
                ui.infinite.waveName.color[4] = ui.infinite.waveName.color[4] - 2.5*delta
                ui.infinite.waveDesc.color[4] = ui.infinite.waveDesc.color[4] - 2.5*delta
            end
            --Make sure alpha is limited to 0 or 1
            if ui.infinite.waveName.color[4] < 0 then ui.infinite.waveName.color[4] = 0 end
            if ui.infinite.waveDesc.color[4] < 0 then ui.infinite.waveDesc.color[4] = 0 end
            if ui.infinite.waveName.color[4] > 1 then ui.infinite.waveName.color[4] = 1 end
            if ui.infinite.waveDesc.color[4] > 1 then ui.infinite.waveDesc.color[4] = 1 end
        end
    end
end

return openareaManager