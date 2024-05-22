local weapon = {}

function weapon.new()
    local w = {
    	name;
    	weaponType;
    	bulletSpeed;
    	bulletDamage;
    	bulletSpread;
        bulletPerShot;
    	reloadTime;
    	shootTime;
    	magSize;
    	recoil;
    	magAmmo = 0;
		screenShakeIntensity = 0;
    }

    function w.new()
        return table.new(w)
    end

    return w
end

return weapon
