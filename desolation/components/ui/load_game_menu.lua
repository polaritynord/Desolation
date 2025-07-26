local clickEvents = require("desolation.button_clickevents")
local loadGameMenu = {}

function loadGameMenu:load()
    local menu = self.parent
    local ui = menu.UIComponent
    ui.enabled = false
    menu.open = false
    ui.title = ui:newTextLabel(
        {
            text = Loca.loadGameMenu.title;
            size = 45;
            position = {0, 140};
            font = "disposable-droid-bold";
        }
    )
    --ui.tempButton = ui:newTextButton(
    --    {
    --        buttonText = "Load test.sav";
    --        position = {0, 200};
    --        buttonTextSize = 30;
    --        clickEvent = function ()
    --            local scene = LoadScene("desolation/assets/scenes/game.json")
    --            SetScene(scene)
    --            scene.mapCreator.script:loadSave("saves/test.sav")
    --        end
    --    }
    --)
    ui.noSavesFound = ui:newTextLabel(
        {
            text = Loca.loadGameMenu.noSavesFound;
            size = 30;
            position = {0, 200};
            color = {1, 1, 1, 0};
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
    --Load up saves (if they exist)
    for i, saveName in ipairs(table.reverse(love.filesystem.getDirectoryItems("saves"))) do
        ui["saveButton" .. i] = ui:newTextButton(
            {
                buttonText = string.sub(saveName, 1, saveName:len()-4);
                position = {0, 200+40*(i-1)};
                hoverEvent = clickEvents.redHover;
                unhoverEvent = clickEvents.redUnhover;
                clickEvent = function (element)
                    local scene = LoadScene("desolation/assets/scenes/game.json")
                    SetScene(scene)
                    scene.mapCreator.script:loadSave("saves/" .. element.saveName)
                end
            }
        )
        ui["saveButton" .. i].saveName = saveName
        ui.controllerButtons[#ui.controllerButtons+1] = ui["saveButton" .. i]
    end
end

function loadGameMenu:update(delta)
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
    local saves = love.filesystem.getDirectoryItems("saves")
    if #saves > 6 then
        ui.returnButton.position[2] = 440 + 40*(#saves-6)
    else
        ui.returnButton.position[2] = 440
    end

    --Check for save count
    if love.filesystem.getInfo("saves") then
        if #saves > 0 then
            ui.noSavesFound.color[4] = 0
            --Write save files here
        else
            --Show no saves found here
            ui.noSavesFound.color[4] = 1
        end
    end
end

return loadGameMenu