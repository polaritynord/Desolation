local object = require("engine.object")
local itemScript = require("desolation.components.item.item_script")
local wallScript = require("desolation.components.wall_script")
local humanoidHandScript = require("desolation.components.humanoid_hand_script")
local itemEventFuncs = require("desolation.components.item.item_event_funcs")
local json = require("engine.lib.json")
local weaponManager = require("desolation.weapon_manager")
local particleFuncs = require("desolation.particle_funcs")

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
    prop.targetable = propData[prop.name].targetable or false
    if propData[prop.name].piercable ~= nil then
        prop.piercable = propData[prop.name].piercable
    else
        prop.piercable = true
    end
    prop.position = v[2]
    prop.rotation = v[3]*math.pi/180
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

function mapCreator:loadMap(path, resetGlobals)
    self.mapBaseData = {}
    --dunno why I had to write it like this
    if resetGlobals == nil or resetGlobals == true then
        Globals:load()
    end
    self.ambience = nil
    --read & convert to lua table
    local data = love.filesystem.read("desolation/assets/maps/" .. path .. ".json")
    data = json.decode(data)
    self.parent.prettyMapName = data.name or "Map"
    self.parent.mapName = path
    --Set illumination
    CurrentScene.illumination = data.illumination or {0.4, 0.4, 0.4}
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
            tile.material = v[4] or "concrete"
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
            --Add light polygon data
            if wall.name ~= "invisible" then
                CurrentScene:addLightPolygon(
                    {
                        wall.position[1], wall.position[2], --topleft
                        wall.position[1]+64*wall.scale[1], wall.position[2], --topright
                        wall.position[1]+64*wall.scale[1], wall.position[2]+64*wall.scale[2], --bottomright
                        wall.position[1], wall.position[2]+64*wall.scale[2] --bottomleft
                    }
                )
            end
            --Add to scene tree
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
    --load lights
    if data.lights ~= nil then
        for _, light in ipairs(data.lights) do --x, y, radius, r, g, b, a
            CurrentScene:addLight(unpack(light))
        end
    end
    --ambience
    if Assets.mapSounds["ambience"] ~= nil then
        Assets.mapSounds["ambience"]:setLooping(true)
        SoundManager:playSound(Assets.mapSounds["ambience"], Settings.vol_world)
    end
    --player data
    self.parent.cameraBoundaries = data.playerData.cameraBoundaries
    self.parent.allowZoom = data.playerData.allowZoom
    if CurrentScene.player ~= nil then
        local player = CurrentScene.player
        --If no previous playerData is passed through
        if self.parent.mapTransitionPlayer == nil then
            player.position = data.playerData.position
            CurrentScene.camera.position = data.playerData.cameraPosition
            --load up beginner inventory
            local inv = data.playerData.beginnerInventory
            if inv ~= nil then
                --load weapons
                for i, v in ipairs(inv.weapons) do
                    if v == nil or v == "null" then
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
            if data.playerData.armorAcquired ~= nil then
                player.armorAcquired = data.playerData.armorAcquired
            else
                player.armorAcquired = true
            end
            if data.playerData.flashlightAcquired ~= nil then
                player.flashlightAcquired = data.playerData.flashlightAcquired
            else
                player.flashlightAcquired = false
            end
        else
            --If the player is, indeed, coming from another map
            --(just set the position)
            local oldPlayer = self.parent.mapTransitionPlayer
            player.flashlightOn = oldPlayer.flashlightOn
            player.armorAcquired = oldPlayer.armorAcquired
            player.flashlightAcquired = oldPlayer.flashlightAcquired
            player.inventory = table.new(oldPlayer.inventory)
            player.stamina = oldPlayer.stamina
            player.armor = oldPlayer.armor
            player.health = oldPlayer.health
            --gosh I hope I'm not doing memory leaks with this shit
        end
    end
    MapChanged = true
    self.parent.changingMapTo = nil
    self.parent.mapTransitionPlayer = nil
    self.parent.saveableMap = data.saveable
end

