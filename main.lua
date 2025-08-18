local utf8 = require("utf8")
local json  = require("engine.lib.json")
local coreFuncs = require("coreFuncs")
local startupManager = require("engine.startup_manager")

Lighter = require("engine.lib.lighterlib")()
InputManager = require("engine.input_manager")
SoundManager = require("engine.sound_manager")
Globals = require("engine.globals")
Assets = require("assets")
MenuUIOffset = 0
RealMenuUIOffset = 0
CurrentScene = nil
Scenes = {}
OldSceneName = ""
MapChanged = false
DevConsoleOpen = false
GamePaused = false

function love.mousemoved()
    InputManager:setInputTypeTo("keyboard")
end

function love.wheelmoved(_, y)
    InputManager:setInputTypeTo("keyboard")
    --Scrolling in various alt menus (TODO: Improve?)
    if CurrentScene.settings and (CurrentScene.settings.menu == "keys" or CurrentScene.settings.menu == "video" or CurrentScene.settings.menu == "gameplay") then
        local menu = CurrentScene.settings.keysMenu
        if CurrentScene.settings.menu == "video" then menu = CurrentScene.settings.videoMenu end
        if CurrentScene.settings.menu == "gameplay" then menu = CurrentScene.settings.gameplayMenu end
        menu.realY = menu.realY + 35*y
        if menu.realY > 0 then menu.realY = 0 end
        if menu.realY < 540-menu.length then menu.realY = 540-menu.length end
    end
    --Infinite menu scrolling
    if CurrentScene.extras ~= nil then
        if CurrentScene.extras.infiniteMenu.UIComponent.enabled then
            local menu = CurrentScene.extras.infiniteMenu
            menu.realY = menu.realY + 35*y
            if menu.realY > 0 then menu.realY = 0 end
            if menu.realY < 540-menu.length then menu.realY = 540-menu.length end
        end
    end
    --Achivements menu scrolling
    if CurrentScene.achievements ~= nil then
        if CurrentScene.achievements.open then
            local menu = CurrentScene.achievements
            --menu.UIComponent.scrollbar.value = menu.UIComponent.scrollbar.value - y/20
            menu.realY = menu.realY + 35*y
            if menu.realY > 0 then menu.realY = 0 end
            if menu.realY < 540-menu.length then menu.realY = 540-menu.length end
        end
    end
    --Changelog menu scrolling
    if CurrentScene.changelog ~= nil then
        if CurrentScene.changelog.open then
            local menu = CurrentScene.changelog
            --menu.UIComponent.scrollbar.value = menu.UIComponent.scrollbar.value - y/20
            menu.realY = menu.realY + 35*y
            if menu.realY > 0 then menu.realY = 0 end
            if menu.realY < 540-menu.length then menu.realY = 540-menu.length end
        end
    end
    --Load game menu scrolling
    if CurrentScene.loadGameMenu ~= nil then
        if CurrentScene.loadGameMenu.open then
            local menu = CurrentScene.loadGameMenu
            --menu.UIComponent.scrollbar.value = menu.UIComponent.scrollbar.value - y/20
            menu.realY = menu.realY + 35*y
            if menu.realY > 0 then menu.realY = 0 end
            if menu.realY < 540-menu.length then menu.realY = 540-menu.length end
        end
    end

    --Ingame zooming
    if not GamePaused and CurrentScene.name == "Game" and (CurrentScene.mapCreator.allowZoom or GetGlobal("freecam") > 0) then
        local camController = CurrentScene.camera.script
        if y > 0 then
            camController.playerManualZoom = camController.playerManualZoom + 0.1
            if camController.playerManualZoom > 2.5 then camController.playerManualZoom = 2.5 end
        elseif y < 0 then
            camController.playerManualZoom = camController.playerManualZoom - 0.1
            if camController.playerManualZoom < 0.01 then camController.playerManualZoom = 0.01 end
        end
    end

    --[[Ingame slot switching
    if not GamePaused and CurrentScene.name == "Game" and not love.keyboard.isDown("lctrl") and CurrentScene.player.health > 0 then
        local player = CurrentScene.player
        local oldSlot = player.inventory.slot
        player.inventory.previousSlot = player.inventory.slot
        player.inventory.slot = player.inventory.slot - y
        if player.inventory.slot > 3 then player.inventory.slot = 1 end
        if player.inventory.slot < 1 then player.inventory.slot = 3 end
        --Update hand offset
        if oldSlot ~= player.inventory.slot and player.inventory.weapons[oldSlot] ~= player.inventory.weapons[player.inventory.slot] then
            player.handOffset = -15
        end
        --Cancel reload if slot switching is done
        if oldSlot ~= player.inventory.slot then
            player.reloading = false
            local weapon = player.inventory.weapons[player.inventory.previousSlot]
            if weapon ~= nil then
                SoundManager:stopSound(Assets.sounds["reload_" .. string.lower(weapon.name)])
            end
        end
    end
    ]]--
    
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
    if key == "4" then
        CurrentScene.player.armorAcquired = not CurrentScene.player.armorAcquired
    end
    --console shit
    local console = CurrentScene.devConsole
    local consoleUI
    if console then
        consoleUI = console.UIComponent
    else consoleUI = nil end
    InputManager:setInputTypeTo("keyboard")
    --Various devconsole related stuff
    if console ~= nil and console.takingInput then
        --Arrows
        if key == "left" then
            console.inputIndex = console.inputIndex - 1
            if console.inputIndex < 1 then console.inputIndex = 1 end
        end
        if key == "right" then
            console.inputIndex = console.inputIndex + 1
            if console.inputIndex > #console.commandInput + 1 then console.inputIndex = #console.commandInput + 1 end
        end
        --Paste
        if (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) and key == "v" then
            local clipboardText = love.system.getClipboardText()
            if clipboardText ~= nil and clipboardText ~= "" then
                local temp = string.sub(console.commandInput, console.inputIndex, string.len(console.commandInput))
                console.commandInput = string.sub(console.commandInput, 1, console.inputIndex-1) .. clipboardText
                console.inputIndex = console.inputIndex + string.len(clipboardText)
                console.commandInput = console.commandInput .. temp
            end
        end
    end
    -- Fullscreen key
    if table.contains(InputManager:getKeys("fullscreen"), key) then
        --fullscreen = not fullscreen
        --love.window.setMode(love.window.getDesktopDimensions())
        love.window.setFullscreen(not love.window.getFullscreen(), "desktop")
        --Switch the fullscreen option in the settings too
        Settings.fullscreen = love.window.getFullscreen()
        if CurrentScene.settings ~= nil then
            CurrentScene.settings.videoMenu.UIComponent.fullscreenBox.toggled = love.window.getFullscreen()
        end

        --love.window.setFullscreen(fullscreen, "desktop")
        -- Set window dimensions to default
        if not love.window.getFullscreen() then
            local res = Settings.resolution_options[Settings.resolution]
            love.window.setMode(res[1], res[2], {})
        end
    end

    --Pause key (not devConsoleUI.takingInput)
    if table.contains(InputManager:getKeys("pause_game"), key) and (console and not console.open) and CurrentScene.name == "Game" and not AltMenuOpen and CurrentScene.player.health > 0 then
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
        CurrentScene.hud.UIComponent.hiddenHUD = not CurrentScene.hud.UIComponent.hiddenHUD
    end

    --Toggle flashlight
    if table.contains(InputManager:getKeys("flashlight"), key) and CurrentScene.name == "Game" and not GamePaused and CurrentScene.player.health > 0 and CurrentScene.player.flashlightAcquired then
        CurrentScene.player.flashlightOn = not CurrentScene.player.flashlightOn
        SoundManager:restartSound(Assets.sounds["flashlight_on"], Settings.vol_world)
    end

    --Take screenshot key
    if table.contains(InputManager:getKeys("screenshot"), key) then
        love.graphics.captureScreenshot("screenshots/" .. os.date("%Y.%m.%d %H.%m.%S") .. ".png")
        ConsoleLog("Screenshot saved at " .. love.filesystem.getRealDirectory("screenshots"))
    end

    --Save progress key
    if table.contains(InputManager:getKeys("save_progress"), key) and CurrentScene.name == "Game" then
        if CurrentScene.mapCreator.saveableMap then
            CurrentScene.mapCreator.script:saveProgress()
            CurrentScene.keyHints.UIComponent.progressSaveText.color[4] = 1
            SoundManager:restartSound(Assets.defaultSounds.save, Settings.vol_sfx)
        end
    end

    --Player quick slot switching
    local player = CurrentScene.player
    if player ~= nil and player.inventory.previousSlot and table.contains(InputManager:getKeys("w_quickswitch"), key) and CurrentScene.name == "Game" and not GamePaused and player.health > 0 then
        local temp = player.inventory.previousSlot
        player.inventory.previousSlot = player.inventory.slot
        player.inventory.slot = temp
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

        if byteoffset and console.inputIndex > 1 then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            console.commandInput = string.sub(console.commandInput, 1, console.inputIndex - 2) .. string.sub(console.commandInput, console.inputIndex, byteoffset + 1)
            --console.commandInput = string.sub(console.commandInput, 1, byteoffset - 1)
            console.inputIndex = console.inputIndex - 1
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
        GiveAchievement("devConsole")
        print("Ran console script: " .. console.commandInput)
        ConsoleLog("> " .. console.commandInput)
        console.commandInput = ""
        console.inputIndex = 1
    end

    --Check if the key is assigned to a devConsole command
    if table.contains(console.assignedKeys, key) and not GamePaused then
        local commandInput = console.assignedCommands[table.contains(console.assignedKeys, key, true)]
        local commands = console.script:readCommandsFromInput(commandInput, true)
        for i = 1, #commands do
            RunConsoleCommand(commands[i])
        end
    end

    --Check if a button is selected in keys menu
    if CurrentScene.settings ~= nil and CurrentScene.settings.keysMenu.selectedBinding ~= nil then
        local keysMenu = CurrentScene.settings.keysMenu
        RunConsoleCommand("bind " .. keysMenu.selectedBinding[1] .. " " .. key)
        local element = keysMenu.UIComponent[keysMenu.selectedBinding[1]]
        element.selected = false
        keysMenu.selectedBinding = nil
        --save bindings data
        love.filesystem.write("bindings.json", json.encode(InputManager.bindings))
    end
