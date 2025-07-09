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
    local xPos = 0
    for i, hint in ipairs(self.hints) do
        ui.hintElements[#ui.hintElements+1] = {
            --Image
            ui:newImage(
                {
                    source = Assets.images["nord_transparent"];
                    scale = {0.32, 0.32};
                    position = {xPos, 16};
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

function controllerHintsScript:extrasMenuCheck()
    if not CurrentScene.extras.open then return end
    --If there is a change in the selection:
    if self.oldExtraSelection ~= CurrentScene.extras.selection then
        if CurrentScene.extras.selection == "infinite" then --Infinite menu
            self:updateHints(
                {
                    {1, "SELECT"},
                    {2, "BACK"},
                    {12, "DOWN"},
                    {13, "UP"},
                    {15, "INCREASE"},
                    {14, "DECREASE"}
                },
                {120, 510}
            )
        else
            --Return to default
            self:updateHints(
                {
                    {1, "SELECT"},
                    {12, "DOWN"},
                    {13, "UP"}
                },
                {120, 510}
            )
        end
    end
    self.oldExtraSelection = CurrentScene.extras.selection
end

function controllerHintsScript:settingsMenuCheck()
    if not CurrentScene.settings.open then return end
    local settings = CurrentScene.settings
    if self.oldSettingsSelection ~= settings.menu then
        if settings.menu == "audio" then --Audio menu
            self:updateHints(
                {
                    {1, "SELECT"},
                    {2, "BACK"},
                    {12, "DOWN"},
                    {13, "UP"},
                    {15, "INCREASE"},
                    {14, "DECREASE"}
                },
                {120, 510}
            )
        elseif settings.menu ~= nil then --Every other menu
            self:updateHints(
                {
                    {1, "SELECT"},
                    {2, "BACK"},
                    {12, "DOWN"},
                    {13, "UP"}
                },
                {120, 510}
            )
        else --No menu selected
            self:updateHints(
                {
                    {1, "SELECT"},
                    {12, "DOWN"},
                    {13, "UP"},
                },
                {120, 510}
            )
        end
    end
    self.oldSettingsSelection = settings.menu
end

function controllerHintsScript:load()
    local ui = self.parent.UIComponent
    self.hints = {}
    ui.hintElements = {}
    self.oldExtraSelection = nil
    self.oldSettingsSelection = nil
end

function controllerHintsScript:update(delta)
    local ui = self.parent.UIComponent
    --ui.enabled = InputManager.inputType == "joystick"
    if not ui.enabled then return end
    if CurrentScene.name == "Main Menu" then
        self:extrasMenuCheck()
        self:settingsMenuCheck()
    elseif CurrentScene.name == "Game" then
        print(#self.hints)
    end
end

return controllerHintsScript