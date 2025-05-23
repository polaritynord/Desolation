local object = require("engine.object")
local itemScript = require("desolation.components.item.item_script")
local wallScript = require("desolation.components.wall_script")
local humanoidHandScript = require("desolation.components.humanoid_hand_script")
local itemEventFuncs = require("desolation.components.item.item_event_funcs")
local json = require("engine.lib.json")
local weaponManager = require("desolation.weapon_manager")
local particleFuncs = require("desolation.particle_funcs")
local coreFuncs = require("coreFuncs")

local mapCreator = ENGINE_COMPONENTS.scriptComponent.new()

function mapCreator:spawnItem(v)
    local item = object.new(CurrentScene.items)
    --Return if the item doesnt exist in the database
    if self.parent.itemData[v[1]] == nil then
        ConsoleLog("WARNING: Couldn't spawn item " .. v[1] .. ", nonexistant.")
        return
    end
    item.name = v[1]
    item:addComponent(table.new(itemScript))
    item.position = v[2]
    item.rotation = math.pi*2 * (v[3]/360)
    --Set despawning attribute
    if item.name == "weapon" then
        item.notDespawning = true
    else
        if v[4] ~= nil then item.notDespawning = v[4] else item.notDespawning = false end
    end
    item.scale = table.new(self.parent.itemData[item.name].scale)
    item.pickupEvent = itemEventFuncs[self.parent.itemData[item.name].pickupEvent]
    --weapon data
    if item.name == "weapon" then
        item.weaponData = weaponManager[v[4]].new()
    end
    item.script:load()
    --Some bs I did for robot loots to have velocity
    --if item.name ~= "weapon" then item.velocity = v[4] end
    CurrentScene.items:addChild(item)
    return item
end

function mapCreator:spawnProp(v)
    local propData = self.parent.propData
    --Return if the prop doesnt exist in the database
    if propData[v[1]] == nil then
        ConsoleLog("WARNING: Couldn't spawn prop " .. v[1] .. ", nonexistant.")
        return
    end
    local prop = object.new(CurrentScene.props)
    prop.name = v[1]
    prop.collidable = propData[prop.name].collidable or false
    prop.movable = propData[prop.name].movable or false
    prop.invincible = propData[prop.name].invincible or false
    prop.material = propData[prop.name].material or "wood"
    prop.health = propData[prop.name].health or 100
    prop.mass = propData[prop.name].mass or 0.05
    prop.position = v[2]
    prop.rotation = v[3]
    --custom variables
    for _, k in ipairs(v[4]) do
        prop[k[1]] = k[2]
    end
    --load custom script file
    --TODO: make these scripts get stored in a pool to prevent loading it over and over again!
    if propData[prop.name] ~= nil and propData[prop.name].script ~= nil then
        local comp = love.filesystem.load(propData[prop.name].script .. ".lua")
        comp = comp()
        prop:addComponent(comp)
        comp:load()
    end
    CurrentScene.props:addChild(prop)
end

function mapCreator:spawnNPC(v)
    local npcData = self.parent.npcData
    --Return if the NPC doesnt exist in the database
    if npcData[v[1]] == nil then
        ConsoleLog("WARNING: Couldn't spawn NPC " .. v[1] .. ", nonexistant.")
        return
    end
    local npc = object.new(CurrentScene.npcs)
    npc.name = v[1]
    npc.position = v[2]
    npc.imageComponent = ENGINE_COMPONENTS.imageComponent.new(npc)
    npc.mass = npcData[npc.name].mass or 10
    --add hand object
    local hand = object.new(npc)
    hand.name = "hand"
    hand.imageComponent = ENGINE_COMPONENTS.imageComponent.new(hand)
    hand:addComponent(table.new(humanoidHandScript))
    hand.script:load()
    npc:addChild(hand)
    --load custom script file
    if npcData[npc.name] ~= nil and npcData[npc.name].script ~= nil then
        local comp = love.filesystem.load(npcData[npc.name].script .. ".lua")
        comp = comp()
        npc:addComponent(comp)
        comp:load()
    end
    CurrentScene.npcs:addChild(npc)
end

