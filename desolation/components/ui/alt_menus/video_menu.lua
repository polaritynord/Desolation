local buttonEvents = require("desolation.button_clickevents")
local videoMenu = ENGINE_COMPONENTS.scriptComponent.new()

function videoMenu:load()
    local video = self.parent
    local settings = video.parent
    local ui = video.UIComponent
    ui.enabled = false
    video.realY = video.position[2]
    video.length = 655

    ui.title = ui:newTextLabel(
        {
            text = Loca.settings.videoTitle;
            size = 45;
            position = {0, 140};
            font = "disposable-droid-bold";
        }
    )

    ui.resolutionText = ui:newTextLabel(
        {
            text = Loca.videoMenu.resolution;
            size = 30;
            position = {0, 200};
        }
    )
    ui.resolutionButton = ui:newTextButton(
        {
            buttonText = tostring(Settings.resolution_options[Settings.resolution][1]) .. "x" .. Settings.resolution_options[Settings.resolution][2];
            buttonTextSize = 30;
            position = {350, 200};
            hoverEvent = buttonEvents.redHover;
            unhoverEvent = buttonEvents.redUnhover;
            clickEvent = function(element)
                Settings.resolution = Settings.resolution + 1
                if Settings.resolution > #Settings.resolution_options then Settings.resolution = 1 end
                element.buttonText = tostring(Settings.resolution_options[Settings.resolution][1]) .. "x" .. Settings.resolution_options[Settings.resolution][2]
                love.window.setMode(Settings.resolution_options[Settings.resolution][1], Settings.resolution_options[Settings.resolution][2], {fullscreen=love.window.getFullscreen()})
            end;
        }
    )
    ui.fullscreenButton = ui:newTextLabel(
        {
            text = Loca.videoMenu.fullscreen;
            size = 30;
            position = {0, 240};
        }
    )
    ui.fullscreenBox = ui:newCheckbox(
        {
            position = {400, 255};
            toggled = Settings.fullscreen;
            clickEvent = function(element)
                element.toggled = not element.toggled
                SoundManager:playSound(Assets.defaultSounds["button_click"], Settings.vol_sfx)
                love.window.setFullscreen(not love.window.getFullscreen(), "desktop")
                -- Set window dimensions to default
                if not love.window.getFullscreen() then
                    local res = Settings.resolution_options[Settings.resolution]
                    love.window.setMode(res[1], res[2], {})
                end
            end;
        }
    )
    ui.vsyncText = ui:newTextLabel(
        {
            text = Loca.videoMenu.vsync;
            position = {0, 280};
            size = 30;
        }
    )
    ui.vsyncBox = ui:newCheckbox(
        {
            position = {400, 295};
            toggled = Settings.vsync;
        }
    )
    ui.vignetteText = ui:newTextLabel(
        {
            text = Loca.videoMenu.vignette;
            position = {0, 320};
            size = 30;
        }
    )
    ui.vignetteBox = ui:newCheckbox(
        {
            position = {400, 335};
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
            position = {0, 360};
            size = 30;
        }
    )
    ui.weaponParticlesBox = ui:newCheckbox(
        {
            position = {400, 375};
            toggled = Settings.weapon_flame_particles;
        }
    )
    ui.bulletShellText = ui:newTextLabel(
        {
            text = Loca.videoMenu.bulletShellParticles;
            position = {0, 400};
            size = 30;
        }
    )
    ui.bulletShellBox = ui:newCheckbox(
        {
            position = {400, 415};
            toggled = Settings.bullet_shell_particles;
        }
    )
    ui.destructionParticlesText = ui:newTextLabel(
        {
            text = Loca.videoMenu.destructionParticles;
            position = {0, 440};
            size = 30;
        }
    )
    ui.destructionParticlesBox = ui:newCheckbox(
        {
            position = {400, 455};
            toggled = Settings.destruction_particles;
        }
    )
    ui.explosionParticlesText = ui:newTextLabel(
        {
            text = Loca.videoMenu.explosionParticles;
            position = {0, 480};
            size = 30;
        }
    )
    ui.explosionParticlesBox = ui:newCheckbox(
        {
            position = {400, 495};
            toggled = Settings.explosion_particles;
        }
    )
    ui.shinyMenuText = ui:newTextLabel(
        {
            text = Loca.videoMenu.shinyMenu;
            position = {0, 520};
            size = 30;
        }
    )
    ui.shinyMenuBox = ui:newCheckbox(
        {
            position = {400, 535};
            toggled = Settings.shiny_menu;
            clickEvent = function (element)
                element.toggled = not element.toggled
                SoundManager:playSound(Assets.defaultSounds["button_click"], Settings.vol_sfx)
                settings.UIComponent.restartWarning.text = Loca.settings.restartWarning
            end
        }
    )
    ui.controllerButtons = {
        ui.resolutionButton,
        ui.fullscreenBox,
        ui.vsyncBox,
        ui.vignetteBox,
        --ui.brightnessSlider,
        ui.weaponParticlesBox,
        ui.bulletShellBox,
        ui.destructionParticlesBox,
        ui.explosionParticlesBox,
        ui.shinyMenuBox
    }
end

function videoMenu:update(delta)
    local video = self.parent
    local settings = video.parent
    local ui = video.UIComponent

    --UI Offsetting & canvas enabling
    video.position[1] = 950 + MenuUIOffset
    video.position[2] = video.position[2] + (video.realY-video.position[2])*8*delta
    ui.enabled = settings.menu == "video"
    --Transparency animation
    if ui.enabled then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end

    if not ui.enabled then return end
    settings.preview.fullscreen = ui.fullscreenBox.toggled
    settings.preview.resolution = Settings.resolution
    settings.preview.vsync = ui.vsyncBox.toggled
    settings.preview.vignette = ui.vignetteBox.toggled
    settings.preview.weapon_flame_particles = ui.weaponParticlesBox.toggled
    settings.preview.bullet_shell_particles = ui.bulletShellBox.toggled
    settings.preview.destruction_particles = ui.destructionParticlesBox.toggled
    settings.preview.explosion_particles = ui.explosionParticlesBox.toggled
    settings.preview.shiny_menu = ui.shinyMenuBox.toggled
    --Settings.brightness = ui.brightnessSlider.value
    --quitting when using controller
    if InputManager:isPressed("return") then
        --UpdateControllerHints("menu_normal")
        settings.menu = nil
    end
end

return videoMenu