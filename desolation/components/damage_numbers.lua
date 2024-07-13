local coreFuncs = require("coreFuncs")
local damageNumbers = ENGINE_COMPONENTS.scriptComponent.new()

local function drawNumbers(comp)
    for _, v in ipairs(comp.parent.numbers) do
        local pos = coreFuncs.getRelativePosition(v.position, CurrentScene.camera)
        SetFont("desolation/assets/fonts/disposable-droid.ttf", 32)
        love.graphics.setColor(1, 0, 0, v.alpha)
        love.graphics.print(tostring(math.floor(v.number)), pos[1], pos[2])
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function damageNumbers:load()
   self.parent.imageComponent.draw = drawNumbers
   self.parent.numbers = {}
end

function damageNumbers:update(delta)
    --Update numbers
    for _, v in ipairs(self.parent.numbers) do
        -- Despawn number
        if v.alpha < 0 then
            table.remove(self.parent.numbers, i)
            goto skipNumber
        end
        -- Update alpha & scale
        v.alpha = v.alpha - 10 * delta
        -- Move up
        v.position[2] = v.position[2] - 70 * delta
        ::skipNumber::
    end
end

return damageNumbers