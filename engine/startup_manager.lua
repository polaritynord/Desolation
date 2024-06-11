local json = require("engine.lib.json")
local scene = require("engine.scene")
local globals = require("engine.globals")

local startupManager = {}

function startupManager:load()
    --Fetch game info
    local engineInfoFile = love.filesystem.read("engine/info.json")
    local engineInfoData = json.decode(engineInfoFile)
    local gameDirectory = engineInfoData.gameDirectory
    local infoFile = love.filesystem.read(gameDirectory .. "/info.json")
    local infoData = json.decode(infoFile)
    GAME_NAME = infoData.name
    GAME_VERSION = infoData.version
    GAME_VERSION_STATE = infoData.versionState
    AUTHOR = infoData.author
    ENGINE_NAME = engineInfoData.name
    ENGINE_VERSION = engineInfoData.version

    --Load settings data
    local settingsExists = love.filesystem.getInfo("settings.json")
    local defaultSettingsFile = love.filesystem.read("desolation/assets/default_settings.json")
    if settingsExists and not table.contains(arg, "--default-settings") then
        --read settings file & save it as table
        local file = love.filesystem.read("settings.json")
        Settings = json.decode(file)
        --TODO compare to default binding file & see if there is anything missing
    else
        --write new settings file
        love.filesystem.write("settings.json", defaultSettingsFile)
        Settings = json.decode(defaultSettingsFile)
    end

    --Load localization data
    Loca = love.filesystem.read("desolation/assets/loca_" .. Settings.language .. ".json")
    Loca = json.decode(Loca)

    --Open up the default scene
    local startScene = LoadScene(infoData.startScene)
    if startScene.name == "Intro" and table.contains(arg, "--skip-intro") then
        startScene = LoadScene("desolation/assets/scenes/main_menu2.json")
    end
    SetScene(startScene)
end

return startupManager