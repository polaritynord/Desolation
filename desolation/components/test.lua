local test = ENGINE_COMPONENTS.scriptComponent.new()

function test:load()
end

function test:update(delta)
    print(delta)
end

return test