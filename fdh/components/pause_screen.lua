local pauseScreen = {}

function pauseScreen:load()
    local ui = self.parent.UIComponent

    ui.background = ui:newRectangle({color={0, 0, 0, 0.6}})
    
end

function pauseScreen:update(delta)
    local ui = self.parent.UIComponent
    --Set enabled state
    ui.enabled = GamePaused
    --Smooth alpha transitioning
    local smoothness = 7
    if GamePaused then
        ui.alpha = ui.alpha + (1 - ui.alpha) * smoothness * delta
        --Scale background to fit screen
        ui.background.size = {ScreenWidth+500, ScreenHeight}
    else
        ui.alpha = 0.4
    end
end

return pauseScreen