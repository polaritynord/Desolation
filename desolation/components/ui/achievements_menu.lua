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
        print(Assets.achievementIcons)
        ui["icon_" .. name] = ui:newImage(
            {
                position = {0, 200};
                source = Assets.achievementIcons[name];
                scale = {5, 5};
            }
        )

        ::skip::
        i = i + 1
    end
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