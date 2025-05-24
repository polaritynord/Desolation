local json = require("engine.lib.json")

local settings = ENGINE_COMPONENTS.scriptComponent.new()

function settings:load()
    local s = self.parent
    local ui = s.UIComponent

    s.open = false
    s.menu = nil
    ui.languages = {"en", "tr"}
    ui.menuButtons = {}

    --Element creation
    ui.menuButtons.gameplay = ui:newTextButton(
        {
            buttonText = Loca.settings.gameplay;
            buttonTextSize = 30;
            position = {0, 200};
            clickEvent = function() if s.menu == "gameplay" then s.menu = nil else s.menu = "gameplay" end end;
        }
    )
    ui.menuButtons.video = ui:newTextButton(
        {
            buttonText = Loca.settings.video;
            buttonTextSize = 30;
            position = {0, 240};
            clickEvent = function() if s.menu == "video" then s.menu = nil else s.menu = "video" end end;
        }
    )
    ui.menuButtons.audio = ui:newTextButton(
        {
            buttonText = Loca.settings.audio;
            buttonTextSize = 30;
            position = {0, 280};
            clickEvent = function() if s.menu == "audio" then s.menu = nil else s.menu = "audio" end end;
        }
    )
    ui.menuButtons.keys = ui:newTextButton(
        {
            buttonText = Loca.settings.keys;
            buttonTextSize = 30;
            position = {0, 320};
            clickEvent = function() if s.menu == "keys" then s.menu = nil else s.menu = "keys" end end;
        }
    )
    ui.languageButton = ui:newTextButton(
        {
            buttonText = "Language: EN";
            buttonTextSize = 30;
            position = {0, 360};
            clickEvent = function()
                local i = table.contains(ui.languages, s.preview.language, true) + 1
                if i > #ui.languages then i = 1 end
                s.preview.language = ui.languages[i]
                love.filesystem.write("settings.json", json.encode(s.preview))
                if s.preview.language ~= Settings.language then
                    ui.restartWarning.text = Loca.settings.restartWarning
                else
                    ui.restartWarning.text = ""
                end
            end;
        }
    )
    ui.restartWarning = ui:newTextLabel(
        {
            text = "";
            position = {0, 400};
            size = 15;
            color = {1, 0, 0, 1};
        }
    )
    ui.returnButton = ui:newTextButton(
        {
            buttonText = Loca.settings.returnButton;
            buttonTextSize = 30;
            position = {0, 440};
            clickEvent = function()
                s.open = false
                s.menu = nil
                Settings = table.new(s.preview)
                love.filesystem.write("settings.json", json.encode(Settings))
            end;
            bindedKey = "escape";
        }
    )
end

function settings:update(delta)
    local s = self.parent
    local ui = s.UIComponent

    --UI Offsetting & canvas enabling
    s.position[1] = 600 + MenuUIOffset
    ui.enabled = s.open
    --Transparency animation
    if s.open then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end

    if not s.open then return end
    ui.languageButton.buttonText = Loca.settings.lang .. string.upper(s.preview["language"])
    --button coloring if respective menu is open
    for name, element in pairs(ui.menuButtons) do
        element.color = {1, 1, 1, 1}
        if s.menu == name then
            element.color = {1, 0, 0, 1}
        end
    end
end

return settings