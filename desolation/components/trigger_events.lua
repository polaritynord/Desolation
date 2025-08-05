local triggerEvents = {}

--Chapter title trigger events
function triggerEvents.chapter1Title(prop)
    local chapterTitleScript = CurrentScene.chapterTitle.script
    chapterTitleScript:setTitle("CHAPTER 1\nAWAKENED")
end

--Map switching trigger events
function triggerEvents.loadc1Hallway(prop)
    local mapCreator = CurrentScene.mapCreator
    mapCreator.changingMapTo = "c1_hallway"
    mapCreator.mapTransitionPlayer = CurrentScene.player
end

function triggerEvents.loadc1Labs(prop)
    local mapCreator = CurrentScene.mapCreator
    mapCreator.changingMapTo = "c1_labs"
    mapCreator.mapTransitionPlayer = CurrentScene.player
end

--Key hint trigger events
function triggerEvents.sprintHint(prop)
    local keyHintsScript = CurrentScene.keyHints.script
    keyHintsScript:addHintToQueue("lshift")
end

function triggerEvents.zoomHint(prop)
    local keyHintsScript = CurrentScene.keyHints.script
    keyHintsScript:addHintToQueue(nil, "USE THE SCROLL WHEEL TO ZOOM")
end

return triggerEvents