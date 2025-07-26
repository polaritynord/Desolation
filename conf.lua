ENGINE_COMPONENT_NAMES = {
    "imageComponent", "transformComponent", "particleComponent", "UIComponent"
}

ENGINE_COMPONENTS = {
    imageComponent = require "engine.components.image_component";
    UIComponent = require "engine.components.ui_component";
    particleComponent = require("engine.components.particle_component");
    scriptComponent = require("engine.components.script_component");
}

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
    t.window.width = 960 ; t.window.height = 540
    t.window.title = "DESOLATION"
    if table.contains(arg, "--no-vsync") then t.window.vsync = 0 end
    t.window.icon = "desolation/assets/images/icon.png"
    t.console = true
    ScreenWidth, ScreenHeight = t.window.width, t.window.height
end