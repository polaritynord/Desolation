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
        print(Assets.defaultImages["achievement_" .. name])
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

        ::skip::
        i = i + 1
    end

    ui.returnButton = ui:newTextButton(
        {
            buttonText = Loca.settings.returnButton;
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