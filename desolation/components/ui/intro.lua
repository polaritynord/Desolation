local moonshine = require("engine.lib.moonshine")

local intro = ENGINE_COMPONENTS.scriptComponent.new()

function intro:load()
    local ui = self.parent.UIComponent
    ui.alpha = 0
    ui.logo = ui:newImage(
        {
            position = {480, 270}; --dunno if this is centered, if not, sorry perfectionists
            source = Assets.images.logo;
            scale = {3, 3};
        }
    )
    ui.polarity = ui:newImage(
        {
            position = {350, 270};
            scale = {0.3, 0.3};
            source = "none";
        }
    )
    ui.title = ui:newTextLabel(
        {
            text = "";--"Made by \nPolarity";
            position = {415, 220};
            size = 54;
        }
    )
    ui.titleNord = ui:newTextLabel(
        {
            text = "";--"nord";
            position = {595, 270};
            size = 36;
        }
    )
    ui.beta = ui:newTextLabel(
        {
            text = "";
            begin = "center";
            position = {0, 480};
        }
    )
    self.timer = 0
    self.soundPlayed = false
    CurrentScene.uiShader = moonshine.chain(960, 540, moonshine.effects.glow)
end

function intro:update(delta)
    local ui = self.parent.UIComponent
    self.timer = self.timer + delta
    --Play the sound
    if not self.soundPlayed then
        Assets.sounds["ost_intro"]:play()
        self.soundPlayed = true
    end
    --Reveal da desolation
    if self.timer > 1.6 and self.timer < 4.2 then
        ui.alpha = ui.alpha + 4*delta
        if ui.alpha > 1 then ui.alpha = 1 end
    end
    --Hide da desolation
    if self.timer > 4.2 and self.timer < 5.5 then
        ui.alpha = ui.alpha - 4*delta
    end
    --Engine stuff
    if self.timer > 5.5 and self.timer < 8.1 then
        ui.polarity.source = Assets.images.nord
        ui.logo.source = nil
        ui.title.text = "Made by\nPolarity"
        ui.titleNord.text = "nord"
        ui.beta.text = Loca.intro.betaText
        ui.alpha = ui.alpha + 4*delta
    end
    --Hide everything else
    if self.timer > 8.1 then
        ui.alpha = ui.alpha - 4*delta
    end
    --Launch main menu if intro is done or skipped
    if self.timer > 10 or love.keyboard.isDown("space") then
        Assets.sounds["ost_intro"]:stop()
        local scene = LoadScene("desolation/assets/scenes/main_menu2.json")
        SetScene(scene)
    end
end

return intro