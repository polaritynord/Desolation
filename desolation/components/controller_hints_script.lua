local controllerHintsScript = ENGINE_COMPONENTS.scriptComponent.new()

function controllerHintsScript:updateHints(hintName)
    local ui = self.parent.UIComponent
    self.hints = self.hintPresets[hintName][1]
    self.parent.position = self.hintPresets[hintName][2]
    --Remove previous elements (need to check if this works)
    for _, v in ipairs(ui.hintElements) do
        v[1].quad:release()
        ui:removeElement(v[1])
        ui:removeElement(v[2])
    end
    --Create the new elements
    local xPos = 0
    for i, hint in ipairs(self.hints) do
        ui.hintElements[#ui.hintElements+1] = {
            --Image
            ui:newImage(
                {
                    source = Assets.defaultImages.controller_hints_ps;
                    quad = love.graphics.newQuad((hint[1]-1)*33, 0, 32, 32, Assets.defaultImages.controller_hints_ps);
                    scale = {0.65, 0.65};
                    position = {xPos-8, 6};
                }
            ),
            --Text
            ui:newTextLabel(
                {
                    text = hint[2];
                    position = {xPos+16, 4}
                }
            )
        }
        --Determine x position
        xPos = xPos + hint[2]:len()*12 + 35
    end
end

function UpdateControllerHints(hintName)
    if InputManager.inputType ~= "joystick" then return end
    controllerHintsScript:updateHints(hintName)
end

function controllerHintsScript:load()
    local ui = self.parent.UIComponent
    self.hints = {}
    ui.hintElements = {}
    self.oldExtraSelection = nil
    self.oldSettingsSelection = nil
    self.hintPresets =
    {
        menu_normal = {
            {
                {1, "SELECT"},
                {13, "DOWN"},
                {12, "UP"},
            },
            {120, 510}
        },
        menu_withreturn = {
            {
                {1, "SELECT"},
                {2, "BACK"},
                {13, "DOWN"},
                {12, "UP"}
            },
            {120, 510}
        },
        menu_sliders = {
            {
                {1, "SELECT"},
                {2, "BACK"},
                {13, "DOWN"},
                {12, "UP"},
                {15, "INCREASE"},
                {14, "DECREASE"}
            },
            {120, 510}
        },
        game_none = {{}, {0, 0}}
    }
    self:updateHints("menu_normal")
end

function controllerHintsScript:update(delta)
    local ui = self.parent.UIComponent
    ui.enabled = InputManager.inputType == "joystick"
    if not ui.enabled then return end
end

return controllerHintsScript