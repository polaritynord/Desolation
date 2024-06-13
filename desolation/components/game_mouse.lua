local mouseSensivity = ENGINE_COMPONENTS.scriptComponent.new()

local cursors = {
    arrow = love.mouse.getSystemCursor("arrow");
    crosshair = love.mouse.getSystemCursor("crosshair")
}

function mouseSensivity.setMouseCursor()
    if CurrentScene.name == "Game" then
        if not GamePaused then
            love.mouse.setCursor(Assets.images.cursors.combat)
        else
            love.mouse.setCursor(cursors.arrow)
        end
    else
        love.mouse.setCursor(cursors.arrow)
    end
end

function mouseSensivity:load()
    self.oldX, self.oldY = love.mouse.getPosition()
end

function mouseSensivity:update(delta)
    self:setMouseCursor()
    if GamePaused or Settings.sensivity == 1 then return end
    --TODO too buggy!!!
    local mx, my = love.mouse.getPosition()
    mx = mx + (mx-self.oldX)*Settings.sensivity
    my = my + (my-self.oldY)*Settings.sensivity
    love.mouse.setPosition(mx, my)
    self.oldX, self.oldY = love.mouse.getPosition()
end

return mouseSensivity