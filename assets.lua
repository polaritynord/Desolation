local assets = {}

function assets.load()
    assets.images = {
        player = {
            body = love.graphics.newImage("assets/images/player/body.png");
            handDefault = love.graphics.newImage("assets/images/player/hand_default.png");
            handWeapon = love.graphics.newImage("assets/images/player/hand_placeholder.png");
        };
        tiles = {
            prototypeGreen = love.graphics.newImage("assets/images/texture_09.png");
        };
        ui = {
            healthBar = love.graphics.newImage("assets/images/hud/health_bar.png");
        };
        weapons = {
            pistolImg = love.graphics.newImage("assets/images/weapons/pistol.png");
            assaultrifleImg = love.graphics.newImage("assets/images/weapons/assault_rifle.png");
            shotgunImg = love.graphics.newImage("assets/images/weapons/shotgun.png");
        };
        cursors = {
            combat = love.mouse.newCursor("assets/images/cursor_combat.png", 12, 12);
        };
    }

    assets.fonts = {}

    assets.sounds = {
        ost = {
            ambience = love.audio.newSource("assets/sounds/ost/ambience1.wav", "stream");
        };
    }
end

function assets.unloadAll()
    assets = {}
end

return assets