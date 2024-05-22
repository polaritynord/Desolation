local weaponItem = {}

function weaponItem:movement(delta, item)
    local itemPos = item:getPosition()
    local playerPos = CurrentScene.player:getPosition()
    if self.gettingPickedUp then
        itemPos.x = itemPos.x + (playerPos.x-itemPos.x)*10*delta
        itemPos.y = itemPos.y + (playerPos.y-itemPos.y)*10*delta
        --Set alpha
        item.imageComponent.color[4] = self.distanceToPlayer/100
    else
        --Move
        itemPos.x = itemPos.x + self.velocity*math.cos(self.realRot)*delta
        itemPos.y = itemPos.y + self.velocity*math.sin(self.realRot)*delta
        --Slow down
        self.velocity = self.velocity - 2000*delta
        if self.velocity < 0 then self.velocity = 0 end
        --Turn & velocity decrease
        item.transformComponent.rotation = item.transformComponent.rotation - self.rotVelocity*delta
        self.rotVelocity = self.rotVelocity + (-self.rotVelocity)*math.pi*2*delta
    end
    --Set new position
    item.transformComponent.x = itemPos.x
    item.transformComponent.y = itemPos.y
end

function weaponItem:load()
    local item = self.parent
    self.parent.imageComponent = ENGINE_COMPONENTS.imageComponent.new(
        item,
        Assets.images.weapons[string.lower(item.weaponData.name) .. "Img"]
    )
    self.parent.imageComponent.layer = 2
    self.parent.transformComponent.scale = {x=2, y=2}
    --Some vars
    self.gettingPickedUp = false
end

function weaponItem:update(delta)
    local item = self.parent
    self:movement(delta, item)
end

return weaponItem