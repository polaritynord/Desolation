local json = require("engine.lib.json")
local object = require "engine.object"

local scene = {}

function scene.new()
    local s = {
        tree = {};
        drawLayers = {{}, {}, {}};
        uiLayer = {};
        particleLayer = {};
        particleCount = 0;
        uiShader = nil;
        gameShader = nil;
        lightCanvas = love.graphics.newCanvas();
        illumination = {0.2, 0.2, 0.2};
        lights = {};
        lightPolygons = {};
    }

    function s:addChild(obj)
        self.tree[#self.tree+1] = obj
        self[obj.name] = obj
        return obj
    end

    function s:preDrawLights()
        if GetGlobal("fullbright") > 0 then return end
        love.graphics.setCanvas({ self.lightCanvas, stencil = true})
            love.graphics.translate((-self.camera.position[1])*self.camera.zoom+480, (-self.camera.position[2])*self.camera.zoom+270)
            love.graphics.scale(self.camera.zoom, self.camera.zoom)
            love.graphics.clear(unpack(self.illumination)) -- Global illumination level
            Lighter:drawLights()
        love.graphics.setCanvas()
    end

    function s:addLight(x, y, radius, r, g, b, a)
        local light = Lighter:addLight(
            x or 0,
            y or 0,
            radius or 300,
            r or 1, g or 1, b or 1, a or 1
        )
        self.lights[#self.lights+1] = light
        return light
    end

    function s:removeLight(light)
        local index = table.contains(self.lights, light, true)
        Lighter:removeLight(light)
        table.remove(self.lights, index)
    end

    function s:removeLightPolygon(polygon)
        local index = table.contains(self.lightPolygons, polygon, true)
        Lighter:removePolygon(polygon)
        table.remove(self.lightPolygons, index)
    end

    function s:addLightPolygon(polygon)
        Lighter:addPolygon(polygon)
        self.lightPolygons[#self.lightPolygons+1] = polygon
        return polygon
    end

    function s:load()
        love.graphics.setBackgroundColor(self.backgroundColor)
        for _, v in ipairs(self.tree) do
            v:load()
            --Load child objects
            for _, child in ipairs(v.tree) do
                child:load()
            end
        end
    end

    function s:update(delta)
        for _, v in ipairs(self.tree) do
            v:update(delta)
        end
        if self.camera.script then self.camera.script:update(delta) end
        InputManager.leftMouseTimer = InputManager.leftMouseTimer + delta
        self:preDrawLights()
    end

    function s:draw()
        self.drawLayers = {}
        for i = 1, 5 do
            self.drawLayers[#self.drawLayers+1] = {}
        end
        self.uiLayer = {}
        self.particleLayer = {}
        self.particleCount = 0
        love.graphics.push()
            if self.gameShader == nil then
                love.graphics.scale(ScreenWidth/960, ScreenHeight/540)
                self:drawGame()
            else
                self.gameShader.draw(
                    function ()
                        self:drawGame()
                        if GetGlobal("fullbright") > 0 then return end
                        love.graphics.setBlendMode("multiply", "premultiplied")
                        love.graphics.draw(self.lightCanvas)
                        love.graphics.setBlendMode("alpha")
                    end
                )
            end
        love.graphics.pop()
        --Draw UI
        love.graphics.push()
            if self.uiShader == nil then
                love.graphics.scale(ScreenWidth/960, ScreenHeight/540)
                self:drawUI()
            else
                self.uiShader.draw(
                    function ()
                        self:drawUI()
                    end
                )
            end
        love.graphics.pop()
    end

    function s:drawUI()
        for _, v in ipairs(self.uiLayer) do
            v:draw()
        end
    end

    function s:drawGame()
        --love.graphics.scale(self.camera.scale[1], self.camera.scale[2])
        for _, v in ipairs(self.tree) do
            v:draw()
        end
        --Draw image layers
        for k = #self.drawLayers, 1, -1 do
            for _, v in ipairs(self.drawLayers[k]) do
                v:draw()
            end
        end
        --Draw particles
        for _, v in ipairs(self.particleLayer) do
            v:draw()
        end
    end

    return s
end

local function addObjectToScene(instance, v, _isScene)
    --Create new object instance
    local newObj = object.new(instance)
    newObj.name = v[1]
    --Add components
    local compList = v[2]
    for _, compName in ipairs(compList) do
        local newComp = nil
        --Check if component is an engine comp.
        if table.contains(ENGINE_COMPONENT_NAMES, compName) then
            newComp = ENGINE_COMPONENTS[compName].new(newObj)
            newObj:addComponent(newComp)
        else
            --Import script component
            newComp = love.filesystem.load(compName .. ".lua")
            newComp = newComp()
            newComp.name = "script"
            newObj:addComponent(newComp)
        end
    end
    --Add children objects
    if v[3] then
        for i = 1, #v[3] do
            addObjectToScene(newObj, v[3][i], false)
        end
    end
    --Add new object to tree
    instance.tree[#instance.tree+1] = newObj
    instance[newObj.name] = newObj
end

function LoadScene(file)
    --Read & decode scene file
    local sceneFile = love.filesystem.read(file)
    local sceneData = json.decode(sceneFile)
    --Create new scene instance
    local instance = scene.new()
    instance.name = sceneData.name
    --Set background color
    if sceneData.backgroundColor then
        instance.backgroundColor = sceneData.backgroundColor
    else instance.backgroundColor = {1, 1, 1} end
    --Load asset files
    Assets:unloadSceneAssets()
    if sceneData.assets ~= nil then
        --Load images
        if sceneData.assets.images ~= nil then
            for _, v in ipairs(sceneData.assets.images) do
                Assets.images[v[1]] = love.graphics.newImage(v[2])
            end
        end
        --Load sounds
        if sceneData.assets.sounds ~= nil then
            for _, v in ipairs(sceneData.assets.sounds) do
                Assets.sounds[v[1]] = love.audio.newSource(v[2], v[3])
            end
        end
    end
    --Load objects to tree
    for _, v in ipairs(sceneData.tree) do
        addObjectToScene(instance, v, true)
    end
    instance.camera.zoom = 1
    return instance
end

function SetScene(sceneTable)
    if CurrentScene ~= nil then --my poor attempts on preventing memory leak :(
        for _, light in ipairs(CurrentScene.lights) do
            Lighter:removeLight(light)
        end
        for _, polygon in ipairs(CurrentScene.lightPolygons) do
            Lighter:removePolygon(polygon)
        end
        --CurrentScene.lightCanvas:release() (crashes?!)
        CurrentScene.tree = nil
        CurrentScene = nil
    end
    CurrentScene = sceneTable
    CurrentScene:load()
end

return scene