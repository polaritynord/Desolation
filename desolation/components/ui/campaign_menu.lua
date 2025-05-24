local campaignMenu = ENGINE_COMPONENTS.scriptComponent.new()

function campaignMenu:load()
    local campaign = self.parent
    local _settings = campaign.parent
    local ui = campaign.UIComponent
    ui.enabled = false
    campaign.open = false
    ui.wipText = ui:newTextLabel(
        {
            text = Loca.campaignMenu.wip;
            size = 30;
            position = {0, 200};
        }
    )
    ui.returnButton = ui:newTextButton(
        {
            buttonText = Loca.mainMenu.returnButton;
            buttonTextSize = 30;
            position = {0, 440};
            clickEvent = function() campaign.open = false ; campaign.selection = nil end;
            bindedKey = "escape";
        }
    )
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