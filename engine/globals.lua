local globals = {
    -- {value, cheatsEnabled, toggleable}
    cheats = {0, false, true};
    freecam = {0, true, true};
    p_speed = {140, true, false};
    noclip = {0, true, true};
    god = {0, true, true};
    invisible = {0, true, true};
    inf_stamina = {0, true, true};
    slippiness = {12, true, false};
}

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
