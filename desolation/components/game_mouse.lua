local mouseSensivity = ENGINE_COMPONENTS.scriptComponent.new()

--[[
function love.mousemoved(x, y, dx, dy, istouch)
    if GamePaused or CurrentScene.name ~= "Game" then return end
    x = x + dx*Settings.sensivity
    y = y + dy*Settings.sensivity
    love.mouse.setPosition(x, y)
end
]]--

function mouseSensivity.setMouseCursor()
    if CurrentScene.name == "Game" then
        if not GamePaused then
            love.mouse.setCursor(Assets.cursors.combat)
        else
            love.mouse.setCursor(cursors.arrow)
        end
    else
        love.mouse.setCursor(cursors.arrow)
    end
end

function mouseSensivity:load()
    --local obj = self.parent
    --obj.imageComponent = ENGINE_COMPONENTS.imageComponent.new(obj, Assets.cursors.combat)
end

function mouseSensivity:update(delta)
    if true then return end
    local obj = self.parent
    obj.imageComponent.enabled = not GamePaused
    --set position of virtual cursor
    local mx, my = love.mouse.getPosition()
    obj.position = {(mx+CurrentScene.camera.position[1])-ScreenWidth/2, (my+CurrentScene.camera.position[2]-ScreenHeight/2)}
    obj.scale = {1/CurrentScene.camera.zoom, 1/CurrentScene.camera.zoom}
end

return mouseSensivity