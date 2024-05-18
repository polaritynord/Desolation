local utf8 = require("utf8")
local scene = require("engine.scene")
local json  = require("lib.json")
local globals = require("engine.globals")

local fullscreen = false
local cursors = {
    arrow = love.mouse.getSystemCursor("arrow");
    crosshair = love.mouse.getSystemCursor("crosshair")
}

InputManager = require("engine.input_manager")
DevConsoleOpen = false
Assets = require("assets")
MenuUIOffset = 0
CurrentScene = nil
GamePaused = false
Scenes = {}

function love.wheelmoved(x, y)
    if not GamePaused and CurrentScene.name == "Game" then
        local camController = CurrentScene.camera.script
        if y > 0 then
            camController.playerManualZoom = camController.playerManualZoom + 0.1
            if camController.playerManualZoom > 2.5 then camController.playerManualZoom = 2.5 end
        elseif y < 0 then
            camController.playerManualZoom = camController.playerManualZoom - 0.1
            if camController.playerManualZoom < 0.5 then camController.playerManualZoom = 0.5 end
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

    --Pause key (not devConsoleUI.takingInput)
    if key == "escape" and not DevConsoleOpen then
        GamePaused = not GamePaused
    end

    --Debug menu toggle key
    if key == "f3" and CurrentScene.name == "Game" then
        local debugMenu = CurrentScene.debugMenu
        debugMenu.enabled = not debugMenu.enabled
        --Disable verbose mode if closing menu
        if not debugMenu.enabled then debugMenu.verboseMode = false end
        --Check for verbose opening
        if debugMenu.enabled and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
            debugMenu.verboseMode = true
        end
    end

    if true then return end
    --Developer console opening key
    if key == "\"" and false then
        if DevConsoleOpen and devConsoleUI.takingInput then return end
        DevConsoleOpen = not DevConsoleOpen
        if DevConsoleOpen and GameState == "game" then
            GamePaused = true
        end
    end

    --Dev console text erasing
    if key == "backspace" and false then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(devConsoleUI.commandInput, -1)

        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            devConsoleUI.commandInput = string.sub(devConsoleUI.commandInput, 1, byteoffset - 1)
        end
    end

    --Dev console input mode exiting & stuff
    if false then
        if key == "escape" and DevConsoleOpen then
            if devConsoleUI.takingInput then
                devConsoleUI.takingInput = false
            else
                DevConsoleOpen = false
            end
        end
    end

    --Dev console submitting command
    if key == "return" and DevConsoleOpen and devConsoleUI.takingInput and devConsoleUI.commandInput ~= "" and false then
        local commands = devConsoleUI:readCommandsFromInput(devConsoleUI.commandInput)
        for i = 1, #commands do
            RunConsoleCommand(commands[i])
        end
        print("Ran console script: " .. devConsoleUI.commandInput)
        devConsoleUI:log("> " .. devConsoleUI.commandInput)
        devConsoleUI.commandInput = ""
    end

    --Check if the key is assigned to a devConsole command
    if table.contains(devConsoleUI.assignedKeys, key) and false then
        local commandInput = devConsoleUI.assignedCommands[table.contains(devConsoleUI.assignedKeys, key, true)]
        local commands = devConsoleUI:readCommandsFromInput(commandInput, true)
        for i = 1, #commands do
            RunConsoleCommand(commands[i])
        end
        --RunConsoleCommand()
    end
    
    --Dev console history
    if key == "up" and false then
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

local function setMouseCursor()
    if GameState == "game" then
        if not GamePaused then
            love.mouse.setCursor(Assets.images.cursors.combat)
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
    Assets.load()
    love.keyboard.setKeyRepeat(true)
    InputManager:loadBindingFile()
    --weaponManager:load()
    --GameLoad()
    --menuUi:load()
    --gameUi:load()
    --devConsoleUI:load()
    --MapManager = mapManager
    --GameState = "menu"
    --RunConsoleCommand("run_script dcsFiles/test.dcs")

    --Read game directory & launch first scene (TODO: Add game launching from console args)
    local gameDirectory = "fdh"
    --Fetch game info
    local infoFile = love.filesystem.read(gameDirectory .. "/info.json")
    local infoData = json.decode(infoFile)
    local engineInfoFile = love.filesystem.read("engine/info.json")
    local engineInfoData = json.decode(engineInfoFile)
    GAME_NAME = infoData.name
    GAME_VERSION = infoData.version
    GAME_VERSION_STATE = infoData.versionState
    AUTHOR = infoData.author
    ENGINE_NAME = engineInfoData.name
    ENGINE_VERSION = engineInfoData.version
    local startScene = LoadScene(infoData.startScene)
    SetScene(startScene)
end

function love.update(delta)
    ScreenWidth, ScreenHeight = love.graphics.getDimensions()
    if not CurrentScene then return end
    CurrentScene:update(delta)
    --updateUIOffset(delta)
    --setMouseCursor()
end

function love.draw()
    if not CurrentScene then return end
    --Objects
    CurrentScene:draw()
    --UI
    love.graphics.push()
        love.graphics.scale(ScreenWidth/960, ScreenHeight/540)
        --interfaceManager:draw()
    love.graphics.pop()
end
