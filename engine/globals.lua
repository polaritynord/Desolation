local globals = {
    -- {value, cheatsEnabled}
    cheats = {0, false};
    freecam = {0, true};
    p_speed = {140, true};
    s_vol_master = {1, false};
    s_vol_music = {1, false};
    s_vol_sfx = {1, false};
    g_vignette = {1, false}; --todo
    s_language = {"en", false};
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
