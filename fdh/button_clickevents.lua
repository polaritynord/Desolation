local clickEvents = {}

function clickEvents.quitButtonClick(element)
    if element.buttonText == "Quit" then
        if math.random() < 0.05 then
            element.textFont = "pryonkalsov"
            element.buttonText = "Obey the regime for the greater good"
        else
            element.textFont = "disposable-droid-italic"
            element.buttonText = "Are You Sure?"
        end
        element.confirmTimer = 2.4
    else
        love.event.quit()
    end
end

return clickEvents