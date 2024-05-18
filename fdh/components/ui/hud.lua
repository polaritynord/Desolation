local hud = {}

function hud:load()
    local ui = self.parent.UIComponent
    ui.healthBar = ui:newImage(
        {
            source = Assets.images.ui.healthBar;
            position = {97, 465};
            scale = {2.35, 2.35};
        }
    )
    ui.healthMonitor = ui:newTextLabel(
        {
            text = "100";
            position = {55, 490};
            size = 48;
        }
    )
    ui.armorMonitor = ui:newTextLabel(
        {
            text = "100";
            position = {44, 448};
            size = 32;
        }
    )
end

function hud:update(delta)
    local ui = self.parent.UIComponent
end

return hud