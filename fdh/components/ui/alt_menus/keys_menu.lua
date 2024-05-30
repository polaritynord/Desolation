local keysMenu = {}

function keysMenu:load()
    local keys = self.parent
    local settings = keys.parent
    local ui = keys.UIComponent

    --Create binding buttons
    for i = 1, #InputManager.bindings.keybaord do
        
    end

    --[[
    ui.returnButton = ui:newTextButton(
        {
            buttonText = Loca.settingsReturnButton;
            buttonTextSize = 30;
            position = {0, 440};
            clickEvent = function() settings.menu = nil end;
        }
    )
    ]]--
end

function keysMenu:update(delta)
    local keys = self.parent
    local settings = keys.parent
    local ui = keys.UIComponent

    --UI Offsetting & canvas enabling
    keys.transformComponent.x = 950 + MenuUIOffset
    ui.enabled = settings.menu == "keys"
    --Transparency animation
    if ui.enabled then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end

    if not ui.enabled then return end
end

return keysMenu