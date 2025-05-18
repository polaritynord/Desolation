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

function clickEvents.resetKeysButtonClick(element)
    if element.buttonText == Loca.keysMenu.resetToDefault then
        element.textFont = "disposable-droid-italic"
        element.buttonText = Loca.mainMenu.quitConfirmation
        element.confirmTimer = 2.4
    else
        --Write new binding file
        local defaultBindingsFile = love.filesystem.read("desolation/assets/default_bindings.json")
        love.filesystem.write("bindings.json", defaultBindingsFile)
        InputManager.bindings = json.decode(defaultBindingsFile)
        element.buttonText = Loca.keysMenu.resetToDefault
    end
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
        love.filesystem.write("achievements.json", json.encode(Achievements))
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
    settings.preview = table.new(Settings)
    settings.open = true
end

function clickEvents.achievementsButtonClick(element)
    if AltMenuOpen then return end
    local blabla = CurrentScene.achievements
    blabla.open = true
end

function clickEvents.changelogButtonClick(element)
    if AltMenuOpen then return end
    local changelog = CurrentScene.changelog
    changelog.open = true
end

function clickEvents.aboutButtonClick(element)
    if AltMenuOpen then return end
    local about = CurrentScene.about
    about.open = true
end

function clickEvents.campaignButtonClick(element)
    if AltMenuOpen then return end
    local campaign = CurrentScene.campaign
    campaign.open = true
end

return clickEvents