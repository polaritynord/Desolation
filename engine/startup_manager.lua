local json = require("engine.lib.json")
local scene = require("engine.scene")
local globals = require("engine.globals")
local weaponManager = require("desolation.weapon_manager")

local startupManager = {}

function startupManager:load()
    weaponManager:load()
    --Fetch game info
    local engineInfoFile = love.filesystem.read("engine/info.json")
    local engineInfoData = json.decode(engineInfoFile)
    GAME_DIRECTORY = engineInfoData.gameDirectory
    local infoFile = love.filesystem.read(GAME_DIRECTORY .. "/info.json")
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
    local defaultSettingsData = json.decode(defaultSettingsFile)
    if settingsExists and not table.contains(arg, "--default-settings") then
        --read settings file & save it as table
        local file = love.filesystem.read("settings.json")
        Settings = json.decode(file)
        --compare to default binding file & see if there is anything missing
        local currentSettingsList = {}
        for k, v in pairs(Settings) do
            currentSettingsList[#currentSettingsList+1] = k
        end
        local defaultSettingsList = {}
        for k, v in pairs(defaultSettingsData) do
            defaultSettingsList[#defaultSettingsList+1] = k
        end
        if #currentSettingsList ~= #defaultSettingsList then
            --write new settings file
            love.filesystem.write("settings.json", defaultSettingsFile)
            Settings = defaultSettingsData
        end
        --NOTE: this is kinda lazy of me to scrap the users current settings file just because
        --of an update, when I could compare the keys and add if anything is missing
        --this works for now , I guess
    else
        --write new settings file
        love.filesystem.write("settings.json", defaultSettingsFile)
        Settings = defaultSettingsData
    end

    --Load localization data
    Loca = love.filesystem.read("desolation/assets/loca_" .. Settings.language .. ".json")
    Loca = json.decode(Loca)

    --Screenshots folder
    if love.filesystem.getInfo("screenshots") == nil then
        love.filesystem.createDirectory("screenshots")
    end

    --Open up the default scene
    local startScene = LoadScene(infoData.startScene)
    if startScene.name == "Intro" and table.contains(arg, "--skip-intro") then
        startScene = LoadScene("desolation/assets/scenes/main_menu2.json")
    end
    SetScene(startScene)
end

return startupManager