local assets = require("assets")
local player = require("player")
local rgb = require("coreFuncs").rgb
local camera = require("camera")

function love.load()
    Player = player.new()
    Camera = camera.new()
    love.graphics.setDefaultFilter("nearest", "nearest")
    assets.load()
end

function love.update(delta)
    Player:update(delta)
end

function love.draw()
    love.graphics.setBackgroundColor(rgb(50))
    --Game
    Player:draw()
end
