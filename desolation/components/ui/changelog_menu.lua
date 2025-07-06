local changelogMenu = ENGINE_COMPONENTS.scriptComponent.new()

function changelogMenu:load()
    local changelog = self.parent
    local settings = changelog.parent
    local ui = changelog.UIComponent
    ui.enabled = false
    changelog.open = false

    ui.title = ui:newTextLabel(
        {
            text = Loca.changelogMenu.title;
            size = 45;
            position = {0, 140};
            font = "disposable-droid-bold";
        }
    )
    ui.versionTitle = ui:newTextLabel(
        {
            position = {0, 200};
            text = "Alpha 1.4";
            font = "disposable-droid-bold";
            size = 30;
        }
    )
    ui.changelogText = ui:newTextLabel(
        {
            position = {0, 240};
            text = "This is some sample text I've made up from my mind to experiment with how different changelogs of current and previous versions would look like in this menu. Of course, I still have got to figure out how to fetch those texts, 'cause I can't be bothered with manually adding them to the game.";
            wrapLimit = 600;
        }
    )
    ui.returnButton = ui:newTextButton(
        {
            buttonText = Loca.mainMenu.returnButton;
            buttonTextSize = 35;
            position = {0, 440};
            clickEvent = function() changelog.open = false ; changelog.selection = nil end;
            bindedKey = "escape";
        }
    )
    ui.controllerButtons = {ui.returnButton}
end

function changelogMenu:update(delta)
    local changelog = self.parent
    local _settings = changelog.parent
    local ui = changelog.UIComponent

    --UI Offsetting & canvas enabling
    changelog.position[1] = 600 + MenuUIOffset
    ui.enabled = changelog.open
    --Transparency animation
    if ui.enabled then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end

    if not ui.enabled then return end
end

return changelogMenu