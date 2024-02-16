local globals = {
    -- {value, cheatsEnabled}
    cheats = {0, 0};
    freecam = {0, 1};
    p_speed = {140, 1};
    s_vol_master = {1, 0};
    s_vol_music = {1, 0};
    s_vol_sfx = {1, 0};
    s_graphics_vignette = {1, 0};
    s_language = {"en", 0};
    noclip = {0, 1};
    god = {0, 1};
    invisible = {0, 1};
    inf_stamina = {0, 1};
}

function GetGlobal(name)
    return globals[name][1]
end

function SetGlobal(name, value)
    globals[name][1] = value
end

return globals
