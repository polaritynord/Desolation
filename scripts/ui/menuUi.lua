local interfaceManager = require("scripts.ui.interfaceManager")

local menuUi = {}

--Element event funcs
local function playButtonClick()
    menuUi:unload()
    GameLoad()
    GameState = "game"
end

function menuUi:unload()
    table.remove(interfaceManager.canvases, self.mainMenu.index)
    self.mainMenu = nil
end

function menuUi:load()
    self.mainMenu = interfaceManager:newCanvas()

    --Title
    self.mainMenu.title = self.mainMenu:newTextLabel(
        "ETERNAL HORIZONS", {50, 50}, 64, "xx", "left", "disposable-droid", {1,1,1,1}
    )
    --Play button
    self.mainMenu.play = self.mainMenu:newButton(
        {70, 200}, {0,0}, {1,1,1,1}, 1, "Play", 30,
        "disposable-droid", "xx", playButtonClick
    )
end

function menuUi:update(delta)
    self.mainMenu.enabled = GameState == "menu"
end

return menuUi