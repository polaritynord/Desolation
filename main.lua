local utf8 = require("utf8")
local assets = require("assets")
local rgb = require("coreFuncs").rgb
local mapManager = require("scripts.mapManager")
local interfaceManager = require("scripts.ui.interfaceManager")
local gameUi = require("scripts.ui.gameUi")
local menuUi = require("scripts.ui.menuUi")
local globals = require("scripts.globals")
local weaponManager = require("scripts.weaponManager")
local devConsoleUI = require("scripts.ui.devConsole")
local player = require("scripts.player")

local fullscreen = false
local cursors = {
    arrow = love.mouse.getSystemCursor("arrow");
    crosshair = love.mouse.getSystemCursor("crosshair")
}

DevConsoleOpen = false
MenuUIOffset = 0

function love.wheelmoved(x, y)
    -- Mouse wheel slot switching
    if not GamePaused and GameState == "game" then
        -- Switching slots
        local temp
        if y > 0 then
            --Backward
            temp = Player.inventory.slot
            Player.inventory.slot = Player.inventory.slot - 1
            if Player.inventory.slot < 1 then Player.inventory.slot = 3 end
            Player.oldSlot = Player.inventory.slot
        elseif y < 0 then
            --Forward
            temp = Player.inventory.slot
            Player.inventory.slot = Player.inventory.slot + 1
            if Player.inventory.slot > 3 then Player.inventory.slot = 1 end
            Player.oldSlot = temp
        end
    end
    --DevConsole scrolling
    if DevConsoleOpen then
        if y > 0 then
            devConsoleUI.logOffset = devConsoleUI.logOffset - 1
            if devConsoleUI.logOffset < 0 then devConsoleUI.logOffset = 0 end
        elseif y < 0 then
            devConsoleUI.logOffset = devConsoleUI.logOffset + 1
            if devConsoleUI.logOffset > #devConsoleUI.logs then devConsoleUI.logOffset = #devConsoleUI.logs end
        end
    end
end

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
    if key == "return" and DevConsoleOpen and devConsoleUI.takingInput and devConsoleUI.commandInput ~= "" then
        local commands = devConsoleUI:readCommandsFromInput(devConsoleUI.commandInput)
        for i = 1, #commands do
            RunConsoleCommand(commands[i])
        end
        print("Ran console script: " .. devConsoleUI.commandInput)
        devConsoleUI:log("> " .. devConsoleUI.commandInput)
        devConsoleUI.commandInput = ""
    end

    --Check if the key is assigned to a devConsole command
    if table.contains(devConsoleUI.assignedKeys, key) then
        local commandInput = devConsoleUI.assignedCommands[table.contains(devConsoleUI.assignedKeys, key, true)]
        local commands = devConsoleUI:readCommandsFromInput(commandInput, true)
        for i = 1, #commands do
            RunConsoleCommand(commands[i])
        end
        --RunConsoleCommand()
    end
    
    --Dev console history
    if key == "up" then
        --Check if current input is in history, otherwise start from the most recent
        local i 
        if #devConsoleUI.logs > 0 then
            --Find the most recent input in log history
            i = #devConsoleUI.logs
        else return end

        while string.sub(devConsoleUI.logs[i], 1, 1) ~= ">" and i > 1 do
            i = i -1
        end
        local log = string.sub(devConsoleUI.logs[i], 3, #devConsoleUI.logs[i])
        --Replace current input with new log
        devConsoleUI.commandInput = log
    end
end

function GameLoad()
    mapManager:load()
    Player = mapManager:newHumanoid(player.new())
    Player:load()
    GamePaused = false
end

local function setMouseCursor()
    if GameState == "game" then
        if not GamePaused then
            love.mouse.setCursor(assets.images.cursors.combat)
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
    MapManager = mapManager
    GameState = "menu"
    love.keyboard.setKeyRepeat(true)
end

function love.update(delta)
    ScreenWidth, ScreenHeight = love.graphics.getDimensions()
    if GameState == "game" then
        mapManager:update(delta)
    end
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
        --Game canvas
        mapManager:draw()
    elseif GameState == "menu" then
        love.graphics.setBackgroundColor(rgb(75))
    end
    interfaceManager:draw()
end
