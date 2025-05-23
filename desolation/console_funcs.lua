local weaponManager = require("desolation.weapon_manager")

local consoleFunctions = {
    funcsList = {
        "assign", "run_script", "give_ammo", "clear", "help", "lorem",
        "give", "info", "bind", "map", "maps", "hurtme", "hurtarmor", "restart",
        "summon", "newprop", "newitem"
    };
}

function consoleFunctions.assignScript(devConsole, command, i)
    i = i + 1
    --Skip spaces
    while string.sub(command, i, i) == " " do
        i = i + 1
    end
    --Read key
    local temp = ""
    --Read first argument
    while string.sub(command, i, i) ~= " " do
        --Check for incorrect writing
        if i > #command then
            break
        end
        temp = temp .. string.sub(command, i, i)
        i = i + 1
    end
    local assignedKey = temp
    --Read the command to be assigned
    temp = ""
    while i <= #command do
        temp = temp .. string.sub(command, i, i)
        i = i + 1
    end
    local assignCommand = temp
    devConsole.assignedCommands[#devConsole.assignedCommands+1] = assignCommand
    devConsole.assignedKeys[#devConsole.assignedKeys+1] = assignedKey
end

function consoleFunctions.run_scriptScript(devConsole, command, i)
    i = i + 1
    --Skip spaces
    while string.sub(command, i, i) == " " do
        i = i + 1
    end
    --Read script path
    local temp = ""
    while string.sub(command, i, i) ~= " " do
        --Check for incorrect writing
        if i > #command then
            break
        end
        temp = temp .. string.sub(command, i, i)
        i = i + 1
    end
    --Read file from given path
    local scriptFile = love.filesystem.read(temp)
    if scriptFile then
        local commands = devConsole.script:readCommandsFromInput(scriptFile)
        for k = 1, #commands do
            RunConsoleCommand(commands[k])
        end
    end
end

function consoleFunctions.give_ammoScript(devConsole, command, i)
    --Return if cheats are disabled
    if GetGlobal("cheats") < 1 or CurrentScene.name ~= "Game" then return end
    local player = CurrentScene.player
    --Get weapon, and make sure the weapon is ACTUALLY a weapon
    local weapon = player.inventory.weapons[player.inventory.slot]
    if weapon == nil then return end
    --Add a magazine of ammunition to inventory
    player.inventory.ammunition[weapon.ammoType] = player.inventory.ammunition[weapon.ammoType] + weapon.magSize
    --notification in hud
    local hud = CurrentScene.hud.UIComponent
    local newNotif = hud:newImage(
        {
            position = {25, 420};
            source = Assets.images["hud_acquire_ammo"];
            color = {1, 1, 1, 0.7};
        }
    )
    newNotif.scale = {1.7, 1.7}
    newNotif.timer = 0
    hud.acquireNotifs[#hud.acquireNotifs+1] = newNotif
    newNotif.index = #hud.acquireNotifs
end

function consoleFunctions.clearScript(devConsole, command, i)
    for k, _ in pairs(devConsole.logs) do devConsole.logs[k] = nil end
end

function consoleFunctions.helpScript(devConsole, command, i)
    i = i + 1
    --Skip spaces
    while string.sub(command, i, i) == " " do
        i = i + 1
    end
    --Read title
    local temp = ""
    while string.sub(command, i, i) ~= " " do
        --Check for incorrect writing
        if i > #command then
            break
        end
        temp = temp .. string.sub(command, i, i)
        i = i + 1
    end
    --Check if its plain "help" or a staement is given
    if temp == "" then
        for k, v in ipairs(devConsole.helpTexts.titles) do
            local statementType = "global"
            if table.contains(consoleFunctions.funcsList, v, false) then
                statementType = "function"
            end
            ConsoleLog("\t\t(" .. statementType .. ") " .. v)
        end
        ConsoleLog("\tWrite \"help [statement] to view detailed information.\n\tList of statements:")
        return
    end

    --Fetch description & make sure it exists
    local descIndex = table.contains(devConsole.helpTexts.titles, temp, true)
    if descIndex == false then
        ConsoleLog("Unknown statement \"" .. temp .. "\".\nWrite \"help\" to view the full list of globals and functions.")
        return
    end
    ConsoleLog("\t" .. devConsole.helpTexts.descriptions[descIndex])
end

function consoleFunctions.loremScript(devConsole, command, i)
    ConsoleLog("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce at libero ac elit eleifend bibendum eget eu odio. Donec tristique sodales efficitur. Donec bibendum, dui quis placerat ullamcorper, odio dolor feugiat quam, vel pretium orci eros eget risus. Vestibulum ligula nunc, lacinia ut augue nec, egestas consectetur lorem. Integer ante urna, posuere id arcu vel, fermentum feugiat sem. Morbi vehicula, ligula ac iaculis viverra, augue nisi dignissim metus, in vestibulum enim nisl aliquet nunc. Mauris euismod nibh quis aliquet interdum. Cras porttitor")
end

function consoleFunctions.giveScript(devConsole, command, i)
    --Return if cheats are disabled
    if GetGlobal("cheats") < 1 then return end
    i = i + 1
    --Skip spaces
    while string.sub(command, i, i) == " " do
        i = i + 1
    end
    --Read weapon name
    local temp = ""
    while string.sub(command, i, i) ~= " " do
        --Check for incorrect writing
        if i > #command then
            break
        end
        temp = temp .. string.sub(command, i, i)
        i = i + 1
    end
    --Check if weapon exists & replace current slot with it
    local weapon = weaponManager[temp]
    if weapon == nil then return end
    local player = CurrentScene.player
    player.inventory.weapons[player.inventory.slot] = weapon.new()
end

function consoleFunctions.infoScript(devConsole, command, i)
    ConsoleLog("Made by Polaritynord")
    ConsoleLog("Using " .. ENGINE_NAME .. " build " .. ENGINE_VERSION)
    ConsoleLog(GAME_NAME .. " version " .. GAME_VERSION .. " (" .. GAME_VERSION_STATE .. ")")
end

function consoleFunctions.bindScript(devConsole, command, i)
    i = i + 1
    --Skip spaces
    while string.sub(command, i, i) == " " do
        i = i + 1
    end
    --Read binding name
    local temp = ""
    while string.sub(command, i, i) ~= " " do
        --Check for incorrect writing
        if i > #command then
            break
        end
        temp = temp .. string.sub(command, i, i)
        i = i + 1
    end
    local name = temp
    --Read the key
    i = i + 1
    temp = ""
    while i <= #command do
        temp = temp .. string.sub(command, i, i)
        i = i + 1
    end
    local key = temp
    for k = 1, #InputManager.bindings.keyboard do
        if InputManager.bindings.keyboard[k][1] == name then
            InputManager.bindings.keyboard[k][2] = key
        end
    end
end

function consoleFunctions.mapScript(devConsole, command, i)
    i = i + 1
    --Skip spaces
    while string.sub(command, i, i) == " " do
        i = i + 1
    end
    --Read map name
    local temp = ""
    while string.sub(command, i, i) ~= " " do
        --Check for incorrect writing
        if i > #command then
            break
        end
        temp = temp .. string.sub(command, i, i)
        i = i + 1
    end
    --check if map exists
    local path = string.lower(GAME_NAME) .. "/assets/maps/" .. temp .. ".json"
    if love.filesystem.getInfo(path) == nil then
        ConsoleLog("couldn't find map \"" .. temp .. "\".")
        return
    end
    local scene = LoadScene("desolation/assets/scenes/game.json")
    SetScene(scene)
    scene.mapCreator.script:loadMap(path)
end

function consoleFunctions.mapsScript(devConsole, command, i)
    local files = love.filesystem.getDirectoryItems(string.lower(GAME_NAME) .. "/assets/maps")
    for k = 1, #files do
        ConsoleLog(files[k])
    end
    ConsoleLog("List of maps:")
end

function consoleFunctions.hurtmeScript(devConsole, command, i)
    if CurrentScene.name ~= "Game" then return end
    CurrentScene.player.script:damage(10, {0, 0}, true)
end

function consoleFunctions.hurtarmorScript(devConsole, command, i)
    if CurrentScene.name ~= "Game" then return end
    CurrentScene.player.armor = CurrentScene.player.armor - 20
    local src = Assets.sounds["hurt" .. math.random(1, 3)]
    SoundManager:restartSound(src, Settings.vol_world)
end

function consoleFunctions.restartScript(devConsole, command, i)
    love.load()
end

function consoleFunctions.summonScript(devConsole, command, i)
    --Return if cheats are disabled
    if GetGlobal("cheats") < 1 then return end
    i = i + 1
    --Skip spaces
    while string.sub(command, i, i) == " " do
        i = i + 1
    end
    --Read NPC name
    local temp = ""
    while string.sub(command, i, i) ~= " " do
        --Check for incorrect writing
        if i > #command then
            break
        end
        temp = temp .. string.sub(command, i, i)
        i = i + 1
    end
    --Summon the NPC
    local player = CurrentScene.player
    local mapCreator = CurrentScene.mapCreator
    --Determine position
    local spawnPosition = {0, 0}
    if CurrentScene.player ~= nil then
        spawnPosition[1] = player.position[1] + math.cos(player.rotation)*100
        spawnPosition[2] = player.position[2] + math.sin(player.rotation)*100
    end
    mapCreator.script:spawnNPC({temp, spawnPosition})
end

function consoleFunctions.newitemScript(devConsole, command, i)
    --Return if cheats are disabled
    if GetGlobal("cheats") < 1 then return end
    i = i + 1
    --Skip spaces
    while string.sub(command, i, i) == " " do
        i = i + 1
    end
    --Read item name
    local temp = ""
    while string.sub(command, i, i) ~= " " do
        --Check for incorrect writing
        if i > #command then
            break
        end
        temp = temp .. string.sub(command, i, i)
        i = i + 1
    end
    --Summon the item
    local player = CurrentScene.player
    local mapCreator = CurrentScene.mapCreator
    --Determine position
    local spawnPosition = {0, 0}
    if CurrentScene.player ~= nil then
        spawnPosition[1] = player.position[1] + math.cos(player.rotation)*100
        spawnPosition[2] = player.position[2] + math.sin(player.rotation)*100
    end
    mapCreator.script:spawnItem({temp, spawnPosition, 0})
end

function consoleFunctions.newpropScript(devConsole, command, i)
    --Return if cheats are disabled
    if GetGlobal("cheats") < 1 then return end
    i = i + 1
    --Skip spaces
    while string.sub(command, i, i) == " " do
        i = i + 1
    end
    --Read prop name
    local temp = ""
    while string.sub(command, i, i) ~= " " do
        --Check for incorrect writing
        if i > #command then
            break
        end
        temp = temp .. string.sub(command, i, i)
        i = i + 1
    end
    --Summon the prop
    local player = CurrentScene.player
    local mapCreator = CurrentScene.mapCreator
    --Determine position
    local spawnPosition = {0, 0}
    if CurrentScene.player ~= nil then
        spawnPosition[1] = player.position[1] + math.cos(player.rotation)*100
        spawnPosition[2] = player.position[2] + math.sin(player.rotation)*100
    end
    mapCreator.script:spawnProp({temp, spawnPosition, 0, {}})
end

return consoleFunctions