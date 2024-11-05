-- Main.lua file for the game 'My 600-lb Escape'
display.setStatusBar(display.HiddenStatusBar)

-- Initialize physics
local physics = require("physics")
physics.start()
physics.setGravity(0, 9.8)

-- Screen boundaries
local screenLeft = display.screenOriginX
local screenRight = display.contentWidth - display.screenOriginX
local screenBottom = display.contentHeight - display.screenOriginY
local screenTop = display.screenOriginY

-- Load and set background image
local background = display.newImageRect("background/background_5.jpg", display.contentWidth, display.contentHeight)
background.x = display.contentCenterX
background.y = display.contentCenterY

-- Tela inicial
local startScreenGroup = display.newGroup()

local titleText = display.newText({
    text = "My 600-lb Escape",
    x = display.contentCenterX,
    y = display.contentCenterY - 100,
    font = native.systemFontBold,
    fontSize = 40
})
titleText:setFillColor(1, 1, 1)
startScreenGroup:insert(titleText)

local rulesText = display.newText({
    text =
    "Regras:\n- Pule os obstáculos ricos em carboidratos.\n- Colida com alimentos saudáveis para perder peso.\n- Evite ganhar peso acima de 300kg.",
    x = display.contentCenterX,
    y = display.contentCenterY,
    width = display.contentWidth - 40,
    font = native.systemFont,
    fontSize = 20,
    align = "center"
})
rulesText:setFillColor(0.8, 0.8, 0.8)
startScreenGroup:insert(rulesText)

local startButton = display.newRect(display.contentCenterX, display.contentCenterY + 150, 150, 50)
startButton:setFillColor(0.1, 0.5, 0.1)
startScreenGroup:insert(startButton)

local buttonText = display.newText({
    text = "Start",
    x = startButton.x,
    y = startButton.y,
    font = native.systemFontBold,
    fontSize = 24
})
buttonText:setFillColor(1, 1, 1)
startScreenGroup:insert(buttonText)

