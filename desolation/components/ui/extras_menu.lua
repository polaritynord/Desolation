local buttonEvents = require "desolation.button_clickevents"
local extrasMenu = ENGINE_COMPONENTS.scriptComponent.new()

function extrasMenu:load()
    local menu = self.parent
    local ui = menu.UIComponent
    menu.open = false
    ui.enabled = false
    menu.selection = nil
    --Element creation
    ui.title = ui:newTextLabel(
        {
            text = Loca.extrasMenu.title;
            size = 45;
            position = {0, 140};
            font = "disposable-droid-bold";
        }
    )
    ui.playgroundButton = ui:newTextButton(
        {
            buttonText = Loca.extrasMenu.playground;
            buttonTextSize = 30;
            position = {0, 200};
            clickEvent = function ()
                local scene = LoadScene("desolation/assets/scenes/game.json")
                SetScene(scene)
                scene.mapCreator.script:loadMap("playground_old")
                SetGlobal("cheats", 1)
            end;
            hoverEvent = function (element)
                ui.modeDescription.text = Loca.extrasMenu.playgroundDesc
                ui.modeDescription.position[2] = element.position[2]
                buttonEvents.defaultHoverEvent(element)
            end;
        }
    )
    ui.infiniteButton = ui:newTextButton(
        {
            buttonText = Loca.extrasMenu.infinite;
            buttonTextSize = 30;
            position = {0, 240};
            clickEvent = function ()
                if menu.selection == "infinite" then
                    menu.selection = nil
                    --UpdateControllerHints("menu_normal")
                else
                    menu.selection = "infinite"
                    --UpdateControllerHints("menu_sliders")
                end
            end;
            hoverEvent = function (element)
                ui.modeDescription.text = Loca.extrasMenu.infiniteDesc
                ui.modeDescription.position[2] = element.position[2]
                buttonEvents.defaultHoverEvent(element)
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
            buttonText = Loca.mainMenu.returnButton;
            buttonTextSize = 30;
            position = {0, 440};
            clickEvent = function()
                menu.open = false
                menu.selection = nil
                --UpdateControllerHints("menu_normal")
            end;
            bindedKey = "escape";
        }
    )
    ui.controllerButtons = {ui.playgroundButton, ui.infiniteButton, ui.endlessButton2, ui.endlessButton3, ui.returnButton}
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
    --Make infinite button seem red if currently in that menu (TODO apply this to other modes if i happen to add them)
    if menu.selection == "infinite" then
        ui.infiniteButton.color = {1, 0, 0, 1}
    else
        ui.infiniteButton.color = {1, 1, 1, 1}
    end
    if not menu.open then return end
    if menu.selection ~= nil then
        ui.modeDescription.text = ""
    end
end

return extrasMenu