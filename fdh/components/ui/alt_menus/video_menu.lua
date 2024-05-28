local videoMenu = {}

function videoMenu:load()
    local video = self.parent
    local settings = video.parent
    local ui = video.UIComponent

    ui.vsyncText = ui:newTextLabel(
        {
            text = "VSync: ";
            position = {0, 200};
            size = 30;
        }
    )
    ui.vignetteText = ui:newTextLabel(
        {
            text = "Vignette: ";
            position = {0, 240};
            size = 30;
        }
    )
    ui.brightnessText = ui:newTextLabel(
        {
            text = "Brightness: ";
            position = {0, 280};
            size = 30;
        }
    )
    ui.weaponParticlesText = ui:newTextLabel(
        {
            text = "Weapon Flame Particles: ";
            position = {0, 320};
            size = 30;
        }
    )
    ui.playerTrailText = ui:newTextLabel(
        {
            text = "Player Trail Particles: ";
            position = {0, 360};
            size = 30;
        }
    )
    ui.returnButton = ui:newTextButton(
        {
            buttonText = Loca.settingsReturnButton;
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
end

return videoMenu