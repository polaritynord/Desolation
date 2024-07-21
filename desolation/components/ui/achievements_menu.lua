local achievementsMenu = ENGINE_COMPONENTS.scriptComponent.new()

function achievementsMenu:load()
    local achievements = self.parent
    local settings = achievements.parent
    local ui = achievements.UIComponent
    achievements.open = false

    local i = 1
    for name, data in pairs(Achievements) do
        if name == "infiniteHighScores" then goto skip end
        --Icon
        ui["icon_" .. name] = ui:newImage(
            {
                position = {32, 160+i*40};
                source = Assets.defaultImages["achievement_" .. name];
                scale = {4, 4};
            }
        )
        ui["title_" .. name] = ui:newTextLabel(
            {
                position = {72, 144+i*40};
                text = Loca.achievementDisplayNames[name];
                size = 40;
                font = "disposable-droid-bold";
            }
        )
        ui["desc_" .. name] = ui:newTextLabel(
            {
                position = {0, 200+i*40};
                text = Loca.achievementDescriptions[name];
            }
        )
        if data.obtained then
            ui["title_" .. name].color = {0, 1, 0, 1};
            ui["icon_" .. name].color = {0, 1, 0, 1};
        end

        ::skip::
        i = i + 1
    end

    ui.returnButton = ui:newTextButton(
        {
            buttonText = Loca.mainMenu.returnButton;
            buttonTextSize = 30;
            position = {0, 440};
            clickEvent = function() achievements.open = false end;
        }
    )
end

function achievementsMenu:update(delta)
    local achievements = self.parent
    local settings = achievements.parent
    local ui = achievements.UIComponent

    --UI Offsetting & canvas enabling
    achievements.position[1] = 650 + MenuUIOffset
    ui.enabled = achievements.open
    --Transparency animation
    if ui.enabled then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end

    if not ui.enabled then return end
end

return achievementsMenu