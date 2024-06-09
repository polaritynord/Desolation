local assets = {}

function assets.load()
    assets.images = {
        player = {
            body = love.graphics.newImage("desolation/assets/images/player/body.png");
            handDefault = love.graphics.newImage("desolation/assets/images/player/hand_default.png");
            handWeapon = love.graphics.newImage("desolation/assets/images/player/hand_placeholder.png");
        };
        tiles = {
            prototype_green = love.graphics.newImage("desolation/assets/images/texture_09.png");
        };
        walls = {
            test_gray = love.graphics.newImage("desolation/assets/images/test_gray.png");
        };
        ui = {
            healthBar = love.graphics.newImage("desolation/assets/images/hud/health_bar.png");
            menuBackground = love.graphics.newImage("desolation/assets/images/menu_background.png");
            ammo = love.graphics.newImage("desolation/assets/images/hud/ammo.png");
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
end

function assets.unloadAll()
    assets = {}
end

return assets