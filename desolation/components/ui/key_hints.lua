local keyHints = ENGINE_COMPONENTS.scriptComponent.new()

function keyHints:addHintToQueue(key, customDescription)
    local desc = customDescription
    if desc == nil then
        for i = 1, #InputManager.bindings.keyboard do
            if InputManager.bindings.keyboard[i][2] == key then
                desc = Loca.settings.bindingNames[InputManager.bindings.keyboard[i][1]]
                break
            end
        end
        if desc == nil then desc = "[DESC. NOT FOUND]" end
    end
    if key ~= nil then
        self.parent.queue[#self.parent.queue+1] = string.upper(key) .. " - " .. string.upper(desc)
    else
        self.parent.queue[#self.parent.queue+1] = string.upper(desc)
    end
end

function keyHints:load()
    local obj = self.parent
    local ui = obj.UIComponent
    --variables
    obj.queue = {}
    obj.currentHintTimer = 0
    --ui elements
    ui.hintText = ui:newTextLabel(
        {
            font = "disposable-droid-bold";
            begin = "center";
            position = {0, 480};
            size = 30;
            color = {1, 1, 0, 1};
        }
    )
    ui.progressSaveText = ui:newTextLabel(
        {
            text = "Progress Saved.";
            size = 30;
            color = {1, 1, 1, 0};
        }
    )
end

function keyHints:update(delta)
    local obj = self.parent
    local ui = obj.UIComponent
    --Slowly decrease the alpha of "progress saved" text
    ui.progressSaveText.color[4] = ui.progressSaveText.color[4] - delta
    if ui.progressSaveText.color[4] < 0 then ui.progressSaveText.color[4] = 0 end
    --Code regarding key hints
    if GamePaused then return end
    if #obj.queue < 1 then
        ui.hintText.color[4] = 0
        obj.currentHintTimer = 0
        return
    end
    ui.hintText.text = obj.queue[1]
    ui.hintText.color[4] = 0.45*(math.sin(obj.currentHintTimer*7))+0.55
    obj.currentHintTimer = obj.currentHintTimer + delta
    --Continue to next one
    if obj.currentHintTimer > 5 then --TODO make this value customizable
        table.remove(obj.queue, 1)
        --TODO think about adding a little cooldown. Right now, it feels
        --a bit too instant.
        obj.currentHintTimer = 0
    end
end

return keyHints