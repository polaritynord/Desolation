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

function coreFuncs.getRelativePosition(transform, camera)
    local camTransform = camera.transformComponent
    local relativePos = {
        (transform.x-camTransform.x+(ScreenWidth/2)/camera.zoom)*camera.zoom,
        (transform.y-camTransform.y+(ScreenHeight/2)/camera.zoom)*camera.zoom
    }
    return relativePos
end

function coreFuncs.getRelativeElementPosition(position, parentComp)
    local parentPos = parentComp.parent:getPosition()
    local x = position[1]
    local y = position[2]

    return {x + parentPos.x, y + parentPos.y}
end

function coreFuncs.getRelativeMousePosition()
    local mX, mY = love.mouse.getPosition()
    return mX/(ScreenWidth/960), mY/(ScreenHeight/540)
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

return coreFuncs