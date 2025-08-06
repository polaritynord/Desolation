local clickEvents = require("desolation.button_clickevents")
local loadGameMenu = {}

function loadGameMenu:refreshSaveButtons()
    local ui = self.parent.UIComponent
    ui.controllerButtons = {}
    --Remove old ones
    for i, element in ipairs(ui.saveButtons) do
        ui:removeElement(element)
        table.remove(ui.saveButtons, i)
    end
    --Load up saves (if they exist)
    for i, saveName in ipairs(table.reverse(love.filesystem.getDirectoryItems("saves"))) do
        local element = ui:newTextButton(
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
        element.saveName = saveName
        ui.saveButtons[#ui.saveButtons+1] = element
        ui.controllerButtons[#ui.controllerButtons+1] = element
    end
    ui.controllerButtons[#ui.controllerButtons+1] = ui.returnButton
    self.parent.realY = self.parent.position[2]
    self.parent.length = 600+35*(#ui.saveButtons-8)
end

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
    ui.saveButtons = {}
    self:refreshSaveButtons()
end

function loadGameMenu:update(delta)
    local menu = self.parent
    local ui = menu.UIComponent

    --UI Offsetting & canvas enabling
    menu.position[1] = 600 + MenuUIOffset
    menu.position[2] = menu.position[2] + (menu.realY-menu.position[2])*8*delta
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