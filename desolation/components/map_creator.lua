local object = require("engine.object")
local itemScript = require("desolation.components.item.item_script")
local wallScript = require("desolation.components.wall_script")
local itemEventFuncs = require("desolation.components.item.item_event_funcs")
local json = require("engine.lib.json")
local weaponManager = require("desolation.weapon_manager")

local mapCreator = ENGINE_COMPONENTS.scriptComponent.new()

function mapCreator:loadMap(path)
    local creator = self.parent
    --read & convert to lua table
    local data = love.filesystem.read(path)
    data = json.decode(data)
    --load tiles
    if data.tiles ~= nil then
        for _, v in ipairs(data.tiles) do
            local tile = object.new(CurrentScene.tiles)
            --maybe set name?
            tile.imageComponent = ENGINE_COMPONENTS.imageComponent.new(tile, Assets.images.tiles[v[1]])
            tile.imageComponent.layer = 3
            tile.scale = {2, 2}
            tile.position = {v[2]*1024, v[3]*1024}
            CurrentScene.tiles:addChild(tile)
        end
    end
    --load items
    if data.items ~= nil then
        --load items list & decode it
        local items = love.filesystem.read(GAME_NAME .. "/assets/items.json")
        items = json.decode(items)
        --load items
        for _, v in ipairs(data.items) do
            local item = object.new(CurrentScene.items)
            item.name = v[1]
            item:addComponent(table.new(itemScript))
            item.position = v[2]
            item.rotation = math.pi*2 * (v[3]/360)
            item.scale = items[item.name].scale
            item.pickupEvent = itemEventFuncs[items[item.name].pickupEvent]
            --weapon data
            if item.name == "weapon" then
                print(v[1])
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
        local props = love.filesystem.read(GAME_NAME .. "/assets/props.json")
        props = json.decode(props)
        for _, v in ipairs(data.props) do
            local prop = object.new(CurrentScene.props)
            prop.name = v[1]
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
            prop.position = v[2]
            prop.rotation = v[3]
            CurrentScene.props:addChild(prop)
        end
    end
    --player data
    if CurrentScene.player == nil then return end
    local player = CurrentScene.player
    player.position = data.playerData.position
    CurrentScene.camera.position = data.playerData.cameraPosition
end

function mapCreator:load()
    local obj = self.parent
    GamePaused = false
end

function mapCreator:update(delta)
    if GamePaused then return end
    --self.parent.tile.imageComponent.color = {Settings.brightness, Settings.brightness, Settings.brightness, 1}
end

return mapCreator