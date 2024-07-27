local json = require("engine.lib.json")
local moonshine = require("engine.lib.moonshine")
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
    }

    function s:addChild(obj)
        self.tree[#self.tree+1] = obj
        self[obj.name] = obj
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
    if CurrentScene ~= nil then
        CurrentScene.tree = nil
        CurrentScene = nil
    end
    CurrentScene = sceneTable
    CurrentScene:load()
end

return scene