
function love.conf(t)
    t.window.width = 960 ; t.window.height = 540
    t.window.title = "game"
    t.window.resizable = true
    t.console = true
    ScreenWidth, ScreenHeight = 960, 540
    --Some constants
    GAME_NAME = "Eternal Horizons"
    GAME_VERSION_STATE = "indev"
    GAME_VERSION = "0.2.dev1"
end