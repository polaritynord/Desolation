local coreFuncs = require "coreFuncs"
local moonshine = require("engine.lib.moonshine")

local hud = ENGINE_COMPONENTS.scriptComponent.new()

function hud.customDraw(component)
    if not component.enabled then return end
    if Settings.curved_hud then
        component.parent.crtShader.draw(
            function ()
                love.graphics.scale(960/ScreenWidth, 540/ScreenHeight)
                --Draw elements
                for _, v in ipairs(component.elements) do
                    if v.enabled then v:draw() end
                end
            end
        )
    else
        --Draw elements
        for _, v in ipairs(component.elements) do
            if v.enabled then v:draw() end
        end
    end
end

function hud:load()
    local ui = self.parent.UIComponent
    self.parent.crtShader = moonshine.chain(960, 540, moonshine.effects.crt)
    ui.draw = self.customDraw
    --Left side (health etc.)
    ui.healthBar = ui:newImage(
        {
            source = Assets.images.hud_healthbar;
            position = {97, 465};
            scale = {2.35, 2.35};
        }
    )
    ui.healthMonitor = ui:newTextLabel(
        {
            text = "100";
            position = {55, 490};
            size = 48;
        }
    )
    ui.armorMonitor = ui:newTextLabel(
        {
            text = "100";
            position = {44, 448};
            size = 32;
        }
    )
    --Right side (inventory stuff)
    ui.weaponImg = ui:newImage(
        {
            source = "none";
            position = {880, 420};
            scale = {-3.4, 3.4};
        }
    )
    ui.weaponName = ui:newTextLabel(
        {
            text = "Pistol";
            begin = "center";
            position = {380, 450};
            size = 30;
        }
    )
    ui.weaponAmmoText = ui:newTextLabel(
        {
            text = 18;
            begin = "right";
            position = {-138, 495};
            size = 28;
            font = "disposable-droid-bold";
        }
    )
    ui.weaponAmmoText.oldNum = 0
    ui.weaponAmmoText.scaleNumber = 2.35
    ui.weaponAmmoImg = ui:newImage(
        {
            source = Assets.images.hud_ammo;
            position = {875, 500};
            scale = {0.8, 0.8};
        }
    )
    ui.ammunitionText = ui:newTextLabel(
        {
            text = 150;
            position = {890, 485};
            font = "disposable-droid-bold";
            size = 28;
        }
    )
    --Bottom (weapon slots)
    ui.slot1Base = ui:newRectangle(
        {
            position = {220, 510};
            size = {165, 75};
            color = {0.7, 0.7, 0.7, 0};
        }
    )
    ui.slot2Base = ui:newRectangle(
        {
            position = {395, 510};
            size = {165, 75};
            color = {0.7, 0.7, 0.7, 0};
        }
    )
    ui.slot3Base = ui:newRectangle(
        {
            position = {570, 510};
            size = {165, 75};
            color = {0.7, 0.7, 0.7, 0};
        }
    )
    ui.slot1Img = ui:newImage(
        {
            position = {300, 540};
            source = "none";
            scale = {3, 3};
            color = {1,1,1,0};
        }
    )
    ui.slot2Img = ui:newImage(
        {
            position = {475, 540};
            source = "none";
            scale = {3, 3};
            color = {1,1,1,0};
        }
    )
    ui.slot3Img = ui:newImage(
        {
            position = {650, 540};
            source = "none";
            scale = {3, 3};
            color = {1,1,1,0};
        }
    )
    ui.joystickImg = ui:newImage(
        {
            position = {480, 450};
            source = "none";
            scale = {2, 2};
        }
    )
    --ui.acquireNotif = ui:newTextLabel(
    --    {
    --        text = "Pistol Acquired";
    --        position = {-100, 50};
    --        begin = "right";
    --    }
    --)
    ui.slotSwitchTimer = 0
    ui.oldSlot = 1
end

function hud:update(delta)
    if GamePaused then return end
    local ui = self.parent.UIComponent
    --Update monitors
    local player = CurrentScene.player
    ui.healthMonitor.text = player.health
    ui.armorMonitor.text = player.armor
    --update health monitor color
    local temp = coreFuncs.boolToNum(player.health > 30)
    ui.healthMonitor.color = {1, temp, temp, 1}
    --update armor monitor color
    temp = coreFuncs.boolToNum(player.armor > 30)
    ui.armorMonitor.color = {1, temp, temp, 1}
    --Current weapon
    local weapon = player.inventory.weapons[player.inventory.slot]
    if weapon then
        ui.weaponAmmoImg.source = Assets.images.hud_ammo
        ui.weaponImg.source = Assets.images["weapon_" .. string.lower(weapon.name)]
        ui.weaponName.text = weapon.name
        ui.weaponAmmoText.text = weapon.magAmmo
        ui.ammunitionText.text = player.inventory.ammunition[weapon.ammoType]
        --TODO Add scaling fix for weaponImg
    else
        ui.weaponAmmoImg.source = nil
        ui.weaponImg.source = nil
        ui.weaponAmmoText.text = ""
        ui.ammunitionText.text = ""
        ui.weaponName.text = ""
    end
    --Check for recent slot switch
    ui.slotSwitchTimer = ui.slotSwitchTimer - delta
    if ui.oldSlot ~= player.inventory.slot then
        ui.slotSwitchTimer = 4
    end
    ui.oldSlot = player.inventory.slot

    if ui.slotSwitchTimer > 0 then
        for i = 1, 3 do
            --update base alpha
            ui["slot" .. i .. "Base"].color[4] = ui["slot" .. i .. "Base"].color[4] + (0.75-ui["slot" .. i .. "Base"].color[4])*16*delta
            ui["slot" .. i .. "Img"].color[4] = ui["slot" .. i .. "Img"].color[4] + (1-ui["slot" .. i .. "Img"].color[4])*16*delta
            --update base position
            local isSlot = coreFuncs.boolToNum(i == player.inventory.slot)
            ui["slot" .. i .. "Base"].position[2] = ui["slot" .. i .. "Base"].position[2] +
                (510-(isSlot*30)-ui["slot" .. i .. "Base"].position[2])*10*delta
            --update image position
            ui["slot" .. i .. "Img"].position[2] = ui["slot" .. i .. "Img"].position[2] +
                (540-(isSlot*30)-ui["slot" .. i .. "Img"].position[2])*10*delta
            if player.inventory.weapons[i] then
                local name = player.inventory.weapons[i].name
                ui["slot" .. i .. "Img"].source = Assets.images["weapon_" .. string.lower(name)]
            else
                ui["slot" .. i .. "Img"].source = nil
            end
        end
    else
        for i = 1, 3 do
            ui["slot" .. i .. "Base"].color[4] = ui["slot" .. i .. "Base"].color[4] + (-ui["slot" .. i .. "Base"].color[4])*16*delta
            ui["slot" .. i .. "Img"].color[4] = ui["slot" .. i .. "Img"].color[4] + (-ui["slot" .. i .. "Img"].color[4])*16*delta
        end
    end
    --Joystick indicator
    ui.joystickImg.source = nil
    if InputManager.inputType == "joystick" then
        ui.joystickImg.source = Assets.images.hud_joystick
    end
end

return hud