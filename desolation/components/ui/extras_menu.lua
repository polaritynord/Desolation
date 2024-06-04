local extrasMenu = ENGINE_COMPONENTS.scriptComponent.new()

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
                local scene = LoadScene("desolation/assets/scenes/game.json")
                SetScene(scene)
            end;
            hoverEvent = function (element)
                ui.modeDescription.text = Loca.extrasPlaygroundDesc
                ui.modeDescription.position[2] = element.position[2]
            end;
        }
    )
    ui.endlessButton = ui:newTextButton(
        {
            buttonText = "Extra Mode 1";
            buttonTextSize = 30;
            position = {0, 240};
            hoverEvent = function (element)
                ui.modeDescription.text = "Description goes here"
                ui.modeDescription.position[2] = element.position[2]
            end;
        }
    )
    ui.endlessButton2 = ui:newTextButton(
        {
            buttonText = "Extra Mode 2";
            buttonTextSize = 30;
            position = {0, 280};
            hoverEvent = function (element)
                ui.modeDescription.text = "Description goes here";
                ui.modeDescription.position[2] = element.position[2]
            end;
        }
    )
    ui.endlessButton3 = ui:newTextButton(
        {
            buttonText = "Extra Mode 3";
            buttonTextSize = 30;
            position = {0, 320};
            hoverEvent = function (element)
                ui.modeDescription.text = "Description goes here";
                ui.modeDescription.position[2] = element.position[2]
            end;
        }
    )
    ui.modeDescription = ui:newTextLabel(
        {
            text = "";
            font = "disposable-droid-italic";
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
    menu.position[1] = 600 + MenuUIOffset
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