local json = require("engine.lib.json")

local startup = {}

local function hover(element)
    local delta = love.timer.getDelta()
    element.color[2] = element.color[2] + (-element.color[2])*8*delta
    element.color[3] = element.color[3] + (-element.color[3])*8*delta
end

local function unhover(element)
    local delta = love.timer.getDelta()
    element.color[2] = element.color[2] + (1-element.color[2])*8*delta
    element.color[3] = element.color[3] + (1-element.color[3])*8*delta
end

function startup:load()
    --skip if this is not the first time playing
    if not Settings.first_time_playing then
        local scene = LoadScene("desolation/assets/scenes/intro.json")
        SetScene(scene)
        return
    end
    Settings.first_time_playing = false
    --elements
    local ui = self.parent.UIComponent
    ui.languages = {"en", "tr"}
    ui.selectText = ui:newTextLabel(
        {
            text = "Select a Language:";
            size = 30;
            position = {365, 300}
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
            hoverEvent = hover;
            unhoverEvent = unhover;
        }
    )
    ui.continueButton = ui:newTextButton(
        {
            position = {425, 430};
            buttonText = "Proceed";
            buttonTextSize = 30;
            hoverEvent = hover;
            unhoverEvent = unhover;
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