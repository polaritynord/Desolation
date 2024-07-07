local gameOver = ENGINE_COMPONENTS.scriptComponent.new()

function gameOver:load()
    local ui = self.parent.UIComponent
    ui.rectangle = ui:newRectangle(
        {
            size = {960, 540};
            color = {0, 0, 0, 1};
        }
    )
end

function gameOver:createInfiniteStatsElements()
    local ui = self.parent.UIComponent
    ui.timeText = ui:newTextLabel(
        {
            text = Loca.infiniteMode.statsTime .. "???";
            size = 30;
            position = {120, 100};
            color = {1, 1, 1, 0};
        }
    )
    ui.wavesText = ui:newTextLabel(
        {
            text = Loca.infiniteMode.statsWaves .. "???";
            size = 30;
            position = {120, 140};
            color = {1, 1, 1, 0};
        }
    )
    ui.killsText = ui:newTextLabel(
        {
            text = Loca.infiniteMode.statsKills .. "???";
            size = 30;
            position = {120, 180};
            color = {1, 1, 1, 0};
        }
    )
    ui.cratesBrokenText = ui:newTextLabel(
        {
            text = Loca.infiniteMode.statsCratesBroken .. "???";
            size = 30;
            position = {120, 220};
            color = {1, 1, 1, 0};
        }
    )
    ui.explosionsText = ui:newTextLabel(
        {
            text = Loca.infiniteMode.statsExplosions .. "???";
            size = 30;
            position = {120, 260};
            color = {1, 1, 1, 0};
        }
    )
    ui.accuracyText = ui:newTextLabel(
        {
            text = Loca.infiniteMode.statsAccuracy .. "???";
            size = 30;
            position = {120, 300};
            color = {1, 1, 1, 0};
        }
    )
    ui.infiniteStatsList = {ui.timeText, ui.wavesText, ui.killsText, ui.cratesBrokenText, ui.explosionsText, ui.accuracyText}
end

function gameOver:updateInfiniteStats(delta)
    local ui = self.parent.UIComponent
    --Update alpha
    for i, element in ipairs(ui.infiniteStatsList) do
        element.color[4] = element.color[4] + 1/i*3*delta
        if element.color[4] > 1 then element.color[4] = 1 end
    end
end

function gameOver:update(delta)
    local player = CurrentScene.player
    local ui = self.parent.UIComponent
    if player.health > 0 then
        --opening black fade away
        ui.rectangle.color[4] = ui.rectangle.color[4] - delta
        if ui.rectangle.color[4] < 0 then ui.rectangle.color[4] = 0 end
    else
        --game over screen background
        ui.rectangle.color = {1, 0, 0, ui.rectangle.color[4]}
        ui.rectangle.color[4] = ui.rectangle.color[4] + (0.6-ui.rectangle.color[4])*8*delta
    end
end

return gameOver