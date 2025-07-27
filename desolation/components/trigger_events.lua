local triggerEvents = {}

function triggerEvents.chapter1Title(prop)
    local chapterTitleScript = CurrentScene.chapterTitle.script
    chapterTitleScript:setTitle("CHAPTER 1\nDORMITORIES")
end

function triggerEvents.loadc1Hallway(prop)
    local mapCreator = CurrentScene.mapCreator
    mapCreator.changingMapTo = "c1_hallway"
    mapCreator.mapTransitionPlayer = CurrentScene.player
end

return triggerEvents