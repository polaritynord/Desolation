local json = require("engine.lib.json")
local urfs = require("engine.lib.urfs")

local function cameraControls(delta)
    --Mouse controls
    local mx, my = love.mouse.getPosition()
    if love.mouse.isDown(3) then
        Camera.position[1] = Camera.position[1] + (Camera.oldMouseX-mx)*Camera.zoom
        Camera.position[2] = Camera.position[2] + (Camera.oldMouseY-my)*Camera.zoom
    end
    Camera.oldMouseX = mx
    Camera.oldMouseY = my
    --WASD and arrow keys controls
    local speed = 345
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        Camera.position[1] = Camera.position[1] + speed*delta
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        Camera.position[1] = Camera.position[1] - speed*delta
    end
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        Camera.position[2] = Camera.position[2] - speed*delta
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        Camera.position[2] = Camera.position[2] + speed*delta
    end
end

local function drawTiles()
    for _, tile in ipairs(CurrentMap.tiles) do
        local source = Assets.images["tile_" .. tile[1]]
        local w, h = source:getWidth(), source:getHeight()
        love.graphics.draw(
            source, tile[2]*1024, tile[3]*1024,
            0, 2, 2, w/2, h/2
        )
    end
end

local function drawProps()
    for _, prop in ipairs(CurrentMap.props) do
        --Hardcoded crate types to work properly (I need to get rid of that difference and instead add scale attributes...)
        local scale = 2.5
        local source = nil
        if prop[1] == "crate_big" or prop[1] == "crate" then
            source = Assets.images["prop_crate"]
            if prop[1] == "crate_big" then scale = 3.5 end
        else
            --All the other prop types load normally (this will cause great issues in the future)
            source = Assets.images["prop_" .. prop[1]]
        end
        if source ~= nil then
            local w, h = source:getWidth(), source:getHeight()
            love.graphics.draw(
                source, prop[2][1], prop[2][2],
                prop[3]*math.pi/180, scale, scale, w/2, h/2
            )
        elseif prop[1] == "trigger_prop" then
            love.graphics.setColor(1, 1, 0, 0.5)
            love.graphics.rectangle("fill", prop[2][1], prop[2][2], 80, 80)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

local function drawItems()
    --SCALING IS FUCKED UP ON THIS ONE
    local itemData = json.decode(love.filesystem.read("desolation/assets/items.json"))
    for _, item in ipairs(CurrentMap.items) do
        --Apparently items in DESOLATION load their own images. I'm not gonna do this here,
        --But I have to make that code more suitable for this map editor.
        local source
        if item[1] == "weapon" then
            source = Assets.images["weapon_" .. string.lower(item[4])]
            --weapon loading is a bit weird in the game. Might change the names.
        else
            source = Assets.images["item_" .. item[1]]
        end
        local w, h = source:getWidth(), source:getHeight()
        local scale = itemData[item[1]].scale
        love.graphics.draw(
            source, item[2][1], item[2][2], item[3]*math.pi/180, scale[1], scale[2], w/2, h/2
        )
    end
end

local function drawWalls()
    for i, wall in ipairs(CurrentMap.walls) do
        local source = Assets.images["wall_" .. wall[1]]
        love.graphics.draw(
            source, WallQuadData[i], wall[2][1]*64, wall[2][2]*64
        )
    end
end

local function drawPlayerSpawn()
    love.graphics.draw(
        Assets.images["player_body"], CurrentMap.playerData.position[1], CurrentMap.playerData.position[2],
        0, 4, 4, 6, 6
    )
end

local function loadMap(resetCamera)
    --maps folder
    if love.filesystem.getInfo("maps") == nil then
        print("Creating maps directory...")
        love.filesystem.createDirectory("maps")
    end
    if not MapGiven then return end
    CurrentMap = nil
    print("Map name detected. Proceeding to load or create...")
    local mapExists = love.filesystem.getInfo("maps/" .. arg[2] .. ".json")
    local mapFile = nil
    if mapExists then --Load existing map file
        print("Map found. Loading the map file...")
        mapFile = love.filesystem.read("maps/" .. arg[2] .. ".json")
    else --Create new map file
        print("Map not found. Creating new file...")
        local emptyMapFile = love.filesystem.read("empty_map.json")
        love.filesystem.write("maps/" .. arg[2] .. ".json", emptyMapFile)
        mapFile = emptyMapFile
    end
    --Convert json to table
    print("Converting map JSON to a Lua table...")
    CurrentMap = json.decode(mapFile)
    --Loading assets - images
    Assets = {
        images = {}
    }
    for i, img in ipairs(CurrentMap.assets.images) do
        Assets.images[img[1]] = love.graphics.newImage(img[2])
        print("Loading images (" .. i .. "/" .. #CurrentMap.assets.images .. ")...")
    end
    --Wall quad data and shit like that
    WallQuadData = {}
    for i, wall in ipairs(CurrentMap.walls) do
        if wall.name ~= "invisible" then
            Assets.images["wall_" .. wall[1]]:setWrap("repeat", "repeat")
            WallQuadData[#WallQuadData+1] = love.graphics.newQuad(0, 0, wall[3][1]*64, wall[3][2]*64, 64, 64)
        end
        print("Loading wall quad data (" .. i .. "/" .. #CurrentMap.walls .. ")...")
    end
    --Camera
    if not resetCamera then return end
    Camera = {
        position = table.new(CurrentMap.playerData.cameraPosition);
        zoom = 1;
        oldMouseX = 0;
        oldMouseY = 0;
    }
end

function love.wheelmoved(x, y)
    --Camera zooming
    if y > 0 then
        Camera.zoom = Camera.zoom + 0.1
        if Camera.zoom > 2.5 then Camera.zoom = 2.5 end
    elseif y < 0 then
        Camera.zoom = Camera.zoom - 0.1
        if Camera.zoom < 0.1 then Camera.zoom = 0.1 end
    end
end

function love.keypressed(key, unicode)
    --Toggling fullscreen
    if key == "f11" then
        love.window.setFullscreen(not love.window.getFullscreen(), "desktop")
        if not love.window.getFullscreen() then
            love.window.setMode(960, 540, {vsync=false, resizable=true})
        end
    end
    --Reloading map
    if key == "f5" then
        loadMap(love.keyboard.isDown("lctrl"))
        print("Successfully reloaded map.")
    end
end

function love.load()
    urfs.mount(".") --Mount the upper directory to access game assets
    love.graphics.setDefaultFilter("nearest", "nearest")
    loadMap(true)
end

function love.update(delta)
    if not MapGiven then return end
    cameraControls(delta)
end

function love.draw()
    if not MapGiven then
        --"No map given" text
        love.graphics.print("No map name is given. Write a map name after the \"love . \" to create a new map or open an existing one.")
        return
    end
    love.graphics.push()
        local w, h = love.graphics.getDimensions()
        love.graphics.translate(-Camera.position[1]+w/2, -Camera.position[2]+h/2)
        love.graphics.scale(Camera.zoom, Camera.zoom)
        drawTiles()
        drawProps()
        drawItems()
        drawWalls()
        drawPlayerSpawn()
    love.graphics.pop()
    --Draw Texts
    local mx, my = love.mouse.getPosition()
    mx = mx + Camera.position[1]
    my = my + Camera.position[2]
    love.graphics.print(
        "FPS:" .. love.timer.getFPS() .. "\nWall Coords: (" .. 
        math.floor(mx/64) .. " , " .. math.floor(my/64) .. ")"
    )
end
