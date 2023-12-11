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

function coreFuncs.getRelativePosition(pos1, camera)
    local relativePos = {
        (pos1[1]-camera.position[1]+(ScreenWidth/2)/camera.zoom)*camera.zoom,
        (pos1[2]-camera.position[2]+(ScreenHeight/2)/camera.zoom)*camera.zoom
    }
    return relativePos
end

function coreFuncs.getRelativeElementPosition(position, align, parentCanvas)
    local x = position[1]
    local y = position[2]
    -- Find x position
    -- X Aligning
    if align:sub(1, 1) == "-" then
        -- Left align
        x = x - (ScreenWidth-960)
    elseif align:sub(1, 1) == "+" then
        -- Right align
        x = x + (ScreenWidth-960)
    elseif align:sub(1, 1) == "0" then
        -- Center align
        x = x + (ScreenWidth-960)/2
    end
    -- Y Aligning
    if align:sub(2, 2) == "-" then
        -- Up align
        y = y - (ScreenHeight-540)
    elseif align:sub(2, 2) == "+" then
        -- Down align
        y = y + (ScreenHeight-540)
    elseif align:sub(2, 2) == "0" then
        -- Center align
        y = y + (ScreenHeight-540)/2
    end

    return {x + parentCanvas.position[1], y + parentCanvas.position[2]}
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

return coreFuncs