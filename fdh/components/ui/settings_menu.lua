local settings = {}

function settings:load()
    local s = self.parent
    local ui = s.UIComponent

    s.open = false
    s.menu = nil

    --Element creation
    ui.videoButton = ui:newTextButton(
        {
            buttonText = "Video";
            buttonTextSize = 30;
            position = {0, 200};
            clickEvent = function() s.menu = "video" end;
        }
    )
    ui.audioButton = ui:newTextButton(
        {
            buttonText = "Audio";
            buttonTextSize = 30;
            position = {0, 240};
        }
    )
    ui.keysButton = ui:newTextButton(
        {
            buttonText = "Keys";
            buttonTextSize = 30;
            position = {0, 280};
        }
    )
    ui.languageButton = ui:newTextButton(
        {
            buttonText = "Language: EN";
            buttonTextSize = 30;
            position = {0, 320};
        }
    )
    ui.returnButton = ui:newTextButton(
        {
            buttonText = "Return";
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
    s.transformComponent.x = 600 + MenuUIOffset
    ui.enabled = s.open
    --Transparency animation
    if s.open then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end

    if not s.open then return end
end

return settings