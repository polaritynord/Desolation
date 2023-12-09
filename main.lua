local assets = require("assets")
local player = require("player")
local rgb = require("coreFuncs").rgb

function love.load()
    Player = player.new()
    love.graphics.setDefaultFilter("nearest", "nearest")
    assets.load()
end

function love.update(delta)
    Player:update(delta)
    local gameCanvas = love.graphics.newCanvas(480, 270)
end

function love.draw()
    love.graphics.setBackgroundColor(rgb(50))
    love.graphics.setCanvas(gameCanvas)
        gameCanvas:clear()
        Player:draw()
    love.graphics.setCanvas()
end
