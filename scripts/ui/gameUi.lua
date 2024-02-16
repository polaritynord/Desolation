local assets = require("assets")
local interfaceManager = require("scripts.ui.interfaceManager")
local coreFuncs = require("coreFuncs")
local gameUi = {}

--Button event functions
local function menuButtonClick(_element)
    GameState = "menu"
end

function gameUi.quitButtonClick(element)
    if element.buttonText == "Quit" then
        element.buttonText = "Are You Sure?"
    else
        love.event.quit()
    end
end

-- CANVAS CREATION FUNCTIONS
function gameUi:createHUDCanvas()
    self.hud = interfaceManager:newCanvas()
    self.hud:newImage(assets.images.ui.healthBar, {97, 465}, {2.35,2.35}, 0, "x+")
    --Health counter
    self.hud.healthText = self.hud:newTextLabel(
        Player.health, {55, 490}, 48, "x+", "left", "disposable-droid", {1,1,1,1}
    )
    --Armor counters
    self.hud.armorText = self.hud:newTextLabel(
        Player.armor, {44, 448}, 32, "x+", "left", "disposable-droid", {1,1,1,1}
    )

    --Current weapon index
    self.hud.weaponIndex = self.hud:newTextLabel(
        "1", {700, 470}, 24, "++", "left", "disposable-droid", {1,1,1,1}
    )
    --Current weapon image
    self.hud.weaponImg = self.hud:newImage(
        assets.images.ui.pistolImg, {760, 480}, {3,3}, 0, "++"
    )
    --Current weapon mag ammo
    self.hud.weaponMagAmmo = self.hud:newTextLabel(
        "12", {800, 455}, 36, "++", "left", "disposable-droid-bold", {1,1,1,1}
    )
    --Ammunition of current weapon
    self.hud.weaponAmmunition = self.hud:newTextLabel(
        "94", {800, 485}, 20, "++", "left", "disposable-droid", {1,1,1,1}
    )

    --Other weapons 1 index
    self.hud.weapon2Index = self.hud:newTextLabel(
        "2", {840, 430}, 20, "++", "left", "disposable-droid", {1,1,1,1}
    )
    --Other weapons 1 image
    self.hud.weapon2Img = self.hud:newImage(
        assets.images.ui.ARImg, {890, 440}, {2,2}, 0, "++"
    )
    --Other weapons 2 index
    self.hud.weapon3Index = self.hud:newTextLabel(
        "3", {840, 480}, 20, "++", "left", "disposable-droid", {1,1,1,1}
    )
    --Other weapons 2 image
    self.hud.weapon3Img = self.hud:newImage(
        assets.images.ui.shotgunImg, {890, 490}, {2,2}, 0, "++"
    )
end

function gameUi:createPauseCanvas()
    self.pauseMenu = interfaceManager:newCanvas()
    --Background
    self.pauseMenu.background = self.pauseMenu:newRectangle(
        {0,0}, {960, 540}, {0, 0, 0, 0.6}, "xx"
    )
    --Title
    self.pauseMenu.title = self.pauseMenu:newTextLabel(
        "ETERNAL HORIZONS", {50, 50}, 64, "xx", "left", "disposable-droid", {1,1,1,1}
    )
    --Continue button
    self.pauseMenu.continue = self.pauseMenu:newButton(
        {70, 200}, {0,0}, {1,1,1,1}, 1, "Continue", 30,
        "disposable-droid", "xx", function() GamePaused = false end
    )
    --Settings button
    self.pauseMenu.settings = self.pauseMenu:newButton(
        {70, 240}, {0,0}, {1,1,1,1}, 1, "Settings", 30,
        "disposable-droid", "xx", nil
    )
    --Menu button
    self.pauseMenu.menu = self.pauseMenu:newButton(
        {70, 280}, {0,0}, {1,1,1,1}, 1, "Main Menu", 30,
        "disposable-droid", "xx", menuButtonClick
    )
    --Quit button
    self.pauseMenu.quit = self.pauseMenu:newButton(
        {70, 320}, {0,0}, {1,1,1,1}, 1, "Quit", 30,
        "disposable-droid", "xx", gameUi.quitButtonClick
    )
end

