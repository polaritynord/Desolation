local utf8 = require("utf8")
local json  = require("engine.lib.json")
local coreFuncs = require("coreFuncs")
local startupManager = require("engine.startup_manager")

local fullscreen = false

InputManager = require("engine.input_manager")
Globals = require("engine.globals")
DevConsoleOpen = false
Assets = require("assets")
MenuUIOffset = 0
CurrentScene = nil
GamePaused = false
Scenes = {}

function love.wheelmoved(x, y)
    --Keys menu scrolling (TODO, make this work for all menus?)
    if CurrentScene.settings then
        local menu = CurrentScene.settings.keysMenu
        menu.position[2] = menu.position[2] + 35*y
        if menu.position[2] > 0 then menu.position[2] = 0 end
        if menu.position[2] < 540-menu.length then menu.position[2] = 540-menu.length end
    end

    --Ingame zooming
    if not GamePaused and CurrentScene.name == "Game" and (CurrentScene.mapCreator.allowZoom or GetGlobal("freecam") > 0) then
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
    --console shit
    local console = CurrentScene.devConsole
    local consoleUI
    if console then
        consoleUI = console.UIComponent
    else consoleUI = nil end
    --input type check
    if InputManager.inputType == "joystick" then
        print("keyboard input mode active")
        InputManager.inputType = "keyboard"
    end
    -- Fullscreen key
    if table.contains(InputManager:getKeys("fullscreen"), key) then
        fullscreen = not fullscreen
        --love.window.setMode(love.window.getDesktopDimensions())
        love.window.setFullscreen(fullscreen, "desktop")
        --love.window.setFullscreen(fullscreen, "desktop")
        -- Set window dimensions to default
        --if not fullscreen and false then
        -- love.window.setMode(960, 540, {resizable=true}) end
    end

    --Pause key (not devConsoleUI.takingInput)
    if table.contains(InputManager:getKeys("pause_game"), key) and (console and not console.open) and CurrentScene.name == "Game" then
        GamePaused = not GamePaused
        CurrentScene.settings.menu = nil
        CurrentScene.settings.open = false
        CurrentScene.player.shootTimer = 0
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

    --Toggle HUD key
    if table.contains(InputManager:getKeys("toggle_hud"), key) and CurrentScene.name == "Game" then
        CurrentScene.hud.UIComponent.enabled = not CurrentScene.hud.UIComponent.enabled
    end

    --Take screenshot key
    if table.contains(InputManager:getKeys("screenshot"), key) then
        love.graphics.captureScreenshot("screenshots/" .. os.date("%Y%m%d%H%m%S") .. ".png")
    end

    --***DEVCONSOLE RELATED STUFF DOWN HERE***
    if not console then return end
    --Developer console opening key
    if table.contains(InputManager:getKeys("dev_console"), key) and not AltMenuOpen then
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

    --Check if a button is selected in keys menu
    if CurrentScene.settings and CurrentScene.settings.keysMenu.selectedBinding[1] then
        local keysMenu = CurrentScene.settings.keysMenu
        RunConsoleCommand("bind " .. keysMenu.selectedBinding[2][1] .. " " .. key)
        local element = keysMenu.selectedBinding[1]
        element.buttonText = string.upper(element.binding[1]) .. ": " .. element.binding[2]
        element.textFont = "disposable-droid"
        --save bindings data
        love.filesystem.write("bindings.json", json.encode(InputManager.bindings))
        keysMenu.selectedBinding = {nil, nil}
    end
end

local function updateUIOffset(delta)
    AltMenuOpen = (CurrentScene.devConsole and CurrentScene.devConsole.open) or (CurrentScene.settings and CurrentScene.settings.open) or
                (CurrentScene.extras and CurrentScene.extras.open and CurrentScene.extras.selection ~= nil)
    --TODO this code is ass
    local x = (
        coreFuncs.boolToNum(AltMenuOpen) + coreFuncs.boolToNum(CurrentScene.settings and CurrentScene.settings.menu)
        + coreFuncs.boolToNum(CurrentScene.extras and CurrentScene.extras.open)
    )*-250
    MenuUIOffset = MenuUIOffset + (x-MenuUIOffset)*8*delta
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    Assets.load()
    love.keyboard.setKeyRepeat(true)
    InputManager:loadBindingFile()
    startupManager:load()
    love.window.setVSync(Settings.vsync)
end

function love.update(delta)
    ScreenWidth, ScreenHeight = love.graphics.getDimensions()
    if not CurrentScene then return end
    CurrentScene:update(delta)
    updateUIOffset(delta)
    love.window.setVSync(Settings.vsync)
end

function love.draw()
    if not CurrentScene then return end
    CurrentScene:draw()
end
