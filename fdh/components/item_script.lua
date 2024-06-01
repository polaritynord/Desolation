local itemScript = {}

function itemScript:load()
    local item = self.parent
    item.type = "ammo_light"
    --TODD variated items
    item.imageComponent = ENGINE_COMPONENTS.imageComponent.new(item, Assets.images.items.ammoLight)
    item.imageComponent.layer = 2
    item.transformComponent.scale = {x=0.35, y=0.35}
    item.transformComponent.rotation = math.uniform(0, math.pi*2)
    item:setPosition({x=100, y=120})
    
    item.distanceToPlayer = 1000
end

function itemScript:update(delta)
    if GamePaused then return end
end

return itemScript