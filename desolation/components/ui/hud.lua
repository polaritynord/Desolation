local coreFuncs = require "coreFuncs"
local moonshine = require("engine.lib.moonshine")

local hud = ENGINE_COMPONENTS.scriptComponent.new()

local whiteShader = love.graphics.newShader[[
extern float WhiteFactor;

vec4 effect(vec4 vcolor, Image tex, vec2 texcoord, vec2 pixcoord)
{
    vec4 outputcolor = Texel(tex, texcoord) * vcolor;
    outputcolor.rgb += vec3(WhiteFactor);
    return outputcolor;
}
]]

local function whiteIconDraw(element)
    local src = element.source
    if src == nil then return end
    local width = src:getWidth() ;  local height = src:getHeight()
    local pos = coreFuncs.getRelativeElementPosition(element.position, element.parentComp)

    love.graphics.setShader(whiteShader)
    love.graphics.setColor(element.color[1], element.color[2], element.color[3], element.color[4]*element.parentComp.alpha)
    whiteShader:send("WhiteFactor", 1)
    love.graphics.draw(
        src, pos[1], pos[2], element.rotation,
        element.scale[1], element.scale[2], width/2, height/2
    )
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setShader(nil)
end

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
    self.parent.crtShader.crt.feather = 0
    ui.draw = self.customDraw
    --Left side (health etc.)
    ui.healthBar = ui:newImage(
        {
            source = Assets.images.hud_healthbar;
            position = {140, 487};
            scale = {2.35, 2.35};
        }
    )
    ui.healthMonitor = ui:newTextLabel(
        {
            text = "100";
            position = {55, 487};
            size = 48;
        }
    )
    ui.armorMonitor = ui:newTextLabel(
        {
            text = "100";
            position = {190, 487};
            size = 48;
        }
    )
    ui.staminaMonitor = ui:newTextLabel(
        {
            text = "100";
            size = 32;
            position = {44, 444};
        }
    )
    --Right side (inventory stuff)
    ui.weaponImg = ui:newImage(
        {
            source = "none";
            position = {880, 430};
            scale = {-3.4, 3.4};
        }
    )
    ui.weaponImg.draw = whiteIconDraw
    ui.weaponName = ui:newTextLabel(
        {
            text = "Pistol";
            begin = "center";
            position = {380, 460};
            size = 30;
        }
    )
    ui.weaponAmmoText = ui:newTextLabel(
        {
            text = 18;
            begin = "right";
            position = {-138, 505};
            size = 28;
            font = "disposable-droid-bold";
        }
    )
    ui.weaponAmmoText.oldNum = 0
    ui.weaponAmmoText.scaleNumber = 2.35
    ui.weaponAmmoImg = ui:newImage(
        {
            source = Assets.images.hud_ammo;
            position = {875, 510};
            scale = {0.8, 0.8};
        }
    )
    ui.ammunitionText = ui:newTextLabel(
        {
            text = 150;
            position = {890, 495};
            font = "disposable-droid-bold";
            size = 28;
        }
    )
    --Right side weapon slots
    ui.slot1Base = ui:newRectangle(
        {
            position = {220, -60};
            size = {165, 75};
            color = {0.7, 0.7, 0.7, 0};
        }
    )
    ui.slot2Base = ui:newRectangle(
        {
            position = {395, -60};
            size = {165, 75};
            color = {0.7, 0.7, 0.7, 0};
        }
    )
    ui.slot3Base = ui:newRectangle(
        {
            position = {570, -60};
            size = {165, 75};
            color = {0.7, 0.7, 0.7, 0};
        }
    )
    ui.slot1Ammo = ui:newTextLabel(
        {
            position = {-190, 20};
            begin = "center";
            text = "";
        }
    )
    ui.slot2Ammo = ui:newTextLabel(
        {
            position = {-15, 20};
            begin = "center";
            text = "";
        }
    )
    ui.slot3Ammo = ui:newTextLabel(
        {
            position = {160, 20};
            begin = "center";
            text = "";
        }
    )
    ui.slot1Img = ui:newImage(
        {
            position = {300, -10};
            source = "none";
            scale = {3, 3};
            color = {1,1,1,0};
        }
    )
    ui.slot2Img = ui:newImage(
        {
            position = {475, -10};
            source = "none";
            scale = {3, 3};
            color = {1,1,1,0};
        }
    )
    ui.slot3Img = ui:newImage(
        {
            position = {650, -10};
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
    ui.itemPickupImg = ui:newImage(
        {
            source = "none";
            scale = {2, 2};
        }
    )
    ui.itemPickupKey = ui:newTextLabel(
        {
            text = string.upper(InputManager:getKeys("interact")[1]);
            color = {0, 0, 0, 1};
            size = 36;
        }
    )
    --Grenade slot images
    for i = 1, 3 do
        ui["grenadeSlot" .. i] = ui:newImage(
            {
                source = Assets.images["weapon_grenade"];
                position = {790-(i-1)*30, 510};
                scale = {1, 1};
            }
        )
    end
    --Other variables
    ui.acquireNotifs = {}
    ui.hitmarkers = {}
    ui.followingImgs = {}
    ui.slotSwitchTimer = 0
    ui.oldSlot = 1
end

function hud:update(delta)
    if GamePaused then return end
    local ui = self.parent.UIComponent
    local player = CurrentScene.player
    if not player.armorAcquired then
        ui.enabled = false
        return
    end
    --Update monitors
    ui.healthMonitor.text = math.ceil(player.health)
    ui.armorMonitor.text = math.ceil(player.armor)
    ui.staminaMonitor.text = math.ceil(player.stamina)
    --update health monitor color
    local temp = coreFuncs.boolToNum(player.health > 30)
    ui.healthMonitor.color = {1, temp, temp, 1}
    --update armor monitor color
    temp = coreFuncs.boolToNum(player.armor > 30)
    ui.armorMonitor.color = {1, temp, temp, 1}
    --update stamina monitor color
    temp = coreFuncs.boolToNum(player.stamina > 30)
    ui.staminaMonitor.color = {1, temp, temp, 1}
    --Current weapon
    local weapon = player.inventory.weapons[player.inventory.slot]
    if weapon then
        ui.weaponAmmoImg.source = Assets.images.hud_ammo
        ui.weaponImg.source = Assets.images["weapon_" .. string.lower(weapon.name)]
        ui.weaponName.text = Loca.weapons[string.lower(weapon.name)]
        ui.weaponAmmoText.text = weapon.magAmmo
        ui.ammunitionText.text = player.inventory.ammunition[weapon.ammoType]
        --TODO Add scaling fix for weaponImg
        --weaponImg shooting effects
        ui.weaponImg.rotation = ui.weaponImg.rotation + (-ui.weaponImg.rotation)*8*delta
        ui.weaponImg.scale[1] = ui.weaponImg.scale[1] + (-3.4-ui.weaponImg.scale[1])*8*delta
        ui.weaponImg.scale[2] = ui.weaponImg.scale[2] + (3.4-ui.weaponImg.scale[2])*8*delta
        --color (depleted ammo)
        if weapon.magAmmo < 1 and player.inventory.ammunition[weapon.ammoType] < 1 then
            ui.weaponImg.color = {1, 0, 0, 1}
        else
            ui.weaponImg.color = {1, 1, 1, 1}
        end
        --alpha
        if player.reloading then
            ui.weaponImg.color[4] = player.reloadTimer/weapon.reloadTime
        else
            ui.weaponImg.color[4] = 1
        end
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
        SoundManager:restartSound(Assets.sounds["slot_switch"], Settings.vol_world)
        ui.slotSwitchTimer = 4
        ui.weaponImg.scale = {-4.5, 4.5}
    end
    ui.oldSlot = player.inventory.slot

    if ui.slotSwitchTimer > 0 then
        for i = 1, 3 do
            --update base alpha
            ui["slot" .. i .. "Base"].color[4] = ui["slot" .. i .. "Base"].color[4] + (0.75-ui["slot" .. i .. "Base"].color[4])*16*delta
            ui["slot" .. i .. "Img"].color[4] = ui["slot" .. i .. "Img"].color[4] + (1-ui["slot" .. i .. "Img"].color[4])*16*delta
            ui["slot" .. i .. "Ammo"].color[4] = ui["slot" .. i .. "Ammo"].color[4] + (1-ui["slot" .. i .. "Ammo"].color[4])*16*delta
            --update base position
            local isSlot = coreFuncs.boolToNum(i == player.inventory.slot)
            ui["slot" .. i .. "Base"].position[2] = ui["slot" .. i .. "Base"].position[2] +
                (-60+(isSlot*30)-ui["slot" .. i .. "Base"].position[2])*10*delta
            --update image position
            ui["slot" .. i .. "Img"].position[2] = ui["slot" .. i .. "Img"].position[2] +
                (-10+(isSlot*30)-ui["slot" .. i .. "Img"].position[2])*10*delta
            --update ammo position
            ui["slot" .. i .. "Ammo"].position[2] = ui["slot" .. i .. "Ammo"].position[2] +
                (20+(isSlot*30)-ui["slot" .. i .. "Ammo"].position[2])*10*delta
            --if slot has a weapon
            local w = player.inventory.weapons[i]
            if w ~= nil then
                local name = w.name
                ui["slot" .. i .. "Img"].source = Assets.images["weapon_" .. string.lower(name)]
                ui["slot" .. i .. "Ammo"].text = player.inventory.ammunition[w.ammoType] + w.magAmmo
            else
                ui["slot" .. i .. "Img"].source = nil
                ui["slot" .. i .. "Ammo"].text = ""
            end
        end
    else
        for i = 1, 3 do
            ui["slot" .. i .. "Base"].color[4] = ui["slot" .. i .. "Base"].color[4] + (-ui["slot" .. i .. "Base"].color[4])*16*delta
            ui["slot" .. i .. "Img"].color[4] = ui["slot" .. i .. "Img"].color[4] + (-ui["slot" .. i .. "Img"].color[4])*16*delta
            ui["slot" .. i .. "Ammo"].color[4] = ui["slot" .. i .. "Ammo"].color[4] + (-ui["slot" .. i .. "Ammo"].color[4])*16*delta
        end
    end
    --Joystick indicator
    ui.joystickImg.source = nil
    if InputManager.inputType == "joystick" and Settings.show_controller_icon then
        ui.joystickImg.source = Assets.images.hud_joystick
    end
    --Notifications
    for i, notif in ipairs(ui.acquireNotifs) do
        --Move notification smoothly
        notif.realY = 460 - (notif.index*40)
        notif.position[2] = notif.position[2] + (notif.realY-notif.position[2])*16*delta
        notif.scale[1] = notif.scale[1] + (1-notif.scale[1])*10*delta
        notif.scale[2] = notif.scale[2] + (1-notif.scale[2])*10*delta
        notif.timer = notif.timer + delta
        --start decay
        if notif.timer > 2.5 then
            notif.color[4] = notif.color[4] - 4*delta
            if notif.color[4] < 0 then
                --remove self
                table.remove(ui.acquireNotifs, i)
                table.removeValue(ui.elements, notif)
                --change index of upper(newer) notifs
                for k = i, #ui.acquireNotifs do
                    ui.acquireNotifs[k].index = ui.acquireNotifs[k].index - 1
                end
            end
        end
    end
    --Item pickup hint
    if CurrentScene.player.nearItem == nil then
        ui.itemPickupImg.source = nil
        ui.itemPickupImg.color[4] = 0
        ui.itemPickupKey.text = ""
    else
        local item = CurrentScene.player.nearItem
        ui.itemPickupImg.source = Assets.images["hud_item_pickup"]
        ui.itemPickupImg.position = {
            (item.position[1]-CurrentScene.camera.position[1])*CurrentScene.camera.zoom+480,
            (item.position[2]-CurrentScene.camera.position[2]-50)*CurrentScene.camera.zoom+270
        }
        --There is no controller binding customization rn so I simply made it
        --show "A". might change later idk.
        ui.itemPickupKey.text = string.upper(InputManager:getKeys("interact")[1])
        if InputManager.inputType == "joystick" then
            ui.itemPickupKey.text = "A"
        end
        ui.itemPickupKey.position = {
            (item.position[1]-CurrentScene.camera.position[1])*CurrentScene.camera.zoom+470,
            (item.position[2]-CurrentScene.camera.position[2]-50)*CurrentScene.camera.zoom+252
        }
        ui.itemPickupImg.color[4] = ui.itemPickupImg.color[4] + (1-ui.itemPickupImg.color[4])*20*delta
    end
    --Grenade slots
    for i = 1, 3 do
        local element = ui["grenadeSlot" .. i]
        element.enabled = player.inventory.grenades >= i
    end
    --Hitmarkers update
    for i, v in ipairs(ui.hitmarkers) do
        -- Change scale
        v.scale[1] = v.scale[1] - 8 * delta
        v.scale[2] = v.scale[2] - 8 * delta
        -- Despawn
        if v.scale[1] < 0.2 then
            table.remove(ui.hitmarkers, i)
            table.removeValue(ui.elements, v)
        end
    end
    --Follow markers update
    for i, v in ipairs(ui.followingImgs) do
        local npc = CurrentScene.npcs.tree[v.parentIndex]
        --remove if NPC is gone
        if npc ~= v.parentHumanoid then
            table.removeValue(ui.elements, v)
            table.remove(ui.followingImgs, i)
            return
        end
        --remove if NPC is not in follow state anymore
        if npc.state == "follow" then
            --Update position
            v.position = {
                (npc.position[1]-CurrentScene.camera.position[1])*CurrentScene.camera.zoom+480,
                (npc.position[2]-CurrentScene.camera.position[2]-50)*CurrentScene.camera.zoom+270
            }
        else
            table.removeValue(ui.elements, v)
            table.remove(ui.followingImgs, i)
        end
    end
end

return hud