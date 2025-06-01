local aboutMenu = ENGINE_COMPONENTS.scriptComponent.new()

function aboutMenu:load()
    local about = self.parent
    local _settings = about.parent
    local ui = about.UIComponent
    ui.enabled = false
    about.open = false
    ui.title = ui:newTextLabel(
        {
            text = Loca.aboutMenu.title;
            size = 45;
            position = {0, 140};
            font = "disposable-droid-bold";
        }
    )
    ui.returnButton = ui:newTextButton(
        {
            buttonText = Loca.mainMenu.returnButton;
            buttonTextSize = 30;
            position = {0, 440};
            clickEvent = function() about.open = false ; about.selection = nil end;
            bindedKey = "escape";
        }
    )
    ui.controllerButtons = {ui.returnButton}
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