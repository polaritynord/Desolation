local assets = {}

function assets.load()
    assets.images = {
        player = {
            body = love.graphics.newImage("images/player/body.png")
        }
    }
end

function assets.unloadAll()
    assets = {}
end

return assets