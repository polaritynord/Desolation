local chapterTitle = ENGINE_COMPONENTS.scriptComponent.new()

function chapterTitle:setTitle(title)
    local ui = self.parent.UIComponent
    ui.title.text = title
    self.waitTimer = 0
end

function chapterTitle:load()
    local ui = self.parent.UIComponent
    ui.title = ui:newTextLabel(
        {
            text = "";
            begin = "center";
            size = 45;
            font = "disposable-droid-bold";
            position = {-25, 300};
            color = {1, 1, 1, 0};
        }
    )
    self.waitTimer = 0
end

function chapterTitle:update(delta)
    if GamePaused then return end
    local ui = self.parent.UIComponent
    if ui.title.text == "" then return end
    if self.waitTimer > 3 then
        ui.title.color[4] = ui.title.color[4] - 1.3*delta
        if ui.title.color[4] < 0 then
            self.waitTimer = 0
            ui.title.text = ""
        end
    else
        ui.title.color[4] = ui.title.color[4] + 2*delta
    end
    if ui.title.color[4] > 1 then
        ui.title.color[4] = 1
        self.waitTimer = self.waitTimer + delta
    end
end

return chapterTitle