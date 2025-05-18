local aboutMenu = ENGINE_COMPONENTS.scriptComponent.new()

function aboutMenu:load()
    local about = self.parent
    local _settings = about.parent
    local ui = about.UIComponent
    ui.enabled = false
    about.open = false
    ui.returnButton = ui:newTextButton(
        {
            buttonText = Loca.mainMenu.returnButton;
            buttonTextSize = 30;
            position = {0, 440};
            clickEvent = function() about.open = false ; about.selection = nil end;
        }
    )
end

function aboutMenu:update(delta)
    local about = self.parent
    local _settings = about.parent
    local ui = about.UIComponent

    --UI Offsetting & canvas enabling
    about.position[1] = 600 + MenuUIOffset
    ui.enabled = about.open
    --Transparency animation
    if ui.enabled then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end

    if not ui.enabled then return end
end

return aboutMenu