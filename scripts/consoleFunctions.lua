local consoleFunctions = {
    funcsList = {
        "assign",
    }
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

return consoleFunctions