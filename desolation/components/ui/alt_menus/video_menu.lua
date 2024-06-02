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
    ui.vsyncBox = ui:newCheckbox(
        {
            position = {400, 215};
            toggled = Settings.vsync;
        }
    )
    ui.vignetteText = ui:newTextLabel(
        {
            text = "Vignette: ";
            position = {0, 240};
            size = 30;
        }
    )
    ui.vignetteBox = ui:newCheckbox(
        {
            position = {400, 255};
            toggled = Settings.vignette;
        }
    )
    ui.brightnessText = ui:newTextLabel(
        {
            text = "Brightness: ";
            position = {0, 280};
            size = 30;
        }
    )
    ui.brightnessSlider = ui:newSlider(
        {
            position = {300, 285};
            baseColor = {0.5, 0.5, 0.5, 1};
            value = Settings.brightness;
        }
    )
    ui.weaponParticlesText = ui:newTextLabel(
        {
            text = "Weapon Flame Particles: ";
            position = {0, 320};
            size = 30;
        }
    )
    ui.weaponParticlesBox = ui:newCheckbox(
        {
            position = {400, 375};
            toggled = Settings.weapon_flame_particles;
        }
    )
    ui.playerTrailText = ui:newTextLabel(
        {
            text = "Player Trail Particles: ";
            position = {0, 360};
            size = 30;
        }
    )
    ui.playerTrailBox = ui:newCheckbox(
        {
            position = {400, 335};
            toggled = Settings.player_trail_particles;
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
    Settings.vsync = ui.vsyncBox.toggled
    Settings.vignette = ui.vignetteBox.toggled
    Settings.weapon_flame_particles = ui.weaponParticlesBox.toggled
    Settings.player_trail_particles = ui.playerTrailBox.toggled
    Settings.brightness = ui.brightnessSlider.value
end

return videoMenu