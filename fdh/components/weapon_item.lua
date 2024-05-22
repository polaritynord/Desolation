local weaponItem = {}

function weaponItem:load()
    local item = self.parent
    self.parent.imageComponent = ENGINE_COMPONENTS.imageComponent.new(item)
end

function weaponItem:update(delta)
    
end

return weaponItem