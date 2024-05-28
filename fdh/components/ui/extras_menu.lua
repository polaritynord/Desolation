local extrasMenu = {}

function extrasMenu:load()
    local menu = self.parent
    local ui = menu.UIComponent
    menu.open = false
    --Element creation
    ui.playgroundButton = ui:newTextButton(
        {
            buttonText = Loca.extrasPlaygroundButton;
            buttonTextSize = 30;
            position = {0, 200};
            clickEvent = function ()
                local scene = LoadScene("fdh/assets/scenes/game.json")
                SetScene(scene)
            end
        }
    )
    ui.modeDescription = ui:newTextLabel(
        {
            text = Loca.extrasPlaygroundDesc;
            position = {200, 200};
            size = 30;
        }
    )
    ui.returnButton = ui:newTextButton(
        {
            buttonText = Loca.settingsReturnButton;
            buttonTextSize = 30;
            position = {0, 440};
            clickEvent = function() menu.open = false end;
        }
    )
end

function extrasMenu:update(delta)
    local menu = self.parent
    local ui = menu.UIComponent

    --UI Offsetting & canvas enabling
    menu.transformComponent.x = 600 + MenuUIOffset
    ui.enabled = menu.open
    --Transparency animation
    if menu.open then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end
    if not menu.open then return end
end

return extrasMenu