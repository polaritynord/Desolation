--THIS SCRIPT IS UNUSED

local campaignMenu = ENGINE_COMPONENTS.scriptComponent.new()

function campaignMenu:load()
    local campaign = self.parent
    local _settings = campaign.parent
    local ui = campaign.UIComponent
    ui.enabled = false
    campaign.open = false
    ui.title = ui:newTextLabel(
        {
            text = Loca.campaignMenu.title;
            size = 45;
            position = {0, 140};
            font = "disposable-droid-bold";
        }
    )
    ui.newGameButton = ui:newTextButton(
        {
            buttonText = "New Game";
            position = {0, 200};
            buttonTextSize = 30;
        }
    )
    ui.loadGameButton = ui:newTextButton(
        {
            buttonText = "Load Game";
            position = {0, 240};
            buttonTextSize = 30;
        }
    )
    --[[
    ui.wipText = ui:newTextLabel(
        {
            text = Loca.campaignMenu.wip;
            size = 30;
            position = {0, 200};
        }
    )
    ]]--
    ui.returnButton = ui:newTextButton(
        {
            buttonText = Loca.mainMenu.returnButton;
            buttonTextSize = 30;
            position = {0, 440};
            clickEvent = function() campaign.open = false ; campaign.selection = nil end;
            bindedKey = "escape";
        }
    )
    ui.controllerButtons = {ui.returnButton}
end

function campaignMenu:update(delta)
    local campaign = self.parent
    local _settings = campaign.parent
    local ui = campaign.UIComponent

    --UI Offsetting & canvas enabling
    campaign.position[1] = 600 + MenuUIOffset
    ui.enabled = campaign.open
    --Transparency animation
    if ui.enabled then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end

    if not ui.enabled then return end
end

return campaignMenu