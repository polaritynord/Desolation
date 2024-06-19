local videoMenu = ENGINE_COMPONENTS.scriptComponent.new()

function videoMenu:load()
    local video = self.parent
    local settings = video.parent
    local ui = video.UIComponent

    ui.vsyncText = ui:newTextLabel(
        {
            text = Loca.videoMenu.vsync;
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
            text = Loca.videoMenu.vignette;
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
    --[[
    ui.brightnessText = ui:newTextLabel(
        {
            text = Loca.videoMenu.brightness;
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
        ]]--
    ui.weaponParticlesText = ui:newTextLabel(
        {
            text = Loca.videoMenu.weaponFlameParticles;
            position = {0, 280};
            size = 30;
        }
    )
    ui.weaponParticlesBox = ui:newCheckbox(
        {
            position = {400, 295};
            toggled = Settings.weapon_flame_particles;
        }
    )
    ui.playerTrailText = ui:newTextLabel(
        {
            text = Loca.videoMenu.playerTrailParticles;
            position = {0, 320};
            size = 30;
        }
    )
    ui.playerTrailBox = ui:newCheckbox(
        {
            position = {400, 335};
            toggled = Settings.player_trail_particles;
        }
    )
    ui.destructionParticlesText = ui:newTextLabel(
        {
            text = "Destruction Particles: ";
            position = {0, 360};
            size = 30;
        }
    )
    ui.destructionParticlesBox = ui:newCheckbox(
        {
            position = {400, 375};
            toggled = Settings.destruction_particles;
        }
    )
    ui.explosionParticlesText = ui:newTextLabel(
        {
            text = "Explosion Particles: ";
            position = {0, 400};
            size = 30;
        }
    )
    ui.explosionParticlesBox = ui:newCheckbox(
        {
            position = {400, 415};
            toggled = Settings.explosion_particles;
        }
    )
end

function videoMenu:update(delta)
    local video = self.parent
    local settings = video.parent
    local ui = video.UIComponent

    --UI Offsetting & canvas enabling
    video.position[1] = 950 + MenuUIOffset
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
    Settings.destruction_particles = ui.destructionParticlesBox.toggled
    Settings.explosion_particles = ui.explosionParticlesBox.toggled
    --Settings.brightness = ui.brightnessSlider.value

    love.window.setVSync(Settings.vsync)
end

return videoMenu