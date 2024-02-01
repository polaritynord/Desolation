local interfaceManager = require("scripts.ui.interfaceManager")
local quitButtonClick = require("scripts.ui.gameUi").quitButtonClick

local menuUi = {}

--Element event funcs
local function playButtonClick()
    GameLoad()
    GameState = "game"
end

function menuUi:setCanvasState()
    self.mainMenu.enabled = GameState == "menu"
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
    --Quit button
    self.mainMenu.quit = self.mainMenu:newButton(
        {70, 240}, {0,0}, {1,1,1,1}, 1, "Quit", 30,
        "disposable-droid", "xx", quitButtonClick
    )
end

function menuUi:update(delta)
    self:setCanvasState()
end

return menuUi