local coreFuncs = require("coreFuncs")

local itemScript = ENGINE_COMPONENTS.scriptComponent.new()

function itemScript:load()
    local item = self.parent
    if item.name == "weapon" then
        item.imageComponent = ENGINE_COMPONENTS.imageComponent.new(item, Assets.images["weapon_" .. string.lower(item.weaponData.name)])
    else
        --Load image if nonexistant (TODO get rid of this or sth idk)
        if Assets.mapImages["item_" .. item.name] == nil then
            Assets.mapImages["item_" .. item.name] = love.graphics.newImage(GAME_DIRECTORY .. "/assets/images/items/" .. item.name .. ".png")
        end
        item.imageComponent = ENGINE_COMPONENTS.imageComponent.new(item, Assets.mapImages["item_" .. item.name])
    end
    item.imageComponent.layer = 2

    item.distanceToPlayer = 1000
    item.gettingPickedUp = false
    item.velocity = 0
    item.rotVelocity = 0
    item.realRot = 0
    item.defaultScale = table.new(item.scale)
    item.oldPos = table.new(item.position)
end

function itemScript:explosionEvent(position, radius, intensity)
    local item = self.parent
    local distance = coreFuncs.pointDistance(position, item.position)
    if distance > radius then return end
    local dx, dy = item.position[1]-position[1], item.position[2]-position[2]
    item.realRot = math.atan2(dy, dx)
    item.velocity = (radius/distance)*intensity*10
end

function itemScript:movement(delta)
    if CurrentScene.player == nil then return end
    local item = self.parent
    local playerPos = CurrentScene.player.position
    local itemPos = item.position
    item.oldPos = table.new(item.position)
    if item.gettingPickedUp then
        itemPos[1] = itemPos[1] + (playerPos[1]-itemPos[1])*10*delta
        itemPos[2] = itemPos[2] + (playerPos[2]-itemPos[2])*10*delta
        --Set alpha
        item.imageComponent.color[4] = item.distanceToPlayer/100
    else
        --Move
        itemPos[1] = itemPos[1] + item.velocity*math.cos(item.realRot)*delta
        itemPos[2] = itemPos[2] + item.velocity*math.sin(item.realRot)*delta
        --Slow down
        item.velocity = item.velocity + (-item.velocity)*8*delta
        if item.velocity < 0 then item.velocity = 0 end
        --Turn & velocity decrease
        item.rotation = item.rotation - item.rotVelocity*delta
        item.rotVelocity = item.rotVelocity + (-item.rotVelocity)*math.pi*2*delta
    end
end

function itemScript:collisionCheck()
    local item = self.parent
    local size = {25, 25}
    local itemPos = {item.position[1]-size[1]/2, item.position[2]-size[2]/2}
    --iterate through walls
    for _, wall in ipairs(CurrentScene.walls.tree) do
        local wallSize = {wall.scale[1]*64, wall.scale[2]*64}
        if coreFuncs.aabbCollision(itemPos, wall.position, size, wallSize) then
            item.position = table.new(item.oldPos)
            item.velocity = -item.velocity
            item.realRot = item.realRot
        end
    end
end

function itemScript:update(delta)
    if GamePaused then return end
    local item = self.parent
    --Remove self if getting picked up is complete
    if item.distanceToPlayer < 10 and item.gettingPickedUp then
        table.removeValue(CurrentScene.items.tree, item)
        return
    end

    local player = CurrentScene.player
    self:movement(delta)
    self:collisionCheck()
    --Distance calculation
    if player ~= nil then
        item.distanceToPlayer = coreFuncs.pointDistance(item.position, player.position)
    end
    --change size & return if player is far away
    if item.distanceToPlayer > 100 then
        item.scale[1] = item.scale[1] + (item.defaultScale[1]-item.scale[1])*8*delta
        item.scale[2] = item.scale[2] + (item.defaultScale[2]-item.scale[2])*8*delta
        if player.nearItem == item then player.nearItem = nil end
        return
    end
    if player.nearItem == nil and not item.gettingPickedUp then player.nearItem = item end
    item.scale[1] = item.scale[1] + (item.defaultScale[1]*1.4-item.scale[1])*8*delta
    item.scale[2] = item.scale[2] + (item.defaultScale[2]*1.4-item.scale[2])*8*delta
    --Picking up
    if (InputManager:isPressed("interact") or (item.name ~= "weapon" and Settings.auto_pick_loot)) and not item.gettingPickedUp and player.nearItem == item then
        if item.pickupEvent ~= nil then
            player.nearItem = nil
            item.pickupEvent(item)
        end
    end
end

return itemScript