local chapterTitle = ENGINE_COMPONENTS.scriptComponent.new()

function chapterTitle:load()
    local ui = self.parent.UIComponent
    ui.text = ui:newTextLabel(
        {
            text = "CHAPTER 1\nDORMITORIES";
            begin = "center";
            size = 30;
            position= {-25, 300};
        }
    )
end

function chapterTitle:update(delta)
    
end

return chapterTitle