-- Função para iniciar o jogo
local function startGame()
    startScreenGroup:removeSelf() -- Remove a tela de início
    startScreenGroup = nil

    -- Load character jump images and initial setup
    local characterFrames = {
        "character/imag_0_processed.png",
        "character/imag_1_processed.png",
        "character/imag_2_processed.png",
        "character/imag_3_processed.png",
        "character/imag_6_processed.png" -- Final position to reset to standing
    }

    local character = display.newImageRect(characterFrames[1], 120, 140)
    character.x = display.contentCenterX
    character.y = screenBottom - 150 -- Initial position above ground level
    physics.addBody(character, "dynamic", { radius = 30, bounce = 0 })
    character.isFixedRotation = true -- Prevent character from rotating
    character.weight = 66            -- Initial weight set to 66 kg

    -- Dentro da função de atualização ou pulo do personagem
    local function updatePosition()
        character.y = math.min(character.y, screenBottom - 150) -- Limite inferior
        character.y = math.max(character.y, screenTop + 150)    -- Limite superior
        character.x = math.max(screenLeft + 150, math.min(character.x, screenRight - 150))
    end

    Runtime:addEventListener("enterFrame", updatePosition)

    local jumpIndex = 1
    local function characterJump()
        if jumpIndex < #characterFrames then
            jumpIndex = jumpIndex + 1
        else
            jumpIndex = 1
        end
        character.fill = { type = "image", filename = characterFrames[jumpIndex] }
        character:applyLinearImpulse(0, -2, character.x, character.y) -- Controlled jump impulse
    end

    local weightBar = display.newRect(display.contentCenterX, 20, character.weight, 20)
    weightBar:setFillColor(0, 1, 0)

    local weightText = display.newText({
        text = tostring(character.weight) .. " kg",
        x = display.contentCenterX,
        y = 20,
        font = native.systemFontBold,
        fontSize = 16
    })
    weightText:setFillColor(0, 0, 0)

    -- Função para exibir "Game Over" e parar o jogo
    local function gameOver()
        local gameOverText = display.newText({
            text = "Game Over!",
            x = display.contentCenterX,
            y = display.contentCenterY,
            font = native.systemFontBold,
            fontSize = 48
        })
        gameOverText:setFillColor(1, 0, 0) -- Vermelho

        -- Pausa a física do jogo
        physics.pause()

        -- Verifica e remove os event listeners, se existirem
        if Runtime:hasEventListener("enterFrame", updatePosition) then
            Runtime:removeEventListener("enterFrame", updatePosition)
        end

        if Runtime:hasEventListener("touch", onScreenTouch) then
            Runtime:removeEventListener("touch", onScreenTouch)
        end

        if character and character.removeEventListener then
            character:removeEventListener("collision", onCollision)
        end
    end

    -- Listener para o botão de início
    startButton:addEventListener("tap", startGame)


    local function updateWeight()
        weightBar.width = character.weight
        weightText.text = tostring(character.weight) .. " kg"
        if character.weight >= 300 then
            gameOver()
        elseif character.weight > 100 then
            weightBar:setFillColor(1, 0, 0)
            weightText:setFillColor(1, 0, 0)
        else
            weightBar:setFillColor(0, 1, 0)
            weightText:setFillColor(0, 0, 0)
        end
        print("Current weight: ", character.weight)
    end

    local function createObstacle(name, imgPath, carbs, yPosition, speed)
        local sizeScale = 70 + carbs * 0.5
        local obstacle = display.newImageRect(imgPath, sizeScale, sizeScale)
        obstacle.x = math.random(screenLeft + 30, screenRight - 30)
        obstacle.y = yPosition
        physics.addBody(obstacle, "static")
        obstacle.name = name
        obstacle.carbs = carbs

        local function moveObstacle()
            if obstacle.x < screenLeft - 50 then
                obstacle.x = screenRight + math.random(100, 200)
            else
                obstacle.x = obstacle.x - speed
            end
        end
        Runtime:addEventListener("enterFrame", moveObstacle)
        return obstacle
    end

    -- Create upper and lower obstacles
    local upperObstacles = {
        { name = "crossfit",         path = "obstacles/crossfit.png",         carbs = 10 },
        { name = "run",              path = "obstacles/run.png",              carbs = 90 },
        { name = "barbecue_healthy", path = "obstacles/barbecue_healthy.png", carbs = 15 },
        { name = "strawberry",       path = "obstacles/strawberry.png",       carbs = 5 },
        { name = "eggplant",         path = "obstacles/eggplant.png",         carbs = 3 },
        { name = "gym",              path = "obstacles/gym.png",              carbs = 0 },
        { name = "meat",             path = "obstacles/meat.png",             carbs = 0 },
    }
    local lowerObstacles = {
        { name = "bread",                path = "obstacles/bread.png",                carbs = 60 },
        { name = "rice",                 path = "obstacles/rice.png",                 carbs = 40 },
        { name = "noodle",               path = "obstacles/noodle.png",               carbs = 45 },
        { name = "estresse",             path = "obstacles/estresse.png",             carbs = 55 },
        { name = "work_a_lot",           path = "obstacles/work_a_lot.png",           carbs = 75 },
        { name = "ice_cream",            path = "obstacles/ice_cream.png",            carbs = 50 },
        { name = "sedentary_life_style", path = "obstacles/sedentary_life_style.png", carbs = 125 },
    }

    for _, info in ipairs(upperObstacles) do
        createObstacle(info.name, info.path, info.carbs, screenTop + 450, 2)
    end
    for _, info in ipairs(lowerObstacles) do
        createObstacle(info.name, info.path, info.carbs, screenBottom - 150, 1.5)
    end

    local function onCollision(event)
        if event.phase == "began" and event.other.carbs ~= nil then
            if event.other.carbs > 20 then
                character.weight = character.weight + 5
                weightBar:setFillColor(1, 0, 0)
                weightText:setFillColor(1, 0, 0)
            else
                character.weight = character.weight - 2
                weightBar:setFillColor(0, 1, 0)
                weightText:setFillColor(0, 0, 0)
            end
            updateWeight()
        end
    end
    character:addEventListener("collision", onCollision)

    local function onScreenTouch(event)
        if event.phase == "began" then
            characterJump()
        end
    end
    Runtime:addEventListener("touch", onScreenTouch)
end

-- Listener para o botão de início
startButton:addEventListener("tap", startGame)
