local globals = {
    -- {value, cheatsEnabled}
    cheats = {0, false};
    freecam = {0, true};
    p_speed = {140, true};
    noclip = {0, true};
    god = {0, true};
    invisible = {0, true};
    inf_stamina = {0, true};
    slippiness = {12, true};
}

function GetGlobal(name)
    if not globals[name] then return nil end
    return tonumber(globals[name][1])
end

function GetGlobalCheatValue(name)
    if not globals[name] then return nil end
    return globals[name][2]
end

function SetGlobal(name, value)
    globals[name][1] = value
end

return globals