function mapCreator:loadMap(path)
    Globals:load()
    self.ambience = nil
    --read & convert to lua table
    local data = love.filesystem.read(path)
    data = json.decode(data)
    --Load map assets
    Assets:unloadMapAssets()
    if data.assets ~= nil then
        --Load images
        if data.assets.images ~= nil then
            for _, img in ipairs(data.assets.images) do
                Assets.mapImages[img[1]] = love.graphics.newImage(img[2])
            end
        end
        --Load sounds
        if data.assets.sounds ~= nil then
            for _, sound in ipairs(data.assets.sounds) do
                Assets.mapSounds[sound[1]] = love.audio.newSource(sound[2], sound[3])
            end
        end
    end
    --load tiles
    if data.tiles ~= nil then
        for _, v in ipairs(data.tiles) do
            local tile = object.new(CurrentScene.tiles)
            --maybe set name?
            tile.imageComponent = ENGINE_COMPONENTS.imageComponent.new(tile, Assets.mapImages["tile_" .. v[1]])
            tile.imageComponent.layer = 5
            tile.scale = {2, 2}
            tile.position = {v[2]*1024, v[3]*1024}
            CurrentScene.tiles:addChild(tile)
        end
    end
    --load items
    if data.items ~= nil then
        --load items
        for _, v in ipairs(data.items) do
            self:spawnItem(v)
        end
    end
    --load walls
    if data.walls ~= nil then
        for _, v in ipairs(data.walls) do
            local wall = object.new(CurrentScene.walls)
            wall.name = v[1]
            wall.material = "concrete" --TODO material types for walls
            wall:addComponent(table.new(wallScript))
            wall.position = {v[2][1]*64, v[2][2]*64}
            wall.scale = v[3]
            wall.script:load()
            CurrentScene.walls:addChild(wall)
        end
    end
    --load props
    if data.props ~= nil then
        for _, v in ipairs(data.props) do
            self:spawnProp(v)
        end
    end
    --load npc's
    if data.npcs ~= nil then
        for _, v in ipairs(data.npcs) do
            self:spawnNPC(v)
        end
    end
    --player data
    if CurrentScene.player == nil then return end
    local player = CurrentScene.player
    player.position = data.playerData.position
    CurrentScene.camera.position = data.playerData.cameraPosition
    --ambience
    if Assets.mapSounds["ambience"] ~= nil then
        Assets.mapSounds["ambience"]:setLooping(true)
        SoundManager:playSound(Assets.mapSounds["ambience"], Settings.vol_world)
    end
    self.parent.allowZoom = data.playerData.allowZoom
    self.parent.cameraBoundaries = data.playerData.cameraBoundaries
    --load up beginner inventory
    local inv = data.playerData.beginnerInventory
    if inv ~= nil then
        --load wepaons
        for i, v in ipairs(inv.weapons) do
            if v == nil then
                player.inventory.weapons[i] = nil
            else
                player.inventory.weapons[i] = weaponManager[v[1]].new()
                player.inventory.weapons[i].magAmmo = v[2]
            end
        end
        --load ammunition
        for _, v in ipairs(inv.ammunition) do
            player.inventory.ammunition[v[1]] = v[2]
        end
    end
    player.health = data.playerData.health
    player.armor = data.playerData.armor
end

function mapCreator:createExplosion(position, radius, intensity)
    --iterate through props
    for _, prop in ipairs(CurrentScene.props.tree) do
        if prop.script.explosionEvent then prop.script:explosionEvent(position, radius, intensity) end
        --chain reaction achievement
        if prop.name == "explosive_barrel" and prop.health <= 0 then
            GiveAchievement("chainReaction")
        end
    end
    --iterate through items
    for _, item in ipairs(CurrentScene.items.tree) do
        item.script:explosionEvent(position, radius, intensity)
    end
    --alert the player
    CurrentScene.player.script:explosionEvent(position, radius, intensity)
    --iterate through NPC's
    for _, npc in ipairs(CurrentScene.npcs.tree) do
        npc.script:explosionEvent(position, radius, intensity)
        --NOTE: Hardcoded this part to give extra points if the robot was taken down with an explosion
        --in infinite mode.
        if npc.health <= 0 and CurrentScene.score ~= nil then
            CurrentScene.hud.scoreNotifs.script:newNotif(Loca.infiniteMode.notifs.explosionBonus)
            CurrentScene.score = CurrentScene.score + 15
        end
    end
    --explosion effects
    if Settings.explosion_particles then
        local particleComp = CurrentScene.bullets.particleComponent
        particleFuncs.createExplosionParticles(particleComp, position)
    end
    --play sound
    local sound = Assets.sounds["explosion"]
    SoundManager:restartSound(sound, Settings.vol_world, position, true)
end

function mapCreator:load()
    GamePaused = false
    self.parent.propData = love.filesystem.read(GAME_DIRECTORY .. "/assets/props.json")
    self.parent.propData = json.decode(self.parent.propData)
    self.parent.itemData = love.filesystem.read(GAME_DIRECTORY .. "/assets/items.json")
    self.parent.itemData = json.decode(self.parent.itemData)
    self.parent.npcData = love.filesystem.read(GAME_DIRECTORY .. "/assets/npcs.json")
    self.parent.npcData = json.decode(self.parent.npcData)
end

function mapCreator:update(delta)
    local ambienceSource = Assets.mapSounds["ambience"]
    if ambienceSource == nil then return end
    if GamePaused then
        ambienceSource:pause()
    else
        ambienceSource:setVolume(Settings.vol_master * Settings.vol_music)
        ambienceSource:play()
    end
end

return mapCreator