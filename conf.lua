
function love.conf(t)
    t.window.width = 960 ; t.window.height = 540
    t.window.title = "game"
    t.window.resizable = true
    t.window.minwidth = 960 ; t.window.minheight = 540
    t.console = true
    ScreenWidth, ScreenHeight = 960, 540
    --Some constants
    GAME_NAME = "Eternal Horizons"
    GAME_VERSION_STATE = "indev"
    GAME_VERSION = "0.3.dev1"
end