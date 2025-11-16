local buttonEvents = require "desolation.button_clickevents"
local infiniteMenu = ENGINE_COMPONENTS.scriptComponent.new()

function infiniteMenu:load()
    local infinite = self.parent
    local ui = infinite.UIComponent
    ui.enabled = false
    infinite.maps = {"openarea"}
    infinite.mapSelection = 1;
    infinite.realY = infinite.position[2]
    infinite.length = 655
    infinite.difficulty = 1
    infinite.amounts = {
        crate = 54;
        barrel = 16;
        expBarrel = 15;
    }
    infinite.regenerateProps = true

    ui.title = ui:newTextLabel(
        {
            text = Loca.extrasMenu.infiniteTitle;
            size = 45;
            position = {0, 140};
            font = "disposable-droid-bold";
        }
    )
    ui.difficultyIcon = ui:newImage(
        {
            source = Assets.images.difficulty_1;
            position = {20, 214};
            scale = {1.5, 1.5};
        }
    )
    ui.difficultyPicker = ui:newTextButton(
        {
            buttonText = Loca.extrasMenu.infiniteDifficulty .. string.upper(Loca.extrasMenu.infiniteDifficulties[infinite.difficulty]);
            position = {48, 200};
            buttonTextSize = 30;
            hoverEvent = buttonEvents.redHover;
            unhoverEvent = buttonEvents.redUnhover;
            clickEvent = function (element)
                infinite.difficulty = infinite.difficulty + 1
                if infinite.difficulty > #Loca.extrasMenu.infiniteDifficulties then infinite.difficulty = 1 end
                element.buttonText = Loca.extrasMenu.infiniteDifficulty .. string.upper(Loca.extrasMenu.infiniteDifficulties[infinite.difficulty])
            end
        }
    )
    ui.difficultyHighScoreText = ui:newTextLabel(
        {
            text = Loca.extrasMenu.highScore .. ": ";
            size = 24;
            position = {300, 202};
            color = {1, 1, 1, 0.8};
        }
    )
    ui.difficultyDescription = ui:newTextLabel(
        {
            position = {0, 250};
            size = 16;
        }
    )
    ui.crateAmountText = ui:newTextLabel(
        {
            text = Loca.extrasMenu.crateAmount;
            position = {0, 280};
            size = 30;
        }
    )
    ui.crateAmountSlider = ui:newSlider(
        {
            position = {355, 286};
            baseColor = {0.5, 0.5, 0.5, 1};
            baseSize = {135, 18};
            valueText = false;
            value = 0.88;
        }
    )
    ui.barrelAmountText = ui:newTextLabel(
        {
            text = Loca.extrasMenu.barrelAmount;
            position = {0, 320};
            size = 30;
        }
    )
    ui.barrelAmountSlider = ui:newSlider(
        {
            position = {355, 326};
            baseColor = {0.5, 0.5, 0.5, 1};
            baseSize = {135, 18};
            valueText = false;
            value = 0.68;
        }
    )
    ui.expBarrelAmountText = ui:newTextLabel(
        {
            text = Loca.extrasMenu.expBarrelAmount;
            position = {0, 360};
            size = 30;
        }
    )
    ui.expBarrelAmountSlider = ui:newSlider(
        {
            position = {355, 366};
            baseColor = {0.5, 0.5, 0.5, 1};
            baseSize = {135, 18};
            valueText = false;
            value = 0.71;
        }
    )
    ui.regeneratePropsText = ui:newTextLabel(
        {
            position = {0, 400};
            text = Loca.extrasMenu.regenerateProps;
            size = 30;
        }
    )
    ui.regeneratePropsBox = ui:newCheckbox(
        {
            position = {400, 415};
            toggled = infinite.regenerateProps;
        }
    )
    ui.startGameButton = ui:newTextButton(
        {
            buttonText = Loca.extrasMenu.startGame;
            buttonTextSize = 30;
            position = {0, 440};
            clickEvent = function()
                local scene = LoadScene("desolation/assets/scenes/game.json")
                scene.difficulty = infinite.difficulty
                scene.amounts = infinite.amounts
                scene.regenerateProps = infinite.regenerateProps
                scene.score = 0
                scene.wave = 1
                SetScene(scene)
                scene.mapCreator.script:loadMap("infinite_openarea")
            end;
            hoverEvent = buttonEvents.redHover;
            unhoverEvent = buttonEvents.redUnhover;
        }
    )
    ui.controllerButtons = {
        ui.mapLeftArrow,
        ui.mapRightArrow,
        ui.difficultyPicker,
        ui.crateAmountSlider,
        ui.barrelAmountSlider,
        ui.expBarrelAmountSlider,
        ui.regeneratePropsBox,
        ui.startGameButton
    }
end

function infiniteMenu:update(delta)
    local infinite = self.parent
    local menu = infinite.parent
    local ui = infinite.UIComponent
    
    --UI Offsetting & canvas enabling
    infinite.position[1] = 950 + MenuUIOffset
    infinite.position[2] = infinite.position[2] + (infinite.realY-infinite.position[2])*8*delta
    ui.enabled = menu.selection == "infinite"
    --Transparency animation
    if ui.enabled then
        ui.alpha = ui.alpha + (1-ui.alpha)*12*delta
    else
        ui.alpha = 0.25
    end

    if not ui.enabled then return end
    --Set difficulty icon
    ui.difficultyIcon.source = Assets.images["difficulty_" .. infinite.difficulty]
    --Set the difficulty description
    ui.difficultyDescription.text = Loca.extrasMenu.difficultyDescs[infinite.difficulty]
    if infinite.difficulty == #Loca.extrasMenu.infiniteDifficulties then
        ui.difficultyDescription.font = "pryonkalsov"
    else
        ui.difficultyDescription.font = "disposable-droid"
    end
    --Set the difficulty high score text
    local score = Achievements.other.infiniteHighScores[infinite.difficulty]
    local count = Achievements.other.infiniteMatchCounts[infinite.difficulty]
    ui.difficultyHighScoreText.text = Loca.extrasMenu.highScore .. ": " .. tostring(score) .. "\n" .. Loca.extrasMenu.matchesPlayed .. ": " .. tostring(count)
    --Calculate amount values
    infinite.amounts.crate = math.floor(28+(ui.crateAmountSlider.value)*30)
    infinite.amounts.barrel = math.floor(9+(ui.barrelAmountSlider.value)*11)
    infinite.amounts.expBarrel = math.floor(8+(ui.expBarrelAmountSlider.value)*10)
    --Amount texts
    ui.crateAmountText.text = Loca.extrasMenu.crateAmount .. tostring(infinite.amounts.crate)
    ui.barrelAmountText.text = Loca.extrasMenu.barrelAmount .. tostring(infinite.amounts.barrel)
    ui.expBarrelAmountText.text = Loca.extrasMenu.expBarrelAmount .. tostring(infinite.amounts.expBarrel)
    infinite.regenerateProps = ui.regeneratePropsBox.toggled
    --quitting when using controller
    if InputManager:isPressed("return") then
        menu.selection = nil
        --UpdateControllerHints("menu_normal")
    end
end

return infiniteMenu
