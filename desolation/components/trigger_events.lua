local triggerEvents = {}

function triggerEvents.soundTest(prop)

end

function triggerEvents.loadc1Hallway(prop)
    local mapCreator = CurrentScene.mapCreator
    mapCreator.changingMapTo = "desolation/assets/maps/c1_hallway.json"
    mapCreator.mapTransitionPlayer = CurrentScene.player
end

return triggerEvents