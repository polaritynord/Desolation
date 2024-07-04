local json = require "engine.lib.json"

local inputManager = {
    bindings = nil;
    inputType = "keyboard";
    joystick = nil;
    leftMouseTimer = 0;
}

function love.joystickadded(joystick)
    if inputManager.joystick ~= nil then return end
    inputManager.joystick = joystick
    print("joystick connected")
end

function love.joystickremoved(joystick)
    if inputManager.joystick ~= joystick then return end
    inputManager.joystick = nil
    inputManager.inputType = "keyboard"
    print("joystick removed")
end

function love.joystickpressed(joystick, button)
    print(button)
    if inputManager.joystick ~= joystick then return end
    if inputManager.inputType ~= "joystick" then
        inputManager.inputType = "joystick"
        print("joystick input mode active")
    end
    --Pause key
    local console = CurrentScene.devConsole
    if table.contains(InputManager:getKeys("pause_game"), button) and (console and not console.open) then
        GamePaused = not GamePaused
        CurrentScene.settings.menu = nil
        CurrentScene.settings.open = false
    end
end

function inputManager:loadBindingFile()
    local fileExists = love.filesystem.getInfo("bindings.json")
    local defaultBindingsFile = love.filesystem.read("desolation/assets/default_bindings.json")
    local defaultBindings = json.decode(defaultBindingsFile)
    --Check if binding file exists
    if fileExists and not table.contains(arg, "--default-bindings") then
        --Read binding file & save it as table
        local file = love.filesystem.read("bindings.json")
        --Decode json file
        self.bindings = json.decode(file)
        --[[Compare to default bindings: (to check if there is a missing binding)
        if #defaultBindings.keyboard > #self.bindings.keyboard then
            --Write new bindings to the binding file
            for i = #self.bindings.keyboard+1, #defaultBindings.keyboard do
                self.bindings.keyboard[i] = defaultBindings.keyboard[i]
            end
            love.filesystem.write("bindings.json", json.encode(self.bindings))
        end
        ]]--
    else
        --Write new binding file
        love.filesystem.write("bindings.json", defaultBindingsFile)
        self.bindings = json.decode(defaultBindingsFile)
    end
end

function inputManager:getKeys(inputName)
    local keys = {}
    local table = self.bindings.keyboard
    if self.inputType == "joystick" then
        table = self.bindings.joystick
    end
    for i = 1, #table do
        if table[i][1] == inputName then
            keys = {table[i][2], table[i][3]}
            return keys
        end
    end
    return nil
end

function inputManager:isPressed(name)
    local pressed = false
    local inputTable = {}
    --Check for keyboard input
    if type(name) == "string" then
        --One input
        inputTable[#inputTable+1] = name
    elseif type(name) == "table" then
        --Multiple input names
        inputTable = name
    end

    for _, v in ipairs(inputTable) do
        local keys = self:getKeys(v)
        if not keys then return end
        for i = 1, #keys do
            if self.inputType == "keyboard" then
                if love.keyboard.isDown(keys[i]) then pressed = true end
            elseif self.inputType == "joystick" then
                if self.joystick:isDown(keys[i]) then pressed = true end
            end
        end
    end
    return pressed
end

function inputManager:getAxis(num, deadzone)
    if inputManager.inputType == "keyboard" then return 0 end
    local axis = self.joystick:getAxis(num)
    if deadzone ~= nil and math.abs(axis) < deadzone then return 0 end
    return axis
end

return inputManager