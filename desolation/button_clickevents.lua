local json = require "engine.lib.json"
local clickEvents = {}

function clickEvents.redHover(element)
    local delta = love.timer.getDelta()
    element.color[2] = element.color[2] + (-element.color[2])*8*delta
    element.color[3] = element.color[3] + (-element.color[3])*8*delta
end

function clickEvents.redUnhover(element)
    local delta = love.timer.getDelta()
    element.color[2] = element.color[2] + (1-element.color[2])*8*delta
    element.color[3] = element.color[3] + (1-element.color[3])*8*delta
end

function clickEvents.quitButtonClick(element)
    if element.buttonText == Loca.mainMenu.quit then
        if math.random() < 0.05 then
            element.textFont = "pryonkalsov"
            element.buttonText = "I woke you up for a reason"
        else
            element.textFont = "disposable-droid-italic"
            element.buttonText = Loca.mainMenu.quitConfirmation
        end
        element.confirmTimer = 2.4
    else
        love.filesystem.write("settings.json", json.encode(Settings))
        love.event.quit()
    end
end

function clickEvents.extrasButtonClick(element)
    if AltMenuOpen then return end
    local extras = CurrentScene.extras
    extras.open = true
end

function clickEvents.settingsButtonClick(element)
    if AltMenuOpen then return end
    local settings = CurrentScene.settings
    settings.open = true
end

return clickEvents