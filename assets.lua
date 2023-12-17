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
            pistolImg = love.graphics.newImage("assets/images/hud/pistol.png");
        }
    }

    assets.fonts = {}
end

function assets.unloadAll()
    assets = {}
end

return assets