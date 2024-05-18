local clickEvents = {}

function clickEvents.quitButtonClick(element)
    if element.buttonText == "Quit" then
        element.buttonText = "Are You Sure?"
        element.textFont = "disposable-droid-italic"
    else
        love.event.quit()
    end
end

return clickEvents