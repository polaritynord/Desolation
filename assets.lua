local assets = {
    images = {};
    sounds = {};
    fonts = {};
    defaultImages = {};
    defaultSounds = {};
    mapImages = {};
    mapSounds = {};
}

function assets:unloadSceneAssets()
    --remove images
    for k, v in pairs(assets.images) do
        assets.images[k]:release()
        assets.images[k] = nil
    end
    assets.images = {}
    --remove sounds
    for k, v in pairs(assets.sounds) do
        assets.sounds[k]:stop()
        assets.sounds[k]:release()
        assets.sounds[k] = nil
    end
    assets.sounds = {}
end

function assets:unloadMapAssets()
    --remove images
    for k, v in pairs(assets.mapImages) do
        assets.mapImages[k]:release()
        assets.mapImages[k] = nil
    end
    assets.mapImages = {}
    --remove sounds
    for k, v in pairs(assets.mapSounds) do
        assets.mapSounds[k]:stop()
        assets.mapSounds[k]:release()
        assets.mapSounds[k] = nil
    end
    assets.mapSounds = {}
end

function assets.load()
    assets.defaultSounds.button_click = love.audio.newSource("desolation/assets/sounds/button_click.wav", "static")
    assets.defaultSounds.button_hover = love.audio.newSource("desolation/assets/sounds/button_hover.wav", "static")
    assets.defaultImages.missing_texture = love.graphics.newImage("engine/assets/missing_texture.png")
    assets.cursors = {
        default = love.mouse.getSystemCursor("arrow");
        combat = love.mouse.newCursor("desolation/assets/images/cursor_combat.png", 12, 12);
        reload = love.mouse.newCursor("desolation/assets/images/cursor_reload.png", 12, 12);
    }
    --load achievement icons
    for name, data in pairs(Achievements) do
        if name ~= "other" then
            assets.defaultImages["achievement_" .. name] = love.graphics.newImage(data.iconPath)
        end
    end
    --[[if true then return end
    assets.images = {
        player = {
            body = love.graphics.newImage("desolation/assets/images/player/body.png");
            handDefault = love.graphics.newImage("desolation/assets/images/player/hand_default.png");
            handWeapon = love.graphics.newImage("desolation/assets/images/player/hand_placeholder.png");
        };
        tiles = {
            prototype_green = love.graphics.newImage("desolation/assets/images/texture_09.png");
            prototype_black = love.graphics.newImage("desolation/assets/images/texture_08.png");
        };
        walls = {
            test_gray = love.graphics.newImage("desolation/assets/images/test_gray.png");
        };
        ui = {
            healthBar = love.graphics.newImage("desolation/assets/images/hud/health_bar.png");
            menuBackground = love.graphics.newImage("desolation/assets/images/menu_background.png");
            ammo = love.graphics.newImage("desolation/assets/images/hud/ammo.png");
            joystick = love.graphics.newImage("desolation/assets/images/joystick.png");
        };
        weapons = {
            pistolImg = love.graphics.newImage("desolation/assets/images/weapons/pistol.png");
            assaultrifleImg = love.graphics.newImage("desolation/assets/images/weapons/assault_rifle.png");
            shotgunImg = love.graphics.newImage("desolation/assets/images/weapons/shotgun.png");
        };
        cursors = {
            combat = love.mouse.newCursor("desolation/assets/images/cursor_combat.png", 12, 12);
        };
        items = {
            ammo_light = love.graphics.newImage("desolation/assets/images/item_ammo_light.png");
            medkit = love.graphics.newImage("desolation/assets/images/item_medkit.png");
            battery = love.graphics.newImage("desolation/assets/images/item_battery.png");
        };
        bullet = love.graphics.newImage("desolation/assets/images/bullet.png");
        icon = love.graphics.newImage("engine/assets/icon.png");
        iconTransparent = love.graphics.newImage("engine/assets/icon_transparent.png");
        logo = love.graphics.newImage("desolation/assets/images/eh_logo.png");
        missingTexture = love.graphics.newImage("engine/assets/missing_texture.png")
    }

    assets.fonts = {}

    assets.sounds = {
        ost = {
            ambience = love.audio.newSource("desolation/assets/sounds/ost/ambience1.wav", "stream");
            intro = love.audio.newSource("desolation/assets/sounds/ost/intro.wav", "stream");
        };

        sfx = {
            buttonClick = love.audio.newSource("desolation/assets/sounds/button_click.wav", "static");
            buttonHover = love.audio.newSource("desolation/assets/sounds/button_hover.wav", "static");
        };
    }
    ]]--
end

return assets