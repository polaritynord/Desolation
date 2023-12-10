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
    local relativePos = {(pos1[1]-camera.position[1]+480)*camera.zoom, (pos1[2]-camera.position[2]+270)*camera.zoom}
    return relativePos
end

return coreFuncs