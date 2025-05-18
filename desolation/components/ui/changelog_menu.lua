local changelogMenu = ENGINE_COMPONENTS.scriptComponent.new()

function changelogMenu:load()
    local changelog = self.parent
    local settings = changelog.parent
    local ui = changelog.UIComponent
    ui.enabled = false
    changelog.open = false

    ui.test = ui:newTextLabel(
        {
            text = "This menu is most likely going to be empty\nuntil I figure out how to fetch text from the\nweb lol" ..
                "\n\nHonestly shouldn't be that hard, but I think I\ngotta create a github website";
            size = 30;
            position = {0, 200};
        }
    )
    ui.returnButton = ui:newTextButton(
        {
            buttonText = Loca.mainMenu.returnButton;
            buttonTextSize = 30;
            position = {0, 440};
            clickEvent = function() changelog.open = false ; changelog.selection = nil end;
        }
    )
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