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

function mapCreator:loadMap(path)
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
    end
    --load tiles
    if data.tiles ~= nil then
        for _, v in ipairs(data.tiles) do
            local tile = object.new(CurrentScene.tiles)
            --maybe set name?
            tile.imageComponent = ENGINE_COMPONENTS.imageComponent.new(tile, Assets.mapImages["tile_" .. v[1]])
            tile.imageComponent.layer = 3
            tile.scale = {2, 2}
            tile.position = {v[2]*1024, v[3]*1024}
            CurrentScene.tiles:addChild(tile)
        end
    end
    --load items
    if data.items ~= nil then
        --load items list & decode it
        self.parent.itemData = love.filesystem.read(GAME_DIRECTORY .. "/assets/items.json")
        self.parent.itemData = json.decode(self.parent.itemData)
        --load items
        for _, v in ipairs(data.items) do
            local item = object.new(CurrentScene.items)
            item.name = v[1]
            item:addComponent(table.new(itemScript))
            item.position = v[2]
            item.rotation = math.pi*2 * (v[3]/360)
            item.scale = self.parent.itemData[item.name].scale
            item.pickupEvent = itemEventFuncs[self.parent.itemData[item.name].pickupEvent]
            --weapon data
            if item.name == "weapon" then
                item.weaponData = weaponManager[v[4]].new()
            end
            item.script:load()
            CurrentScene.items:addChild(item)
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
        --load items list & decode it
        local props = love.filesystem.read(GAME_DIRECTORY .. "/assets/props.json")
        props = json.decode(props)
        for _, v in ipairs(data.props) do
            local prop = object.new(CurrentScene.props)
            prop.name = v[1]
            prop.collidable = props[prop.name].collidable or false
            prop.movable = props[prop.name].movable or false
            prop.invincible = props[prop.name].invincible or false
            prop.material = props[prop.name].material or "wood"
            prop.health = props[prop.name].health or 100
            prop.mass = props[prop.name].mass or 0.05
            prop.position = v[2]
            prop.rotation = v[3]
            --custom variables
            for _, k in ipairs(v[4]) do
                prop[k[1]] = k[2]
            end
            --load custom script file
            if props[prop.name] ~= nil and props[prop.name].script ~= nil then
                local comp = dofile(props[prop.name].script .. ".lua")
                prop:addComponent(comp)
                comp:load()
            end
            CurrentScene.props:addChild(prop)
        end
    end
    --load npc's
    if data.npcs ~= nil then
        --load npcs list & decode it
        local npcs = love.filesystem.read(GAME_DIRECTORY .. "/assets/npcs.json")
        npcs = json.decode(npcs)
        for _, v in ipairs(data.npcs) do
            local npc = object.new(CurrentScene.npcs)
            npc.name = v[1]
            npc.position = v[2]
            npc.imageComponent = ENGINE_COMPONENTS.imageComponent.new(npc)
            --add hand object
            local hand = object.new(npc)
            hand.name = "hand"
            hand.imageComponent = ENGINE_COMPONENTS.imageComponent.new(hand)
            hand:addComponent(table.new(humanoidHandScript))
            hand.script:load()
            npc:addChild(hand)
            --load custom script file
            if npcs[npc.name] ~= nil and npcs[npc.name].script ~= nil then
                local comp = dofile(npcs[npc.name].script .. ".lua")
                npc:addComponent(comp)
                comp:load()
            end
            CurrentScene.npcs:addChild(npc)
        end
    end
    --player data
    if CurrentScene.player == nil then return end
    local player = CurrentScene.player
    player.position = data.playerData.position
    CurrentScene.camera.position = data.playerData.cameraPosition
    --ambience
    if data.ambience ~= nil then
        self.ambience = love.audio.newSource(data.ambience, "stream")
        self.ambience:setLooping(true)
        self.ambience:play()
    end
end

function mapCreator:createExplosion(position, radius, intensity)
    --iterate through props
    for _, prop in ipairs(CurrentScene.props.tree) do
        if prop.script.explosionEvent then prop.script:explosionEvent(position, radius, intensity) end
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
    end
    --explosion effects
    if Settings.explosion_particles then
        local particleComp = CurrentScene.bullets.particleComponent
        particleFuncs.createExplosionParticles(particleComp, position)
    end
    --determine the volume of sound based on distance
    local camDistance = coreFuncs.pointDistance(CurrentScene.camera.position, position)
    local volume = Settings.vol_master * Settings.vol_world * (radius/camDistance)
    --play sound
    local sound = Assets.sounds["explosion"]
    sound:stop()
    sound:setVolume(volume)
    --sound:setPosition((position[1]-CurrentScene.camera.position[1])/100, 1, 0) --TODO too quiet, needs fix
    sound:play()
end

function mapCreator:load()
    GamePaused = false
end

function mapCreator:update(delta)
    if self.ambience == nil then return end
    if GamePaused then
        self.ambience:pause()
    else
        self.ambience:setVolume(Settings.vol_master * Settings.vol_music)
        self.ambience:play()
    end
    --self.parent.tile.imageComponent.color = {Settings.brightness, Settings.brightness, Settings.brightness, 1}
end

return mapCreator