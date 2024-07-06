local buttonEvents = require "desolation.button_clickevents"
local infiniteMenu = ENGINE_COMPONENTS.scriptComponent.new()

function infiniteMenu:load()
    local infinite = self.parent
    local ui = infinite.UIComponent
    infinite.difficulty = 1

    ui.difficultyPicker = ui:newTextButton(
        {
            buttonText = "Difficulty: " .. string.upper(Loca.extrasMenu.infiniteDifficulties[infinite.difficulty]);
            position = {0, 200};
            buttonTextSize = 30;
            hoverEvent = buttonEvents.redHover;
            unhoverEvent = buttonEvents.redUnhover;
            clickEvent = function (element)
                infinite.difficulty = infinite.difficulty + 1
                if infinite.difficulty > 3 then infinite.difficulty = 1 end
                element.buttonText = "Difficulty: " .. string.upper(Loca.extrasMenu.infiniteDifficulties[infinite.difficulty])
                --TODO difficulty descriptions
            end
        }
    )
    ui.difficultyDescription = ui:newTextLabel(
        {
            position = {0, 240};
            size = 16;
        }
    )
    ui.startGameButton = ui:newTextButton(
        {
            buttonText = "Start Game";
            buttonTextSize = 30;
            position = {0, 440};
            clickEvent = function() end;
        }
    )
end

function infiniteMenu:update(delta)
    local infinite = self.parent
    local menu = infinite.parent
    local ui = infinite.UIComponent
    
    --UI Offsetting & canvas enabling
    infinite.position[1] = 950 + MenuUIOffset
    ui.enabled = menu.selection == "infinite"
    --Transparency animation
    if ui.enabled then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end

    if not ui.enabled then return end
end

return infiniteMenu