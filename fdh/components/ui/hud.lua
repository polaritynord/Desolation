local hud = {}

function hud:load()
    local ui = self.parent.UIComponent
    --Left side (health etc.)
    ui.healthBar = ui:newImage(
        {
            source = Assets.images.ui.healthBar;
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
            source = Assets.images.weapons.pistolImg;
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
            source = Assets.images.ui.ammo;
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
end

function hud:update(delta)
    local ui = self.parent.UIComponent
    --Update monitors
    local player = CurrentScene.player
    ui.healthMonitor.text = player.health
    ui.armorMonitor.text = player.armor
    --Current weapon
    local weapon = player.inventory.weapons[player.inventory.slot]
    if weapon then
        ui.weaponAmmoImg.source = Assets.images.ui.ammo
        ui.weaponImg.source = Assets.images.weapons[string.lower(weapon.name) .. "Img"]
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
end

return hud