local humanoid = {}

function humanoid.new()
    local instance = {
        position = {0, 0};
        velocity = {0, 0};
        rotation = 0;
        health = 100;
        armor = 100;
        sprinting = false;
        moving = false;
        animationSizeDiff = 0; --Used in walk animation
        inventory = {
            weapons = {nil, nil, nil};
            items = {};
            slot = 1;
        };
    }

    return instance
end

return humanoid