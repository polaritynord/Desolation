local json = require "engine.lib.json"
local coreFuncs = {}

function coreFuncs.rgb(r, g, b)
    local val
    if g and b then
        val = {r/255, g/255, b/255}
    else
        val = {r/255, r/255, r/255}
    end
    return val
end

function coreFuncs.getRelativePosition(position, camera)
    local relativePos = {
        (position[1]-camera.position[1]+(ScreenWidth/2)/(ScreenWidth/960)/camera.zoom)*camera.zoom,
        (position[2]-camera.position[2]+(ScreenHeight/2)/(ScreenHeight/540)/camera.zoom)*camera.zoom
    }
    return relativePos
end

function coreFuncs.getRelativeElementPosition(position, parentComp)
    local objectPos = parentComp.parent.position

    return {position[1] + objectPos[1], position[2] + objectPos[2]}
end

function coreFuncs.getRelativeMousePosition()
    local mX, mY = love.mouse.getPosition()
    return mX/(ScreenWidth/960), mY/(ScreenHeight/540)
end

function coreFuncs.boolToNum(bool)
    if bool then return 1 else return 0 end
end

function coreFuncs.roundDecimal(number, decimals)
    local power = 10^decimals
    return math.floor(number * power) / power
end

function coreFuncs.getLineCount(str)
    local lines = 1
    for i = 1, #str do
        local c = str:sub(i, i)
        if c == '\n' then lines = lines + 1 end
    end

    return lines
end

function coreFuncs.pointDistance(pos1, pos2)
    return math.sqrt(
        (pos1[1]-pos2[1])^2 + (pos1[2]-pos2[2])^2
    )
end

function coreFuncs.aabbCollision(pos1, pos2, size1, size2)
    return pos1[1] < pos2[1]+size2[1] and
            pos1[1]+size1[1] > pos2[1] and
            pos1[2] < pos2[2]+size2[2] and
            pos1[2]+size1[2] > pos2[2]
end

function coreFuncs.infiniteModeAmmoType(wave)
    local n = math.random()
    if wave <= 3 then
        --In the first three waves, it is more likely for enemies & crates to
        --drop light ammunition to encourage the player to use the pistol more.
        if n <= 0.65 then
            return "ammo_light"
        elseif n > 0.65 and n <= 0.85 then
            return "ammo_shotgun"
        else
            return "ammo_medium"
        end
    elseif wave <= 7 then
        --In waves 4-7, it is an equal distribution for all types.
        n = math.random(1, 3)
        if n == 1 then return "ammo_light" end
        if n == 2 then return "ammo_shotgun" end
        if n == 3 then return "ammo_medium" end
    else
        --In waves higher than 7, 40% medium, %38 shotgun, %22 pistol.
        if n <= 0.4 then
            return "ammo_medium"
        elseif n > 0.4 and n < 7.8 then
            return "ammo_shotgun"
        else
            return "ammo_light"
        end
    end
end

-- Thanks to @pgimeno at https://love2d.org/forums/viewtopic.php?f=4&t=93768&p=250899#p250899
function SetFont(fontname, size)
    local key = fontname .. "\0" .. size
    local font = Assets.fonts[key]
    if font then
      love.graphics.setFont(font)
    else
      font = love.graphics.setNewFont(fontname, size)
      Assets.fonts[key] = font
    end
    return font
end

function math.uniform(a,b)
	return a + (math.random()*(b-a))
end

function math.getVecValue(vector)
    return math.sqrt((vector[1]*vector[1]) + (vector[2]*vector[2]))
end

function table.new(t)
        -- Taken from http://lua-users.org/wiki/CopyTable/
    local orig = t
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
        copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function table.removeValue(tbl, val)
    for i,v in pairs(tbl) do
        if v == val then
            table.remove(tbl,i)
            break
        end
    end
end

function GiveAchievement(name)
    if Achievements[name].obtained then return end
    Achievements[name].obtained = true
    love.filesystem.write("achievements.json", json.encode(Achievements))
    --Add ach. to notif queue
    if CurrentScene.achievementUI == nil then return end
    CurrentScene.achievementUI.queue[#CurrentScene.achievementUI.queue+1] = name
    --Play sound
    SoundManager:restartSound(Assets.sounds["achievement_obtain"], Settings.vol_sfx)
end

return coreFuncs