local particleFuncs = {}

function particleFuncs.shootParticleUpdate(particle, delta)
    local speed = 500
    particle.position[1] = particle.position[1] + math.cos(particle.rotation)*speed*delta
    particle.position[2] = particle.position[2] + math.sin(particle.rotation)*speed*delta
end

function particleFuncs.wallHitParticleUpdate(particle, delta)
    local speed = 400
    particle.position[1] = particle.position[1] + math.cos(particle.rotation)*speed*delta
    particle.position[2] = particle.position[2] + math.sin(particle.rotation)*speed*delta
end

function particleFuncs.crateWoodUpdate(particle, delta)
    particle.position[1] = particle.position[1] + math.cos(particle.rotation)*particle.velocity*delta
    particle.position[2] = particle.position[2] + math.sin(particle.rotation)*particle.velocity*delta
    particle.velocity = particle.velocity + (-particle.velocity)*10*delta
end

function particleFuncs.explosionBaseUpdate(particle, delta)
    particle.size[1] = particle.size[1] + 400*delta
    particle.color[4] = particle.color[4] - 3*delta
end

function particleFuncs.explosionPieceUpdate(particle, delta)
    particle.position[1] = particle.position[1] + math.cos(particle.rotation)*1000*delta
    particle.position[2] = particle.position[2] + math.sin(particle.rotation)*1000*delta
end

function particleFuncs.createShootParticles(humanoid, comp, rotation)
    for _ = 1, 6 do
        local size = math.uniform(5, 10)
        comp:newParticle(
            {
                position = {humanoid.position[1] + 60*math.cos(rotation), humanoid.position[2] + 60*math.sin(rotation)};
                size = {size, size};
                despawnTime = 0.1;
                color = {1, 0.47, 0.06, 0.85};
                rotation = rotation + math.uniform(-math.pi/3, math.pi/3);
                update = particleFuncs.shootParticleUpdate;
            }
        )
    end
end

function particleFuncs.createWallHitParticles(comp, bulletPos, bulletRot, i, material)
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
                position = table.new(bulletPos);
                size = {s, s};
                color = color;
                update = particleFuncs.wallHitParticleUpdate;
                rotation = bulletRot + math.pi + math.uniform(-math.pi/6, math.pi/6);
                despawnTime = 0.1;
            }
        )
    end
end

function particleFuncs.createBulletHoleParticles(comp, bulletPos, bulletRot, i)
    --if not Settings.bullet_holes then return end
    --determine rotation
    local rot = bulletRot
    if rot > math.pi/4 and rot < 3*math.pi/4 then
        rot = math.pi/2
    end
    comp:newParticle(
        {
            position = table.new(bulletPos);
            size = {6, 6};
            color = {0, 0, 0, 0.6};
            rotation = rot;
            despawnTime = 30;
        }
    )
end

function particleFuncs.createCrateWoodParticles(comp, position)
    for _ = 1, 4 do
        local temp = math.uniform(0.7, 1.1)
        local p = comp:newParticle(
            {
                position = table.new(position);
                sourceImage = Assets.images["crate_wood"];
                type = "image";
                size = {2*temp, 2*temp};
                rotation = math.uniform(0, math.pi*2);
                despawnTime = 5;
                update = particleFuncs.crateWoodUpdate;
            }
        )
        p.velocity = math.uniform(200, 400);
    end
end

function particleFuncs.createExplosionParticles(comp, position)
    --base
    comp:newParticle(
        {
            position = table.new(position);
            type = "circle";
            color = {1, 0.4, 0.2, 0.85};
            update = particleFuncs.explosionBaseUpdate;
            despawnTime = 0.7;
        }
    )
    --small thingies (idk what to call them) (shrapnel? is that how its written?)
    for _ = 1, 12 do
        local s = math.uniform(10, 25)
        local particle = comp:newParticle(
            {
                position = {position[1] + math.uniform(-40, 40), position[2] + math.uniform(-40, 40)};
                color = {1, 0.64, 0.2, 1};
                size = {s, s};
                update = particleFuncs.explosionPieceUpdate;
                despawnTime = 0.3;
            }
        )
        particle.rotation = math.atan2(particle.position[2]-position[2], particle.position[1]-position[1])
    end
end

function particleFuncs.createBulletShellParticle(comp, humanoid, weapon)
    if not Settings.bullet_shell_particles then return end
    local color = weapon.shellColor
    local d = math.uniform(0.8, 1)
    local particle = comp:newParticle(
        {
            position = {
                humanoid.position[1] + math.cos(humanoid.rotation)*weapon.bulletOffset/1.5,
                humanoid.position[2] + math.sin(humanoid.rotation)*weapon.bulletOffset/1.5
            };
            rotation = humanoid.rotation + math.pi/2 + math.uniform(-math.pi/10, math.pi/10);
            despawnTime = 10;
            size = {8, 4};
            color = {color[1]*d, color[2]*d, color[3]*d, 1};
            update = function(particle, delta)
                --rotate
                particle.rotation = particle.rotation + particle.rotVelocity*delta
                particle.rotVelocity = particle.rotVelocity + (-particle.rotVelocity)*8*delta
                --move
                particle.position[1] = particle.position[1] + math.cos(particle.realRot)*particle.velocity*delta
                particle.position[2] = particle.position[2] + math.sin(particle.realRot)*particle.velocity*delta
                particle.velocity = particle.velocity + (-particle.velocity)*8*delta
            end;
        }
    )
    particle.realRot = particle.rotation
    particle.rotVelocity = 100
    particle.velocity = math.uniform(600, 850)
end

return particleFuncs