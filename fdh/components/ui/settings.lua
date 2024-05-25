local settings = {}

function settings:load()
    local s = self.parent
    local ui = s.UIComponent

    s.open = false
    s.menu = "video"

    --Element creation
    ui.window = ui:newRectangle(
        {
            position = {0, 135};
            size = {480, 300};
            color = {0.1, 0.1, 0.1, 0.75};
        }
    )
    ui.windowBar = ui:newRectangle(
        {
            position = {0, 135};
            size = {480, 25};
            color = {0.1, 0.1, 0.1, 1};
        }
    )
    ui.windowTitle = ui:newTextLabel(
        {
            position = {0, 135};
            text = "Settings Menu";
        }
    )
end

function settings:update(delta)
    local s = self.parent
    local ui = s.UIComponent

    --UI Offsetting & canvas enabling
    s.transformComponent.x = 600 + MenuUIOffset
    ui.enabled = s.open
    --Transparency animation
    if s.open then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end

    if not s.open then return end
end

return settings