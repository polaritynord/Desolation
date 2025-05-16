local buttonEvents = require "desolation.button_clickevents"
local json = require("engine.lib.json")
local keysMenu = ENGINE_COMPONENTS.scriptComponent.new()

function keysMenu:load()
    local keys = self.parent
    local settings = keys.parent
    local ui = keys.UIComponent
    ui.enabled = false
    keys.realY = keys.position[2]
    keys.length = 380 + #InputManager.bindings.keyboard*40

    --[[scrollbar element
    ui.scrollbar = ui:newScrollbar(
        {
            position = {480, 250};
            maxValue = 0.7; --Done by hand for now, figure out a better way later
            baseColor = {0.5, 0.5, 0.5, 0.6};
            barColor = {0.85, 0.85, 0.85, 1};
        }
    )
    ui.scrollbar.realY = ui.scrollbar.position[2]
    ]]--
    --key binding main title or some shi
    ui:newTextLabel(
        {
            position = {0, 200};
            size = 30;
            font = "disposable-droid-bold";
            text = Loca.keysMenu.name;
            color = {1, 1, 1, 0.2};
        }
    )
    ui:newTextLabel(
        {
            position = {375, 200};
            size = 30;
            font = "disposable-droid-bold";
            text = Loca.keysMenu.key;
            color = {1, 1, 1, 0.2};
        }
    )
    --key binding titles
    for i = 1, #InputManager.bindings.keyboard do
        local binding = InputManager.bindings.keyboard[i]
        local bindingTitle
        if Loca.settings.bindingNames[binding[1]] ~= nil then
            bindingTitle = Loca.settings.bindingNames[binding[1]]
        else
            bindingTitle = string.upper(binding[1])
        end
        ui[binding[1]] = ui:newTextButton(
            {
                buttonTextSize = 30;
                buttonText = bindingTitle;
                position = {0, 200+i*40};
                clickEvent = function (element)
                    if element.selected then
                        element.selected = false
                        return
                    end
                    element.selected = true
                    keys.selectedBinding = binding
                end
            }
        )
        ui["key_" .. binding[1]] = ui:newTextLabel(
            {
                size = 30;
                font = "disposable-droid-bold";
                text = string.upper(binding[2]);
                position = {370, 200+i*40};
            }
        )
    end

    ui.resetKeys = ui:newTextButton(
        {
            buttonText = Loca.keysMenu.resetToDefault;
            position = {0, 240+#InputManager.bindings.keyboard*40};
            hoverEvent = buttonEvents.redHover;
            unhoverEvent = buttonEvents.redUnhover;
            clickEvent = function()
                --Write new binding file
                local defaultBindingsFile = love.filesystem.read("desolation/assets/default_bindings.json")
                love.filesystem.write("bindings.json", defaultBindingsFile)
                InputManager.bindings = json.decode(defaultBindingsFile)
            end
        }
    )
    ui.showControllerIconText = ui:newTextLabel(
        {
            size = 30;
            font = "disposable-droid-bold";
            text = Loca.keysMenu.showControllerIcon;
            position = {0, 275+#InputManager.bindings.keyboard*40}
        }
    )
    ui.showControllerIconBox = ui:newCheckbox(
        {
            position = {400, 290+#InputManager.bindings.keyboard*40};
            toggled = Settings.show_controller_icon;
        }
    )
end

function keysMenu:update(delta)
    local keys = self.parent
    local settings = keys.parent
    local ui = keys.UIComponent

    --UI Offsetting & canvas enabling
    keys.position[1] = 950 + MenuUIOffset
    keys.position[2] = keys.position[2] + (keys.realY-keys.position[2])*8*delta
    ui.enabled = settings.menu == "keys"
    --Transparency animation
    if ui.enabled then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end
    if not ui.enabled then
        if keys.selectedBinding ~= nil then
            ui[keys.selectedBinding[1]].selected = false
            keys.selectedBinding = nil
        end
        return
    end
    --Controller settings here
    settings.preview.show_controller_icon = ui.showControllerIconBox.toggled
    --Update binding name and titles
    for i = 1, #InputManager.bindings.keyboard do
        local binding = InputManager.bindings.keyboard[i]
        local nameElement = ui[binding[1]]
        local keyElement = ui["key_" .. binding[1]]
        if nameElement.selected then
            nameElement.textFont = "disposable-droid-italic"
            keyElement.text = ""
            nameElement.buttonText = Loca.keysMenu.pressAKey
        else
            keyElement.text = string.upper(binding[2])
            local bindingTitle = string.upper(binding[1])
            if Loca.settings.bindingNames[binding[1]] ~= nil then
                bindingTitle = Loca.settings.bindingNames[binding[1]]
            end
            nameElement.buttonText = bindingTitle
            nameElement.textFont = "disposable-droid"
            --key element yellow color if the key is already taken by something else
            local excluded = table.new(InputManager.keysList)
            table.remove(excluded, i)
            keyElement.color = {1, 1, 1, 1}
            if table.contains(excluded, binding[2]) then
                keyElement.color = {1, 1, 0, 1}
            end
        end
    end
end

return keysMenu