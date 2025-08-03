
function table.new(t)
        -- Taken from http://lua-users.org/wiki/CopyTable/
    local orig = t
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
        copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function table.contains(table, element, returnIndex)
    for i, value in pairs(table) do
      if value == element then
        if returnIndex then
            return i
        else
            return true
        end
      end
    end
    return false
end

function love.conf(t)
    t.window.width = 960; t.window.height = 540
    t.window.title = "DESOLATION Map Editor"
    t.window.vsync = 0
    t.window.resizable = true
    t.console = true
    MapGiven = arg[2] ~= nil
end