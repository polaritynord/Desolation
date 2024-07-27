local achievementUI = {}

function achievementUI:load()
    self.parent.queue = {}
    self.timer = 0

    local ui = self.parent.UIComponent
    ui.icon = ui:newImage(
        {
            source = "none";
            position = {330, 330};
            scale = {5, 5};
            color = {1, 1, 0, 0};
        }
    )
    ui.title = ui:newTextLabel(
        {
            text = Loca.game.achievementObtained;
            size = 30;
            position = {385, 290};
            color = {1, 1, 0, 0};
        }
    )
    ui.achievementName = ui:newTextLabel(
        {
            text = "";
            position = {385, 320};
            font = "disposable-droid-bold";
            size = 48;
            color = {1, 1, 0, 0};
        }
    )
end

function achievementUI:update(delta)
    --Check queue
    local ui = self.parent.UIComponent
    --Update UI content of current achievement
    if self.parent.currentAchivement ~= nil then
        --Set texts & image
        ui.icon.source = Assets.defaultImages["achievement_" .. self.parent.currentAchivement]
        ui.achievementName.text = Loca.achievementDisplayNames[self.parent.currentAchivement]
        --Increment timer
        self.timer = self.timer + delta
        if self.timer > 3 then
            --Fade out
            ui.icon.color[4] = ui.icon.color[4] - delta
            ui.title.color[4] = ui.title.color[4] - delta
            ui.achievementName.color[4] = ui.achievementName.color[4] - delta
            --End current achievement
            if ui.icon.color[4] < 0.01 then
                self.parent.currentAchivement = nil
            end
        else
            --Fade in
            ui.icon.color[4] = ui.icon.color[4] + 2*delta
            ui.title.color[4] = ui.title.color[4] + 2*delta
            ui.achievementName.color[4] = ui.achievementName.color[4] + 2*delta
        end
    else
        self.timer = 0
        --Move on to the next achievement
        if #self.parent.queue > 0 then
            self.parent.currentAchivement = self.parent.queue[1]
            table.remove(self.parent.queue, 1)
        end
    end
    if ui.icon.color[4] > 1 then ui.icon.color[4] = 1 end
    if ui.icon.color[4] < 0 then ui.icon.color[4] = 0 end
    if ui.achievementName.color[4] > 1 then ui.achievementName.color[4] = 1 end
    if ui.achievementName.color[4] < 0 then ui.achievementName.color[4] = 0 end
    if ui.title.color[4] > 1 then ui.title.color[4] = 1 end
    if ui.title.color[4] < 0 then ui.title.color[4] = 0 end
end

return achievementUI