local audioMenu = ENGINE_COMPONENTS.scriptComponent.new()

function audioMenu:load()
    local audio = self.parent
    local settings = audio.parent
    local ui = audio.UIComponent


    ui.masterVolText = ui:newTextLabel(
        {
            text = Loca.audioMenu.masterVolume;
            position = {0, 200};
            size = 30;
        }
    )
    ui.masterVolSlider = ui:newSlider(
        {
            position = {300, 205};
            baseColor = {0.5, 0.5, 0.5, 1};
            value = Settings.vol_master;
        }
    )
    ui.sfxVolText = ui:newTextLabel(
        {
            text = Loca.audioMenu.sfxVolume;
            position = {0, 240};
            size = 30;
        }
    )
    ui.sfxVolSlider = ui:newSlider(
        {
            position = {300, 245};
            baseColor = {0.5, 0.5, 0.5, 1};
            value = Settings.vol_sfx;
        }
    )
    ui.musicVolText = ui:newTextLabel(
        {
            text = Loca.audioMenu.musicVolume;
            position = {0, 280};
            size = 30;
        }
    )
    ui.musicVolSlider = ui:newSlider(
        {
            position = {300, 285};
            baseColor = {0.5, 0.5, 0.5, 1};
            value = Settings.vol_music;
        }
    )
    ui.worldVolText = ui:newTextLabel(
        {
            text = Loca.audioMenu.worldVolume;
            position = {0, 320};
            size = 30;
        }
    )
    ui.worldVolSlider = ui:newSlider(
        {
            position = {300, 325};
            baseColor = {0.5, 0.5, 0.5, 1};
            value = Settings.vol_world;
        }
    )
    ui.returnButton = ui:newTextButton(
        {
            buttonText = Loca.settings.returnButton;
            buttonTextSize = 30;
            position = {0, 440};
            clickEvent = function() settings.menu = nil end;
        }
    )
end

function audioMenu:update(delta)
    local audio = self.parent
    local settings = audio.parent
    local ui = audio.UIComponent

    --UI Offsetting & canvas enabling
    audio.position[1] = 950 + MenuUIOffset
    ui.enabled = settings.menu == "audio"
    --Transparency animation
    if ui.enabled then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end

    if not ui.enabled then return end
    Settings.vol_master = ui.masterVolSlider.value
    Settings.vol_sfx = ui.sfxVolSlider.value
    Settings.vol_music = ui.musicVolSlider.value
    Settings.vol_world = ui.worldVolSlider.value
end

return audioMenu