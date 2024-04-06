local consoleFunctions = {
    funcsList = {
        "assign", "run_script", "give_ammo", "clear", "help"
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
    if GetGlobal("cheats") < 1 then return end
    --Get weapon, and make sure the weapon is ACTUALLY a weapon
    local weapon = Player.inventory.weapons[Player.inventory.slot]
    if weapon == nil then return end
    --Add a magazine of ammunition to inventory
    Player.inventory.ammunition[weapon.ammoType] = Player.inventory.ammunition[weapon.ammoType] + weapon.magSize
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
            devConsole:log("\t(" .. statementType .. ") " .. v)
        end
        devConsole:log("List of statements:")
        return
    end

    --Fetch description & make sure it exists
    local descIndex = table.contains(devConsole.helpTexts.titles, temp, true)
    if descIndex == false then
        devConsole:log("Unknown statement \"" .. temp .. "\".\nWrite \"help\" to view the full list of globals and functions.")
        return
    end
    devConsole:log(devConsole.helpTexts.descriptions[descIndex])
end

return consoleFunctions