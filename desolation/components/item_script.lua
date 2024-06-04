local itemScript = ENGINE_COMPONENTS.scriptComponent.new()

function itemScript:load()
    local item = self.parent
    item.type = "ammo_light"
    --TODD variated items
    item.imageComponent = ENGINE_COMPONENTS.imageComponent.new(item, Assets.images.items.ammoLight)
    item.imageComponent.layer = 2
    item.scale = {0.35, 0.35}
    item.rotation = math.uniform(0, math.pi*2)
    item.position = {100, 120}

    item.distanceToPlayer = 1000
end

function itemScript:update(delta)
    if GamePaused then return end
end

return itemScript