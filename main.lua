local assets = require("assets")
local player = require("scripts.player")
local rgb = require("coreFuncs").rgb
local camera = require("scripts.camera")
local mapRenderer = require("scripts.mapRenderer")
local interfaceManager = require("scripts.ui.interfaceManager")
local gameUi = require("scripts.ui.gameUi")
local menuUi = require("scripts.ui.menuUi")
local weaponManager = require("scripts.weaponManager")

local fullscreen = false

function love.keypressed(key, _unicode)
    -- Fullscreen key
    if key == "f11" then
        fullscreen = not fullscreen
        love.window.setFullscreen(fullscreen, "desktop")
        -- Set window dimensions to default
        if not fullscreen and false then
         love.window.setMode(960, 540, {resizable=true}) end
    end
    --Pause key
    if key == "escape" then
        GamePaused = not GamePaused
    end
end

function GameLoad()
    Player = player.new()
    Camera = camera.new()
    Player:load()
    mapRenderer:load()
    GamePaused = false
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    assets.load()
    GameLoad()
    menuUi:load()
    gameUi:load()
    weaponManager:load()
    GameState = "menu"
end

function love.update(delta)
    ScreenWidth, ScreenHeight = love.graphics.getDimensions()
    if GameState == "game" then
        Player:update(delta)
    elseif GameState == "menu" then end
    gameUi:update(delta)
    menuUi:update(delta)
    interfaceManager:update(delta)
end

function love.draw()
    if GameState == "game" then
        love.graphics.setBackgroundColor(rgb(50))
        --Game
        mapRenderer:draw()
        Player:draw()
    elseif GameState == "menu" then
        love.graphics.setBackgroundColor(rgb(75))
    end
    interfaceManager:draw()
end
