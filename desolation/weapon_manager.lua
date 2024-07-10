local json = require("engine.lib.json")
local weapon = require("desolation.weapon")

local weaponManager = {loaded=false}

function weaponManager:load()
    if self.loaded then return end
    self.loaded = true
    --Read weapons.json
    local weaponsFile = love.filesystem.read("desolation/assets/weapons.json")
    local weaponsData = json.decode(weaponsFile)
    --Import classes
    for i = 1, #weaponsData.WEAPONS_LIST do
        local instance = weapon.new()
        local instanceData = weaponsData[weaponsData.WEAPONS_LIST[i]]
        instance.name = weaponsData.WEAPONS_LIST[i]
        instance.weaponType = instanceData.weaponType
        instance.bulletSpeed = instanceData.bulletSpeed
        instance.bulletDamage = instanceData.bulletDamage
        instance.bulletSpread = instanceData.bulletSpread
        instance.bulletPerShot = instanceData.bulletPerShot
        instance.bulletOffset = instanceData.bulletOffset
        instance.reloadTime = instanceData.reloadTime
        instance.shootTime = instanceData.shootTime
        instance.magSize = instanceData.magSize
        instance.bulletOffset = instanceData.bulletOffset
        instance.recoil = instanceData.recoil
        instance.screenShakeIntensity = instanceData.screenShakeIntensity
        instance.ammoType = instanceData.ammoType
        instance.handRecoilIntensity = instanceData.handRecoilIntensity
        instance.shellColor = instanceData.shellColor
        instance.fireLineColor = instanceData.fireLineColor
        instance.fireLineWidth = instanceData.fireLineWidth
        instance.aimRange = instanceData.aimRange
        self[instance.name] = instance
    end
end

return weaponManager