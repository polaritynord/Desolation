local keysMenu = {}

function keysMenu:load()
    local keys = self.parent
    local settings = keys.parent
    local ui = keys.UIComponent
    keys.selectedBinding = {nil, nil}

    --Create binding buttons
    for i = 1, #InputManager.bindings.keyboard do
        local binding = InputManager.bindings.keyboard[i]
        ui[binding[1]] = ui:newTextButton(
            {
                position = {0, 200+(i-1)*40};
                buttonTextSize = 30;
                buttonText = string.upper(binding[1]) .. ": " .. binding[2];
                clickEvent = function(element)
                    if element.textFont ~= "disposable-droid" then return end
                    --select button
                    keys.selectedBinding[1] = element
                    keys.selectedBinding[2] = element.binding
                    element.textFont = "disposable-droid-italic"
                    element.buttonText = "Press a key..."
                end;
            }
        )
        ui[binding[1]].binding = binding
    end

    ui.returnButton = ui:newTextButton(
        {
            buttonText = Loca.settingsReturnButton;
            buttonTextSize = 30;
            position = {0, 160};
            clickEvent = function() settings.menu = nil end;
        }
    )

    keys.length = 200 + #InputManager.bindings.keyboard*40
end

function keysMenu:update(delta)
    local keys = self.parent
    local settings = keys.parent
    local ui = keys.UIComponent

    --UI Offsetting & canvas enabling
    keys.position[1] = 950 + MenuUIOffset
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