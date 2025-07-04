local newGameMenu = {}

function newGameMenu:load()
    local menu = self.parent
    local ui = menu.UIComponent
    ui.enabled = false
    menu.open = false
    ui.title = ui:newTextLabel(
        {
            text = Loca.newGameMenu.title;
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
            clickEvent = function() menu.open = false ; menu.selection = nil end;
            bindedKey = "escape";
        }
    )
    ui.controllerButtons = {ui.returnButton}
end

function newGameMenu:update(delta)
    local menu = self.parent
    local ui = menu.UIComponent

    --UI Offsetting & canvas enabling
    menu.position[1] = 600 + MenuUIOffset
    ui.enabled = menu.open
    --Transparency animation
    if ui.enabled then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end

    if not ui.enabled then return end
end

return newGameMenu