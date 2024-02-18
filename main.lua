local utf8 = require("utf8")
local assets = require("assets")
local player = require("scripts.player")
local rgb = require("coreFuncs").rgb
local camera = require("scripts.camera")
local mapRenderer = require("scripts.mapRenderer")
local interfaceManager = require("scripts.ui.interfaceManager")
local gameUi = require("scripts.ui.gameUi")
local menuUi = require("scripts.ui.menuUi")
local globals = require("scripts.globals")
local weaponManager = require("scripts.weaponManager")
local weaponItem = require("scripts.weaponItem")
local devConsoleUI = require("scripts.ui.devConsole")

local fullscreen = false
local cursors = {
    arrow = love.mouse.getSystemCursor("arrow");
    crosshair = love.mouse.getSystemCursor("crosshair")
}

DevConsoleOpen = false
MenuUIOffset = 0

function love.keypressed(key, unicode)
    -- Fullscreen key
    if key == "f11" then
        fullscreen = not fullscreen
        love.window.setFullscreen(fullscreen, "desktop")
        -- Set window dimensions to default
        if not fullscreen and false then
         love.window.setMode(960, 540, {resizable=true}) end
    end
    --Pause key
    if key == "escape" and not devConsoleUI.takingInput and not DevConsoleOpen then
        GamePaused = not GamePaused
    end
    --Debug menu toggle key
    if key == "f3" and GameState == "game" then
        gameUi.debug.toggled = not gameUi.debug.toggled
        --Disable verbose mode if closing menu
        if not gameUi.debug.toggled then gameUi.debug.verboseMode = false end
        --Check for verbose opening
        if gameUi.debug.toggled and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
            gameUi.debug.verboseMode = true
        end
    end

    --Developer console opening key
    if key == "\"" then
        if DevConsoleOpen and devConsoleUI.takingInput then return end
        DevConsoleOpen = not DevConsoleOpen
        if DevConsoleOpen and GameState == "game" then
            GamePaused = true
        end
    end

    --Dev console text erasing
    if key == "backspace" then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(devConsoleUI.commandInput, -1)

        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            devConsoleUI.commandInput = string.sub(devConsoleUI.commandInput, 1, byteoffset - 1)
        end
    end

    --Dev console input mode exiting & stuff
    if key == "escape" and DevConsoleOpen then
        if devConsoleUI.takingInput then
            devConsoleUI.takingInput = false
        else
            DevConsoleOpen = false
        end
    end

    --Dev console submitting command
    if key == "return" and DevConsoleOpen and devConsoleUI.takingInput then
        --RunConsoleCommand(devConsoleUI.commandInput)
        local commands = devConsoleUI:readCommandsFromInput()
        for i = 1, #commands do
            RunConsoleCommand(commands[i])
        end
        devConsoleUI.commandInput = ""
    end
end

function GameLoad()
    Player = player.new()
    Camera = camera.new()
    Player:load()
    mapRenderer:load()
    GamePaused = false
end

local function setMouseCursor()
    if GameState == "game" then
        if not GamePaused then
            love.mouse.setCursor(cursors.crosshair)
        else
            love.mouse.setCursor(cursors.arrow)
        end
    else
        love.mouse.setCursor(cursors.arrow)
    end
end

local function updateUIOffset(delta)
    local x = 0
    if DevConsoleOpen then
        x = -250
    end
    MenuUIOffset = MenuUIOffset + (x-MenuUIOffset)*8*delta
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    assets.load()
    weaponManager:load()
    GameLoad()
    menuUi:load()
    gameUi:load()
    devConsoleUI:load()
    GameState = "menu"
    love.keyboard.setKeyRepeat(true)
end

function love.update(delta)
    ScreenWidth, ScreenHeight = love.graphics.getDimensions()
    if GameState == "game" then
        Player:update(delta)
    elseif GameState == "menu" then end
    gameUi:update(delta)
    menuUi:update(delta)
    devConsoleUI:update(delta)
    interfaceManager:update(delta)
    updateUIOffset(delta)
    setMouseCursor()
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
