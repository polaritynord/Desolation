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

function particleFuncs.createWallHitParticles(comp, bullet, i)
    for _ = 1, 4 do
        local c = math.uniform(0.2, 0.4)
        local s = math.uniform(4, 10)
        comp:newParticle(
            {
                position = table.new(bullet.oldPositions[i]);
                size = {s, s};
                color = {c, c, c, math.uniform(0.6, 0.8)};
                update = particleFuncs.wallHitParticleUpdate;
                rotation = bullet.rotation + math.pi + math.uniform(-math.pi/6, math.pi/6);
                despawnTime = 0.1;
            }
        )
    end
end

function particleFuncs.wallHitParticleUpdate(particle, delta)
    local speed = 400
    particle.position[1] = particle.position[1] + math.cos(particle.rotation)*speed*delta
    particle.position[2] = particle.position[2] + math.sin(particle.rotation)*speed*delta
end

return particleFuncs