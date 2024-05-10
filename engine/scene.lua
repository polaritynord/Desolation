local json = require "scripts.lib.json"
local object = require "scripts.engine.object"
local components = {
    imageComponent = require "scripts.engine.components.imageComponent";
    particleComponent = require "scripts.engine.components.particleComponent";
}

local scene = {}

function scene.new()
    local s = {
        tree = {}
    }

    function s:load()
        for _, v in ipairs(self.tree) do
            v:load()
        end
    end

    function s:update(delta)
        for _, v in ipairs(self.tree) do
            v:update(delta)
        end
    end

    function s:draw()
        local camTransform = self.camera.transformComponent
        love.graphics.setBackgroundColor(ConvertColor(self.backgroundColor))
        love.graphics.push()
            love.graphics.scale(camTransform.scale.x, camTransform.scale.y)
            love.graphics.translate(-camTransform.x+240/camTransform.scale.x, -camTransform.y+135/camTransform.scale.y)
            for _, v in ipairs(self.tree) do
                v:draw()
            end
        love.graphics.pop()
    end

    return s
end

local function addObjectToScene(instance, v, isScene)
    --Create new object instance
    local newObj = object.new(instance)
    newObj.name = v[1]
    --Add components
    local compList = v[2]
    for _, compName in ipairs(compList) do
        local newComp = nil
        --Check if component is an engine comp.
        if table.contains(ENGINE_COMPONENTS, compName) then
            newComp = components[compName].new(newObj)
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
    --Setup camera if the scene doesn't have one yet
    if not instance.camera and isScene then
        instance.camera = object.new(instance)
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