local particleFuncs = {}

function particleFuncs.shootParticleUpdate(particle, delta)
    local speed = 500
    particle.position[1] = particle.position[1] + math.cos(particle.rotation)*speed*delta
    particle.position[2] = particle.position[2] + math.sin(particle.rotation)*speed*delta
end

function particleFuncs.createShootParticles(comp, rotation)
    for _ = 1, 6 do
        local size = math.uniform(5, 10)
        comp:newParticle(
            {
                position = {60*math.cos(rotation), 60*math.sin(rotation)};
                size = {size, size};
                despawnTime = 0.1;
                color = {1, 0.47, 0.06, 0.85};
                rotation = rotation + math.uniform(-math.pi/3, math.pi/3);
                update = particleFuncs.shootParticleUpdate;
            }
        )
    end
end

function particleFuncs.createWallHitParticles(comp, bullet, i, material)
    for _ = 1, 4 do
        local s = math.uniform(4, 10)
        --determine color based on material
        local color = {0, 0, 0, 1}
        if material == "wood" then
            color = {0.5, 0.3, 0.1, math.uniform(0.6, 0.8)} -- NOTE varying colors like concrete?
        elseif material == "concrete" then
            local c = math.uniform(0.2, 0.4)
            color = {c, c, c, math.uniform(0.6, 0.8)}
        end
        comp:newParticle(
            {
                position = table.new(bullet.oldPositions[i]);
                size = {s, s};
                color = color;
                update = particleFuncs.wallHitParticleUpdate;
                rotation = bullet.rotation + math.pi + math.uniform(-math.pi/6, math.pi/6);
                despawnTime = 0.1;
            }
        )
    end
end

function particleFuncs.createBulletHoleParticles(comp, bullet, i)
    if not Settings.bullet_holes then return end
    --determine rotation
    local rot = bullet.rotation
    if rot > math.pi/4 and rot < 3*math.pi/4 then
        rot = math.pi/2
    end
    comp:newParticle(
        {
            position = table.new(bullet.oldPositions[i]);
            size = {6, 6};
            color = {0, 0, 0, 0.6};
            rotation = rot;
            despawnTime = 30;
        }
    )
end

function particleFuncs.wallHitParticleUpdate(particle, delta)
    local speed = 400
    particle.position[1] = particle.position[1] + math.cos(particle.rotation)*speed*delta
    particle.position[2] = particle.position[2] + math.sin(particle.rotation)*speed*delta
end

return particleFuncs