local controllerHintsScript = ENGINE_COMPONENTS.scriptComponent.new()

function controllerHintsScript:updateHints(hintTable, position)
    local ui = self.parent.UIComponent
    self.hints = hintTable
    self.parent.position = position
    --Remove previous elements (need to check if this works)
    for _, v in ipairs(ui.hintElements) do
        ui:removeElement(v[1])
        ui:removeElement(v[2])
    end
    --Create the new elements
    for i, hint in ipairs(self.hints) do
        ui.hintElements[#ui.hintElements+1] = {
            --Image
            ui:newImage(
                {
                    source = Assets.images["nord_transparent"];
                    scale = {0.32, 0.32};
                    position = {(i-1)*100, 16};
                }
            ),
            --Text
            ui:newTextLabel(
                {
                    text = hint[2];
                    position = {(i-1)*100+16, 0}
                }
            )
        }
    end
end

function controllerHintsScript:load()
    local ui = self.parent.UIComponent
    self.hints = {}
    ui.hintElements = {}
end

function controllerHintsScript:update(delta)
    --local ui = self.parent.UIComponent
    --ui.enabled = InputManager.inputType == "joystick"
end

return controllerHintsScript