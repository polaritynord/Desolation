local intro = {}

function intro:load()
    local ui = self.parent.UIComponent
    ui.alpha = 0
    ui.polarity = ui:newImage(
        {
            position = {350, 270};
            scale = {0.3, 0.3};
        }
    )
    ui.title = ui:newTextLabel(
        {
            text = "Made by \nPolarity";
            position = {415, 220};
            size = 54;
        }
    )
    ui.titleNord = ui:newTextLabel(
        {
            text = "nord";
            position = {595, 270};
            size = 36;
        }
    )
end

function intro:update(delta)
    
end

return intro