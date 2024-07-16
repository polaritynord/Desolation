local keysMenu = ENGINE_COMPONENTS.scriptComponent.new()

function keysMenu:load()
    local keys = self.parent
    local settings = keys.parent
    local ui = keys.UIComponent
    keys.selectedBinding = {nil, nil}
    keys.realY = keys.position[2]

    --Create binding buttons
    for i = 1, #InputManager.bindings.keyboard do
        local binding = InputManager.bindings.keyboard[i]
        local bindingTitle
        if Loca.settings.bindingNames[binding[1]] ~= nil then
            bindingTitle = Loca.settings.bindingNames[binding[1]]
        else
            bindingTitle = string.upper(binding[1])
        end
        ui[binding[1]] = ui:newTextButton(
            {
                position = {0, 200+(i-1)*40};
                buttonTextSize = 30;
                buttonText = bindingTitle .. ": " .. string.upper(binding[2]);
                clickEvent = function(element)
                    if element.textFont ~= "disposable-droid" then return end
                    --select button
                    keys.selectedBinding[1] = element
                    keys.selectedBinding[2] = element.binding
                    element.textFont = "disposable-droid-italic"
                    element.buttonText = Loca.keysMenu.pressAKey
                end;
            }
        )
        ui[binding[1]].title = bindingTitle
        ui[binding[1]].binding = binding
    end
    keys.length = 200 + #InputManager.bindings.keyboard*40
    --Scrollbar
    ui.scrollbar = ui:newScrollbar(
        {
            position = {400, 250};
            maxValue = 0.7; --Done by hand for now, figure out a better way later
            baseColor = {0.5, 0.5, 0.5, 0.6};
            barColor = {0.85, 0.85, 0.85, 1};
        }
    )
    ui.scrollbar.realY = ui.scrollbar.position[2]
end

function keysMenu:update(delta)
    local keys = self.parent
    local settings = keys.parent
    local ui = keys.UIComponent

    --UI Offsetting & canvas enabling
    keys.position[1] = 950 + MenuUIOffset
    keys.position[2] = -ui.scrollbar.value*keys.length--keys.position[2] + (keys.realY-keys.position[2])*12*delta
    ui.enabled = settings.menu == "keys"
    --Transparency animation
    if ui.enabled then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end
    if not ui.enabled then return end
    --keys.realY = -ui.scrollbar.value*keys.length
    ui.scrollbar.position[2] = ui.scrollbar.realY - keys.position[2]
end

return keysMenu