local json = require("engine.lib.json")

local settings = ENGINE_COMPONENTS.scriptComponent.new()

function settings:load()
    local s = self.parent
    local ui = s.UIComponent

    s.open = false
    s.menu = nil
    ui.languages = {"en", "tr"}

    --Element creation
    ui.gameplayButton = ui:newTextButton(
        {
            buttonText = Loca.settings.gameplay;
            buttonTextSize = 30;
            position = {0, 200};
            clickEvent = function() s.menu = "gameplay" end;
        }
    )
    ui.videoButton = ui:newTextButton(
        {
            buttonText = Loca.settings.video;
            buttonTextSize = 30;
            position = {0, 240};
            clickEvent = function() s.menu = "video" end;
        }
    )
    ui.audioButton = ui:newTextButton(
        {
            buttonText = Loca.settings.audio;
            buttonTextSize = 30;
            position = {0, 280};
            clickEvent = function() s.menu = "audio" end;
        }
    )
    ui.keysButton = ui:newTextButton(
        {
            buttonText = Loca.settings.keys;
            buttonTextSize = 30;
            position = {0, 320};
            clickEvent = function() s.menu = "keys" end;
        }
    )
    ui.languageButton = ui:newTextButton(
        {
            buttonText = "Language: EN";
            buttonTextSize = 30;
            position = {0, 360};
            clickEvent = function()
                local i = table.contains(ui.languages, Settings.language, true) + 1
                if i > #ui.languages then i = 1 end
                Settings.language = ui.languages[i]
                love.filesystem.write("settings.json", json.encode(Settings))
                ui.restartWarning.text = Loca.settings.restartWarning
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
            clickEvent = function() s.open = false; s.menu = nil end;
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
    ui.languageButton.buttonText = Loca.settings.lang .. string.upper(Settings["language"])
end

return settings