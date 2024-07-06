local buttonEvents = require("desolation.button_clickevents")
local json = require("engine.lib.json")

local startup = {}

function startup:load()
    --skip if this is not the first time playing
    if not Settings.first_time_playing then
        local scene = LoadScene("desolation/assets/scenes/intro.json")
        SetScene(scene)
        return
    end
    --give "thanks for playing" achievement
    GiveAchievement("thanksForPlaying")
    --ui setup
    Settings.first_time_playing = false
    love.filesystem.write("settings.json", json.encode(Settings))
    --elements
    local ui = self.parent.UIComponent
    ui.languages = {"en", "tr"}
    ui.selectText = ui:newTextLabel(
        {
            text = "Select a Language:";
            size = 30;
            position = {365, 300};
        }
    )
    ui.selectButton = ui:newTextButton(
        {
            buttonText = string.upper(Settings.language);
            buttonTextSize = 42;
            position = {450, 360};
            clickEvent = function ()
                local i = table.contains(ui.languages, Settings.language, true) + 1
                if i > #ui.languages then i = 1 end
                Settings.language = ui.languages[i]
                love.filesystem.write("settings.json", json.encode(Settings))
            end;
            hoverEvent = buttonEvents.redHover;
            unhoverEvent = buttonEvents.redUnhover;
        }
    )
    ui.continueButton = ui:newTextButton(
        {
            position = {425, 430};
            buttonText = "Proceed";
            buttonTextSize = 30;
            hoverEvent = buttonEvents.redHover;
            unhoverEvent = buttonEvents.redUnhover;
            clickEvent = function ()
                love.load()
            end;
        }
    )
end

function startup:update(delta)
    local ui = self.parent.UIComponent
    ui.selectButton.buttonText = string.upper(Settings["language"])
end

return startup