local achievementsMenu = ENGINE_COMPONENTS.scriptComponent.new()

function achievementsMenu:load()
    local achievements = self.parent
    local _settings = achievements.parent
    local ui = achievements.UIComponent
    ui.enabled = false
    achievements.open = false
    achievements.length = 200
    achievements.realY = achievements.position[2]

    for i, name in ipairs(Achievements.other.orderList) do
        local data = Achievements[name]
        --Icon
        ui["icon_" .. name] = ui:newImage(
            {
                position = {32, 190+i*110};
                source = Assets.defaultImages["achievement_" .. name];
                scale = {4, 4};
            }
        )
        ui["title_" .. name] = ui:newTextLabel(
            {
                position = {72, 174+i*110};
                text = Loca.achievementDisplayNames[name];
                size = 40;
                font = "disposable-droid-bold";
            }
        )
        ui["desc_" .. name] = ui:newTextLabel(
            {
                position = {0, 230+i*110};
                text = Loca.achievementDescriptions[name];
            }
        )
        if data.obtained then
            ui["title_" .. name].color = {0, 1, 0, 1};
            ui["icon_" .. name].color = {0, 1, 0, 1};
        end
        achievements.length = achievements.length + 150
    end

    ui.progressText = ui:newTextLabel(
        {
            position = {0, 180};
            text = "Progress: 11/72 (15%)";
            size = 30;
            font = "disposable-droid"
        }
    )

    ui.returnButton = ui:newTextButton(
        {
            buttonText = Loca.mainMenu.returnButton;
            buttonTextSize = 30;
            position = {0, 220};
            clickEvent = function() achievements.open = false end;
            bindedKey = "escape";
        }
    )
end

function achievementsMenu:update(delta)
    local achievements = self.parent
    local settings = achievements.parent
    local ui = achievements.UIComponent

    --UI Offsetting & canvas enabling
    achievements.position[1] = 650 + MenuUIOffset
    achievements.position[2] = achievements.position[2] + (achievements.realY-achievements.position[2])*8*delta
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