function mapCreator:loadSave(path)
    local saveFile = love.filesystem.read(path)
    local saveData = json.decode(saveFile)
    self:loadMap(saveData.mapName, true)
    --Set player data
    local player = CurrentScene.player
    player.health = saveData.playerData.health
    player.armor = saveData.playerData.armor
    player.stamina = saveData.playerData.stamina
    player.armorAcquired = saveData.playerData.armorAcquired
    player.flashlightAcquired = saveData.playerData.flashlightAcquired
    player.flashlightOn = saveData.playerData.flashlightOn
    for i, weapon in ipairs(saveData.playerData.beginnerInventory.weapons) do
        if weapon ~= nil and weapon ~= "null" then
            local weaponObj = weaponManager[weapon[1]].new()
            weaponObj.magAmmo = weapon[2]
            player.inventory.weapons[i] = weaponObj
        else
            player.inventory.weapons[i] = nil
        end
    end
    for _, ammunition in ipairs(saveData.playerData.beginnerInventory.ammunition) do
        player.inventory.ammunition[ammunition[1]] = ammunition[2]
    end
end

function mapCreator:createExplosion(position, radius, intensity)
    --add light data
    if GetGlobal("fullbright") < 1 then
        self.explosionLights[#self.explosionLights+1] = CurrentScene:addLight(
            position[1], position[2], 1000, 0.98, 0.45, 0.01, 1
        )
    end
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
        particleFuncs.createExplosionParticles(particleComp, position, radius)
    end
    --play sound
    local sound = Assets.sounds["explosion"]
    SoundManager:restartSound(sound, Settings.vol_world, position, true)
end

function mapCreator:updateExplosionLights(delta)
    if GetGlobal("fullbright") > 0 then return end
    for i, light in ipairs(self.explosionLights) do
        light.a = light.a - 0.8*delta
        if light.a <= 0 then
            table.remove(self.explosionLights, i)
            CurrentScene:removeLight(light)
        end
    end
end

function mapCreator:saveProgress()
    local player = CurrentScene.player
    local now = os.date("*t")
    print(now.month)
    local saveData = {
        title = now.day .. "." .. now.month .. "." .. now.year .. " " .. now.hour .. "." .. now.min .. " " .. self.parent.prettyMapName,
        playerData = {
            health = player.health,
            armor = player.armor,
            stamina = player.stamina,
            beginnerInventory = {
                weapons = {"null", "null", "null"},
                ammunition = {}
            },
            armorAcquired = player.armorAcquired,
            flashlightAcquired = player.flashlightAcquired,
            flashlightOn = player.flashlightOn
        },
        prettyMapName = self.parent.prettyMapName,
        mapName = self.parent.mapName
    }
    --Convert player's inventory to the type that map files use
    for name, ammoCount in pairs(player.inventory.ammunition) do
        local table = {name, ammoCount}
        saveData.playerData.beginnerInventory.ammunition[#saveData.playerData.beginnerInventory.ammunition+1] = table
    end
    --This is definitely going to be comedy for people analyzing my code in the future
    for i = 1,3 do
        if player.inventory.weapons[i] ~= nil then
            local weapon = player.inventory.weapons[i]
            local table = {weapon.name, weapon.magAmmo}
            saveData.playerData.beginnerInventory.weapons[i] = table
        else
            saveData.playerData.beginnerInventory.weapons[i] = "null"
        end
    end
    --Encode file and write
    love.filesystem.write("saves/" .. saveData.title .. ".sav", json.encode(saveData))
end

function mapCreator:load()
    GamePaused = false
    self.parent.propData = love.filesystem.read(GAME_DIRECTORY .. "/assets/props.json")
    self.parent.propData = json.decode(self.parent.propData)
    self.parent.itemData = love.filesystem.read(GAME_DIRECTORY .. "/assets/items.json")
    self.parent.itemData = json.decode(self.parent.itemData)
    self.parent.npcData = love.filesystem.read(GAME_DIRECTORY .. "/assets/npcs.json")
    self.parent.npcData = json.decode(self.parent.npcData)
    self.parent.changingMapTo = nil
    self.parent.mapTransitionPlayer = nil
    self.explosionLights = {}
    self.parent.saveableMap = false
    self.parent.mapName = ""
    self.parent.prettyMapName = "Map"
end

function mapCreator:update(delta)
    self:updateExplosionLights(delta)
    --Ambience stuff
    local ambienceSource = Assets.mapSounds["ambience"]
    if ambienceSource == nil then return end
    if GamePaused then
        ambienceSource:pause()
    else
        ambienceSource:setVolume(Settings.vol_master * Settings.vol_world)
        ambienceSource:play()
    end
end

return mapCreator