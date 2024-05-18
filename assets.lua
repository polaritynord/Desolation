local assets = {}

function assets.load()
    assets.images = {
        player = {
            body = love.graphics.newImage("fdh/assets/images/player/body.png");
            handDefault = love.graphics.newImage("fdh/assets/images/player/hand_default.png");
            handWeapon = love.graphics.newImage("fdh/assets/images/player/hand_placeholder.png");
        };
        tiles = {
            prototypeGreen = love.graphics.newImage("fdh/assets/images/texture_09.png");
        };
        ui = {
            healthBar = love.graphics.newImage("fdh/assets/images/hud/health_bar.png");
            menuBackground = love.graphics.newImage("fdh/assets/images/menu_background.png");
        };
        weapons = {
            pistolImg = love.graphics.newImage("fdh/assets/images/weapons/pistol.png");
            assaultrifleImg = love.graphics.newImage("fdh/assets/images/weapons/assault_rifle.png");
            shotgunImg = love.graphics.newImage("fdh/assets/images/weapons/shotgun.png");
        };
        cursors = {
            combat = love.mouse.newCursor("fdh/assets/images/cursor_combat.png", 12, 12);
        };
        bullet = love.graphics.newImage("fdh/assets/images/bullet.png");
        icon = love.graphics.newImage("engine/assets/icon.png");
        logo = love.graphics.newImage("fdh/assets/images/eh_logo.png");
    }

    assets.fonts = {}

    assets.sounds = {
        ost = {
            ambience = love.audio.newSource("fdh/assets/sounds/ost/ambience1.wav", "stream");
        };
    }
end

function assets.unloadAll()
    assets = {}
end

return assets