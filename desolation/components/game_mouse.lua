local mouseSensivity = {}

function mouseSensivity:load()
    self.oldX, self.oldY = love.mouse.getPosition()
end

function mouseSensivity:update(delta)
    if GamePaused or Settings.sensivity == 1 then return end
    --TODO too buggy!!!
    local mx, my = love.mouse.getPosition()
    mx = mx + (mx-self.oldX)*Settings.sensivity
    my = my + (my-self.oldY)*Settings.sensivity
    love.mouse.setPosition(mx, my)
    self.oldX, self.oldY = love.mouse.getPosition()
end

return mouseSensivity