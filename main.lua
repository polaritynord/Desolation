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
    local console = CurrentScene.devConsole
    if not console then return end
    if console.open then
        if y > 0 then
            console.logOffset = console.logOffset - 1
            if console.logOffset < 0 then console.logOffset = 0 end
        elseif y < 0 then
            console.logOffset = console.logOffset + 1
            if console.logOffset > #console.logs then console.logOffset = #console.logs end
        end
    end
end

function love.keypressed(key, unicode)
    local console = CurrentScene.devConsole
    local consoleUI
    if console then
        consoleUI = console.UIComponent
    else consoleUI = nil end
    -- Fullscreen key
    if table.contains(InputManager:getKeys("fullscreen"), key) then
        fullscreen = not fullscreen
        love.window.setFullscreen(fullscreen, "desktop")
        -- Set window dimensions to default
        if not fullscreen and false then
         love.window.setMode(960, 540, {resizable=true}) end
    end

    --Pause key (not devConsoleUI.takingInput)
    if table.contains(InputManager:getKeys("pause_game"), key) and (console and not console.open) then
        GamePaused = not GamePaused
    end

    --Debug menu toggle key
    if table.contains(InputManager:getKeys("toggle_debug"), key) and CurrentScene.name == "Game" then
        local debugMenu = CurrentScene.debugMenu
        debugMenu.enabled = not debugMenu.enabled
        --Disable verbose mode if closing menu
        if not debugMenu.enabled then debugMenu.verboseMode = false end
        --Check for verbose opening
        if debugMenu.enabled and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
            debugMenu.verboseMode = true
        end
    end

    --***DEVCONSOLE RELATED STUFF DOWN HERE***
    if not console then return end
    --Developer console opening key
    if table.contains(InputManager:getKeys("dev_console"), key) then
        if console.open and consoleUI.takingInput then return end
        console.open = not console.open
        if console.open and CurrentScene.name == "Game" then
            GamePaused = true
        end
    end

    --Dev console text erasing
    if key == "backspace" then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(console.commandInput, -1)

        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            console.commandInput = string.sub(console.commandInput, 1, byteoffset - 1)
        end
    end

    --Dev console input mode exiting & stuff
    if key == "escape" and console.open then
        if console.takingInput then
            console.takingInput = false
        else
            console.open = false
        end
    end

    --Dev console submitting command
    if key == "return" and console.open and console.takingInput and console.commandInput ~= "" then
        local commands = console.script:readCommandsFromInput(console.commandInput)
        for i = 1, #commands do
            RunConsoleCommand(commands[i])
        end
        print("Ran console script: " .. console.commandInput)
        console.script:log("> " .. console.commandInput)
        console.commandInput = ""
    end

    --Check if the key is assigned to a devConsole command
    if table.contains(console.assignedKeys, key) then
        local commandInput = console.assignedCommands[table.contains(console.assignedKeys, key, true)]
        local commands = console.script:readCommandsFromInput(commandInput, true)
        for i = 1, #commands do
            RunConsoleCommand(commands[i])
        end
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
    if CurrentScene.devConsole and CurrentScene.devConsole.open then
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
    --Fetch game info
    local engineInfoFile = love.filesystem.read("engine/info.json")
    local engineInfoData = json.decode(engineInfoFile)
    local gameDirectory = engineInfoData.gameDirectory
    local infoFile = love.filesystem.read(gameDirectory .. "/info.json")
    local infoData = json.decode(infoFile)
    GAME_NAME = infoData.name
    GAME_VERSION = infoData.version
    GAME_VERSION_STATE = infoData.versionState
    AUTHOR = infoData.author
    ENGINE_NAME = engineInfoData.name
    ENGINE_VERSION = engineInfoData.version
    local startScene = LoadScene(infoData.startScene)
    if startScene.name == "Intro" and table.contains(arg, "--skip-intro") then
        startScene = LoadScene("fdh/assets/scenes/main_menu.json")
    end
    SetScene(startScene)
end

function love.update(delta)
    ScreenWidth, ScreenHeight = love.graphics.getDimensions()
    if not CurrentScene then return end
    CurrentScene:update(delta)
    updateUIOffset(delta)
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
