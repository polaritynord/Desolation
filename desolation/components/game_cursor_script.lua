local coreFuncs = require "coreFuncs"
local gameCursorScript = ENGINE_COMPONENTS.scriptComponent.new()

function gameCursorScript:update(_)
    if CurrentScene.name ~= "Game" then return end
    if GamePaused then
        love.mouse.setCursor(Assets.cursors.default)
    else
        if CurrentScene.player.reloading then
            love.mouse.setCursor(Assets.cursors.reload)
        else
            love.mouse.setCursor(Assets.cursors.combat)
        end
    end
end

return gameCursorScript