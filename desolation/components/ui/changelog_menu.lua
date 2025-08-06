local coreFuncs = require("coreFuncs")
local changelogMenu = ENGINE_COMPONENTS.scriptComponent.new()

function changelogMenu:readChangelogFiles(changelog)
    changelog.texts = {
        {love.filesystem.read("desolation/assets/changelogs/1.5.txt"), 20, "Alpha 1.5"}
    }
    --[[
    for _, fileName in ipairs(love.filesystem.getDirectoryItems(GAME_DIRECTORY .. "/assets/changelogs")) do
        local filePath = GAME_DIRECTORY .. "/assets/changelogs/" .. fileName
        local lineCount = coreFuncs.totalLineCount(filePath)
        --Find the first line (by iterating through all of them, why tf was there not a better solution??)
        local firstLine = ""
        for line in love.filesystem.lines(filePath) do
            firstLine = line
            break
        end
        changelog.texts[#changelog.texts+1] = {love.filesystem.read(filePath), lineCount, firstLine}
    end
    ]]--
end

function changelogMenu:load()
    local changelog = self.parent
    local settings = changelog.parent
    local ui = changelog.UIComponent
    ui.enabled = false
    changelog.open = false
    changelog.realY = changelog.position[2]
    changelog.length = 1600

    self:readChangelogFiles(changelog)
    changelog.currentIndex = 1

    ui.title = ui:newTextLabel(
        {
            text = Loca.changelogMenu.title;
            size = 45;
            position = {0, 140};
            font = "disposable-droid-bold";
        }
    )
    --[[
    ui.versionTitle = ui:newTextLabel(
        {
            position = {0, 200};
            text = "Alpha 1.4";
            font = "disposable-droid-bold";
            size = 30;
            begin = "left";
        }
    )
    ]]--
    ui.changelogText = ui:newTextLabel(
        {
            position = {0, 200};
            text = changelog.texts[1][1];--"This is some sample text I've made up from my mind to experiment with how different changelogs of current and previous versions would look like in this menu. Of course, I still have got to figure out how to fetch those texts, 'cause I can't be bothered with manually adding them to the game.";
            wrapLimit = 600;
        }
    )
    ui.returnButton = ui:newTextButton(
        {
            buttonText = Loca.mainMenu.returnButton;
            buttonTextSize = 35;
            position = {0, 1460};
            clickEvent = function() changelog.open = false ; changelog.selection = nil end;
            bindedKey = "escape";
        }
    )
    ui.controllerButtons = {ui.changelogText, ui.returnButton}
end

function changelogMenu:update(delta)
    local changelog = self.parent
    local _settings = changelog.parent
    local ui = changelog.UIComponent

    --UI Offsetting & canvas enabling
    changelog.position[1] = 600 + MenuUIOffset
    changelog.position[2] = changelog.position[2] + (changelog.realY-changelog.position[2])*8*delta
    ui.enabled = changelog.open
    --Transparency animation
    if ui.enabled then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end

    if not ui.enabled then return end
    --Change length based on current selected text (NOTE unused for now)
    if true then return end
    local lineCount = changelog.texts[changelog.currentIndex][2]
    changelog.length = 65*lineCount
    ui.returnButton.position[2] = 515+(lineCount-1)*24
end

return changelogMenu