local globals = {}

function globals:load()
    -- {value, cheatProtection, toggleable}
    --NOTE might as well move this to a json file later
    self.cheats = {1, false, true}
    self.freecam = {0, true, true}
    self.p_speed = {200, true, false}
    self.noclip = {0, true, true}
    self.god = {0, true, true}
    self.invisible = {0, true, true}
    self.inf_stamina = {0, true, true}
    self.slippiness = {12, true, false}
    self.stamina_fill = {16, true, false}
    self.stamina_drain = {12, true, false}
    self.draw_triggers = {0, false, true}
    self.fullbright = {0, false, true} --NOTE Might change cheat protection to false.
end

function GetGlobal(name)
    if not globals[name] then return nil end
    return tonumber(globals[name][1])
end

function GetGlobalCheatValue(name)
    if not globals[name] then return nil end
    return globals[name][2]
end

function GetGlobalToggleValue(name)
    if not globals[name] then return nil end
    return globals[name][3]
end

function SetGlobal(name, value)
    globals[name][1] = value
end

return globals
