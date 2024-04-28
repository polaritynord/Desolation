local particleFunctions = {}

function particleFunctions.shootParticleUpdate(particle, delta)
    local speed = 500
    particle.position[1] = particle.position[1] + math.cos(particle.rotation)*speed*delta
    particle.position[2] = particle.position[2] + math.sin(particle.rotation)*speed*delta
end

return particleFunctions