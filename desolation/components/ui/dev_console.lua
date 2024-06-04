local coreFuncs = require("coreFuncs")
local json = require("engine.lib.json")
local consoleFuncs = require("desolation.console_funcs")

local devConsole = ENGINE_COMPONENTS.scriptComponent.new()

function devConsole:readCommandsFromInput(commandInput, secondaryJoin)
    local i = 1
    local temp = ""
    local commands = {}
    local joinText = "&&"
    if secondaryJoin then joinText = "//" end
    while i <= #commandInput do
        if string.sub(commandInput, i, i+1) == joinText then
            commands[#commands+1] = temp
            temp = ""
            i = i + 2
        end
        temp = temp .. string.sub(commandInput, i, i)
        i = i + 1
    end
    commands[#commands+1] = temp
    return commands
end

function devConsole:log(text)
    self.parent.logs[#self.parent.logs+1] = text
end

function devConsole:load()
    local console = self.parent
    local ui = console.UIComponent
    ui.alpha = 0

    --Load help descriptions
    console.helpTexts = love.filesystem.read("desolation/assets/console_help_texts.json")
    console.helpTexts = json.decode(console.helpTexts)
    --Variables
    console.open = false
    console.takingInput = false
    console.commandInput = ""
    console.logs = {}
    console.assignedKeys = {};
    console.assignedCommands = {}
    console.logOffset = 0

    --Element creation
    ui.window = ui:newRectangle(
        {
            position = {0, 135};
            size = {480, 300};
            color = {0.1, 0.1, 0.1, 0.75};
        }
    )
    ui.windowBar = ui:newRectangle(
        {
            position = {0, 135};
            size = {480, 25};
            color = {0.1, 0.1, 0.1, 1};
        }
    )
    ui.windowTitle = ui:newTextLabel(
        {
            position = {0, 135};
            text = "Developer Console";
        }
    )
    ui.commandInputBar = ui:newRectangle(
        {
            position = {0, 415};
            size = {480, 20};
            color = {1, 1, 1, 0.1};
        }
    )
    ui.commandInputText = ui:newTextLabel(
        {
            position = {0, 415};
            text = "> ";
            size = 20;
        }
    )
    ui.commandSendHint = ui:newTextLabel(
        {
            position = {0, 400};
            text = "Press ENTER to send written command. Write \"help\" for details.";
            size = 15;
            color = {1, 1, 1, 0.6}
        }
    )
    ui.logs = ui:newTextLabel(
        {
            text = "";
            position = {10, 200};
            size = 15;
            color = {1, 1, 1, 0.8};
        }
    )
end

function devConsole:updateInputText(console, ui)
    ui.commandInputText.text = "> " .. console.commandInput
    if console.takingInput and math.floor(love.timer.getTime()) % 2 == 0 then
        ui.commandInputText.text = ui.commandInputText.text .. "_"
    end
end

function devConsole:checkForInputClick(console, ui)
    local mx, my = coreFuncs.getRelativeMousePosition()
    if mx > 350 and mx < 350+ui.window.size[1] and my > ui.commandInputBar.position[2] and my < ui.commandInputBar.position[2]+20 and love.mouse.isDown(1) then
        console.takingInput = true
    end
end

function devConsole:update(delta)
    local console = self.parent
    local ui = console.UIComponent

    --UI Offsetting & canvas enabling
    console.position[1] = 600 + MenuUIOffset
    ui.enabled = console.open

    --Transparency animation
    if console.open then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end

    if not console.open then return end
    self:updateInputText(console, ui)
    self:checkForInputClick(console, ui)

    --Update logs text
    if #console.logs < 1 then return end
    ui.logs.wrapLimit = ui.window.size[1]-40
    ui.logs.text = ""
    for i = #console.logs-console.logOffset, 1, -1 do
        if coreFuncs.getLineCount(ui.logs.text) > 13 then break end
        ui.logs.text = ui.logs.text .. console.logs[i] .. "\n"
    end
end

function love.textinput(t)
    local console = devConsole.parent
    if console.takingInput and console.open then
        console.commandInput = console.commandInput .. t
    end
end

function RunConsoleCommand(command)
    if command == "" then return end
    local temp = "" ; local temp2 = ""
    local i = 1
    --Skip spaces
    while string.sub(command, i, i) == " " do
        i = i + 1
    end
    --Read first argument
    while string.sub(command, i, i) ~= " " and i <= #command do
        temp = temp .. string.sub(command, i, i)
        i = i + 1
    end
    --If argument is a global variable:
    if GetGlobal(temp) then
        i = i + 1
        --Skip spaces
        while string.sub(command, i, i) == " " do
            i = i + 1
        end
        --Read value
        temp2 = ""
        while i <= #command do
            temp2 = temp2 .. string.sub(command, i, i)
            i = i + 1
        end
        --Check for cheat protection
        if GetGlobalCheatValue(temp) and GetGlobal("cheats") < 1 then return end
        --TODO: Toggle the global if no value is given
        if temp2 == "" then return end
        --Set value
        SetGlobal(temp, temp2)
        return
    end
    -- If argument is a function:
    if table.contains(consoleFuncs.funcsList, temp) then
        consoleFuncs[temp .. "Script"](devConsole.parent, command, i)
    end
end

return devConsole