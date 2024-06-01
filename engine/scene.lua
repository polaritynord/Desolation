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
    }

    function s:addChild(obj)
        self.tree[#self.tree+1] = obj
        self[obj.name] = obj
    end

    function s:load()
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
    end

    function s:draw()
        local camTransform = self.camera.transformComponent
        self.drawLayers = {{}, {}, {}}
        self.uiLayer = {}
        self.particleLayer = {}
        self.particleCount = 0
        love.graphics.setBackgroundColor(self.backgroundColor)
        love.graphics.push()
            love.graphics.scale(camTransform.scale.x, camTransform.scale.y)
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
            --Draw UI
            love.graphics.push()
                love.graphics.scale(ScreenWidth/960, ScreenHeight/540)
                for _, v in ipairs(self.uiLayer) do
                    v:draw()
                end
            love.graphics.pop()
        love.graphics.pop()
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
            newComp.parent = newObj
            newObj[compName] = newComp
        else
            --Import script component
            newComp = dofile(compName .. ".lua")
            newComp.parent = newObj
            newObj.script = newComp
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
    --Load assets from asset file
    if sceneData.assetFile then
        Assets:loadAssetsFromFile(sceneData.assetFile)
    end
    --Create new scene instance
    local instance = scene.new()
    instance.name = sceneData.name
    --Set background color
    if sceneData.backgroundColor then
        instance.backgroundColor = sceneData.backgroundColor
    else instance.backgroundColor = {1, 1, 1} end
    --Load objects to tree
    for _, v in ipairs(sceneData.tree) do
        addObjectToScene(instance, v, true)
    end
    return instance
end

function SetScene(sceneTable)
    CurrentScene = sceneTable
    CurrentScene:load()
end

return scene