end

local function updateUIOffset(delta)
    AltMenuOpen = (CurrentScene.devConsole and CurrentScene.devConsole.open) or (CurrentScene.settings and CurrentScene.settings.open) or
                (CurrentScene.extras and CurrentScene.extras.open) or ((CurrentScene.achievements and CurrentScene.achievements.open))
                or (CurrentScene.changelog and CurrentScene.changelog.open) or (CurrentScene.about and CurrentScene.about.open)
                or (CurrentScene.newGameMenu and CurrentScene.newGameMenu.open) or (CurrentScene.loadGameMenu and CurrentScene.loadGameMenu.open)
    --TODO this code is absolute fucking shit
    RealMenuUIOffset = (
        coreFuncs.boolToNum(AltMenuOpen) + coreFuncs.boolToNum(CurrentScene.settings and CurrentScene.settings.menu)
        + coreFuncs.boolToNum(CurrentScene.extras and CurrentScene.extras.open and CurrentScene.extras.selection ~= nil)
    )*-250
    MenuUIOffset = MenuUIOffset + (RealMenuUIOffset-MenuUIOffset)*8*delta
end

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.audio.setDistanceModel("linearclamped")
    InputManager:loadBindingFile()
    startupManager:load()
    Assets.load()
    love.keyboard.setKeyRepeat(true)
    love.window.setVSync(Settings.vsync)

    local startScene = nil
    --Open map directly if given
    if table.contains(arg, "--map") then
        local i = table.contains(arg, "--map", true)
        startScene = LoadScene(GAME_DIRECTORY .. "/assets/scenes/game.json")
        SetScene(startScene)
        startScene.mapCreator.script:loadMap(arg[i+1])
        return
    end
    --Open up the default scene (or the scene given in args)
    local infoData = json.decode(love.filesystem.read(GAME_DIRECTORY .. "/info.json"))
    if table.contains(arg, "--scene") then
        local i = table.contains(arg, "--scene", true)
        startScene = LoadScene(GAME_DIRECTORY .. "/assets/scenes/" .. arg[i+1] .. ".json")
    else
        startScene = LoadScene(infoData.startScene)
    end
    --[[
    if startScene.name == "Intro" and table.contains(arg, "--skip-intro") then
        startScene = LoadScene("desolation/assets/scenes/main_menu2.json")
    end
    ]]--
    SetScene(startScene)
end

function love.update(delta)
    ScreenWidth, ScreenHeight = love.graphics.getDimensions()
    if CurrentScene == nil then return end
    CurrentScene:update(delta)
    updateUIOffset(delta)
    love.window.setVSync(Settings.vsync)
end

function love.draw()
    if CurrentScene == nil then return end
    if CurrentScene.name ~= OldSceneName then
        OldSceneName = CurrentScene.name
        return
    end
    if MapChanged then
        MapChanged = false
        return
    end
    CurrentScene:draw()
end
