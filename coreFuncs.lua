local assets = require("assets")

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
        (position[1]-camera.position[1]+(ScreenWidth/2)/camera.zoom)*camera.zoom,
        (position[2]-camera.position[2]+(ScreenHeight/2)/camera.zoom)*camera.zoom
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

-- Thanks to @pgimeno at https://love2d.org/forums/viewtopic.php?f=4&t=93768&p=250899#p250899
function SetFont(fontname, size)
    local key = fontname .. "\0" .. size
    local font = assets.fonts[key]
    if font then
      love.graphics.setFont(font)
    else
      font = love.graphics.setNewFont(fontname, size)
      assets.fonts[key] = font
    end
    return font
end

function math.uniform(a,b)
	return a + (math.random()*(b-a))
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

return coreFuncs