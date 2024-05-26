local videoMenu = {}

function videoMenu:load()
    local video = self.parent
    local settings = video.parent
    local ui = video.UIComponent

    ui.testButton = ui:newTextButton(
        {
            buttonText = "Test";
            buttonTextSize = 30;
            position = {0, 200};
            clickEvent = function() Settings["vol_master"] = math.random() end;
        }
    )
    ui.returnButton = ui:newTextButton(
        {
            buttonText = "Back";
            buttonTextSize = 30;
            position = {0, 440};
            clickEvent = function() settings.menu = nil end;
        }
    )
end

function videoMenu:update(delta)
    local video = self.parent
    local settings = video.parent
    local ui = video.UIComponent

    --UI Offsetting & canvas enabling
    video.transformComponent.x = 950 + MenuUIOffset
    ui.enabled = settings.menu == "video"
    --Transparency animation
    if ui.enabled then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end

    if not ui.enabled then return end
    ui.testButton.buttonText = Settings["vol_master"]
end

return videoMenu