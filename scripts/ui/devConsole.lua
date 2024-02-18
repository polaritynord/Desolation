local interfaceManager = require("scripts.ui.interfaceManager")

function RunConsoleCommand(command)
    print("Ran console script: " .. command)
    --command = tostring(command)
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
    end
end

local devConsole = {}

function devConsole:readCommandsFromInput()
    local i = 1
    local temp = ""
    local commands = {}
    while i <= #self.commandInput do
        if string.sub(self.commandInput, i, i+1) == "&&" then
            commands[#commands+1] = temp
            temp = ""
            i = i + 2
        end
        temp = temp .. string.sub(self.commandInput, i, i)
        i = i + 1
    end
    commands[#commands+1] = temp
    return commands
end

function devConsole:load()
    self.takingInput = false
    self.commandInput = ""
    --SETUP CANVAS
    self.canvas = interfaceManager:newCanvas()
    --Window background
    self.windowBase = self.canvas:newRectangle(
        {0, 135}, {480, 300}, {0.1,0.1,0.1,0.75}, "xx"
    )
    --Window bar
    self.windowBar = self.canvas:newRectangle(
        {0, 135}, {480, 25}, {0.1,0.1,0.1,1}, "xx"
    )
    --Window title
    self.windowTitle = self.canvas:newTextLabel(
        "Developer Console", {0, 135}, 24, "xx", "left", "disposable-droid", {1,1,1,1}
    )
    --Command entry bar
    self.commandInputBar = self.canvas:newRectangle(
        {0, 415}, {480, 20}, {1,1,1,0.1}, "xx"
    )
    --Command entry text
    self.commandInputText = self.canvas:newTextLabel(
        "> ", {0, 415}, 20, "xx", "left", "disposable-droid", {1,1,1,1}
    )
    --"Press enter to send" text
    self.commandSendHint = self.canvas:newTextLabel(
        "Press ENTER to send written command. Write \"help\" for details.", {0, 400}, 15, "xx", "left", "disposable-droid", {1,1,1,0.6}
    )
end

function devConsole:updateInputText()
    self.commandInputText.text = "> " .. self.commandInput
    if self.takingInput then
        self.commandInputText.text = self.commandInputText.text .. "_"
    end
end

function devConsole:checkForInputClick()
    local mx, my = love.mouse.getPosition()
    if mx > 350 and mx < 830 and my > 415 and my < 435 and love.mouse.isDown(1) then
        self.takingInput = true
    end
end

function devConsole:update(delta)
    --Offsetting & canvas enabling
    self.canvas.position[1] = 600+MenuUIOffset
    self.canvas.enabled = DevConsoleOpen
    --Transparency animation
    if DevConsoleOpen then
        self.canvas.alpha = self.canvas.alpha + (1-self.canvas.alpha) * 12 * delta
    else
        self.canvas.alpha = 0.25
    end
    if not DevConsoleOpen then return end
    self:updateInputText()
    self:checkForInputClick()
end

function love.textinput(t)
    if devConsole.takingInput and DevConsoleOpen then
        devConsole.commandInput = devConsole.commandInput .. t
    end
end

return devConsole