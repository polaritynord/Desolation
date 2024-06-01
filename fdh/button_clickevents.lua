local json = require "engine.lib.json"
local clickEvents = {}

function clickEvents.quitButtonClick(element)
    if element.buttonText == Loca.quitButton then
        if math.random() < 0.05 then
            element.textFont = "pryonkalsov"
            element.buttonText = "Obey the regime for the greater good"
        else
            element.textFont = "disposable-droid-italic"
            element.buttonText = Loca.quitConfirmation
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