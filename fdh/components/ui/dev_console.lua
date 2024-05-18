local coreFuncs = require "coreFuncs"

local devConsole = {}

function devConsole:load()
    local console = self.parent
    local ui = console.UIComponent

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
    console.transformComponent.x = 600 + MenuUIOffset
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
end

return devConsole