function gameUi:createDebugCanvas()
    self.debug = interfaceManager:newCanvas()
    self.debug.toggled = false
    self.debug.verboseMode = false
    self.debug.debugTexts = self.debug:newTextLabel(
        "FPS: 217", {0, 0}, 20, "xx", "left", "disposable-droid", {1,1,1,1}
    )
end

-- CANVAS UPDATING FUNCTIONS
function gameUi:updateHUDCanvas()
    --Health & Armor bars
    self.hud.healthText.text = Player.health
    self.hud.armorText.text = Player.armor
    --Current weapon
    local weapon = Player.inventory.weapons[Player.inventory.slot]
    if weapon then
        self.hud.weaponImg.source = assets.images.weapons[string.lower(weapon.name) .. "Img"]
        self.hud.weaponMagAmmo.text = weapon.magAmmo
        self.hud.weaponAmmunition.text = Player.inventory.ammunition[weapon.ammoType]
        --Update current weapon image scaling if the image is too big
        local imgWidth = self.hud.weaponImg.source:getWidth()
        if imgWidth > 18 then
            local newScale = 54/imgWidth
            self.hud.weaponImg.scale = {newScale, newScale}
        else
            self.hud.weaponImg.scale = {3, 3}
        end
    else
        self.hud.weaponImg.source = nil
        self.hud.weaponMagAmmo.text = "-"
        self.hud.weaponAmmunition.text = "-"
    end
    self.hud.weaponIndex.text = Player.inventory.slot
    --Other weapon views
    --Find smallest value in {1, 2, 3} excluding our current slot number
    local numberList = {1, 2, 3} ; table.remove(numberList, Player.inventory.slot)
    table.sort(numberList)
    --Weapon 2
    weapon = Player.inventory.weapons[numberList[1]]
    self.hud.weapon2Index.text = numberList[1]
    if weapon then
        self.hud.weapon2Img.source = assets.images.weapons[string.lower(weapon.name) .. "Img"]
    else
        self.hud.weapon2Img.source = nil
    end
    --Weapon 3
    weapon = Player.inventory.weapons[numberList[2]]
    self.hud.weapon3Index.text = numberList[2]
    if weapon then
        self.hud.weapon3Img.source = assets.images.weapons[string.lower(weapon.name) .. "Img"]
    else
        self.hud.weapon3Img.source = nil
    end
end

function gameUi:updatePauseCanvas(delta)
    self.pauseMenu.enabled = GamePaused
    --Smooth alpha transitioning
    local smoothness = 7
    if GamePaused then
        self.pauseMenu.alpha = self.pauseMenu.alpha + (1 - self.pauseMenu.alpha) * smoothness * delta
    else
        self.pauseMenu.alpha = 0.4
    end
    --Scale background to fit screen
    self.pauseMenu.background.size = {ScreenWidth, ScreenHeight}
end

function gameUi:setCanvasState()
    self.hud.enabled = GameState == "game"
    self.pauseMenu.enabled = GameState == "game" and GamePaused
    self.debug.enabled = GameState == "game" and self.debug.toggled
end

function gameUi:updateDebugCanvas()
    local fps = love.timer.getFPS()
    --write vsync next to fps counter if enabled
    local fps_suffix
    if love.window.getVSync() == 1 then
        fps_suffix = " (VSync ON)"
    else
        fps_suffix = " (VSync OFF)"
    end
    --Update debug text
    self.debug.debugTexts.text = GAME_NAME .. " " .. GAME_VERSION_STATE .. " " .. GAME_VERSION ..
                                " - Made by PolarNord" .. "\nFPS: " .. fps .. fps_suffix .. "\nPlayer Coordinates: X=" ..
                                math.floor(Player.position[1]) .. " Y=" .. math.floor(Player.position[2]) .. "\n" ..
                                "Memory Used(Excluding Love2D): " .. coreFuncs.roundDecimal(collectgarbage("count")/1024, 2) .. " MB"
    --TODO additional debug info to add: particle count, humanoid count
end

-- MAIN FUNCTIONS
function gameUi:load()
    self:createHUDCanvas()
    self:createDebugCanvas()
    self:createPauseCanvas()
end

function gameUi:update(delta)
    self:setCanvasState()
    if GameState ~= "game" then return end
    self:updatePauseCanvas(delta)
    self:updateDebugCanvas()
    if GamePaused then return end
    self:updateHUDCanvas()
end

return gameUi