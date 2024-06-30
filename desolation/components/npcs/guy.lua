local humanoidScript = require("desolation.components.humanoid_script")

local guyScript = table.new(humanoidScript)

function guyScript:load()
    self:humanoidSetup()
end

function guyScript:update(delta)
end

return guyScript