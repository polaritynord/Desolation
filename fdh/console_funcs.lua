local weaponManager = require("scripts.weaponManager")

local consoleFunctions = {
    funcsList = {
        "assign", "run_script", "give_ammo", "clear", "help", "lorem",
        "give", "info"
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
        local commands = devConsole:readCommandsFromInput(scriptFile)
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
            devConsole.script:log("\t\t(" .. statementType .. ") " .. v)
        end
        devConsole.script:log("\tWrite \"help [statement] to view detailed information.\n\tList of statements:")
        return
    end

    --Fetch description & make sure it exists
    local descIndex = table.contains(devConsole.helpTexts.titles, temp, true)
    if descIndex == false then
        devConsole.script:log("Unknown statement \"" .. temp .. "\".\nWrite \"help\" to view the full list of globals and functions.")
        return
    end
    devConsole.script:log("\t" .. devConsole.helpTexts.descriptions[descIndex])
end

function consoleFunctions.loremScript(devConsole, command, i)
    devConsole.script:log("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce at libero ac elit eleifend bibendum eget eu odio. Donec tristique sodales efficitur. Donec bibendum, dui quis placerat ullamcorper, odio dolor feugiat quam, vel pretium orci eros eget risus. Vestibulum ligula nunc, lacinia ut augue nec, egestas consectetur lorem. Integer ante urna, posuere id arcu vel, fermentum feugiat sem. Morbi vehicula, ligula ac iaculis viverra, augue nisi dignissim metus, in vestibulum enim nisl aliquet nunc. Mauris euismod nibh quis aliquet interdum. Cras porttitor")
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
    Player.inventory.weapons[Player.inventory.slot] = weapon.new()
end

function consoleFunctions.infoScript(devConsole, command, i)
    devConsole.script:log("Made by Polaritynord")
    devConsole.script:log("Using " .. ENGINE_NAME .. " build " .. ENGINE_VERSION)
    devConsole.script:log(GAME_NAME .. " version " .. GAME_VERSION .. " (" .. GAME_VERSION_STATE .. ")")
end

return consoleFunctions