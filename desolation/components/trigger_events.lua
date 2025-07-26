local triggerEvents = {}

function triggerEvents.soundTest(prop)

end

function triggerEvents.loadc1Hallway(prop)
    local mapCreator = CurrentScene.mapCreator
    mapCreator.changingMapTo = "c1_hallway"
    mapCreator.mapTransitionPlayer = CurrentScene.player
end

return triggerEvents