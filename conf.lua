ENGINE_COMPONENT_NAMES = {
    "imageComponent", "transformComponent", "particleComponent", "UIComponent"
}

ENGINE_COMPONENTS = {
    imageComponent = require "engine.components.image_component";
    UIComponent = require "engine.components.ui_component";
    particleComponent = require("engine.components.particle_component");
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
    t.window.title = "game"
    if table.contains(arg, "--no-vsync") then t.window.vsync = 0 end
    t.window.resizable = true
    t.window.icon = "engine/assets/icon.png"
    t.window.minwidth = 960 ; t.window.minheight = 540
    t.console = true
    ScreenWidth, ScreenHeight = 960, 540
end