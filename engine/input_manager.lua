local json = require "engine.lib.json"

local inputManager = {
    bindings = nil;
    inputType = "keyboard";
}

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
        --Compare to default bindings: (to check if there is a missing binding)
        if #defaultBindings.keyboard > #self.bindings.keyboard then
            --Write new bindings to the binding file
            for i = #self.bindings.keyboard+1, #defaultBindings.keyboard do
                self.bindings.keyboard[i] = defaultBindings.keyboard[i]
            end
            love.filesystem.write("bindings.json", json.encode(self.bindings))
        end
    else
        --Write new binding file
        love.filesystem.write("bindings.json", defaultBindingsFile)
        self.bindings = json.decode(defaultBindingsFile)
    end
end

function inputManager:getKeys(inputName)
    local keys = {}
    for i = 1, #self.bindings.keyboard do
        if self.bindings.keyboard[i][1] == inputName then
            keys = {self.bindings.keyboard[i][2], self.bindings.keyboard[i][3]}
            return keys
        end
    end
    return nil
end

function inputManager:isPressed(name)
    local pressed = false
    if self.inputType == "keyboard" then
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
                if love.keyboard.isDown(keys[i]) then pressed = true end
            end
        end
    else
        --TODO Joystick input
    end
    return pressed
end

return inputManager