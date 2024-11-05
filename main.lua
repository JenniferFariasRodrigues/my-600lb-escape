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
titleText:setFillColor(0, 0, 0)
startScreenGroup:insert(titleText)

local rulesText = display.newText({
    text =
    "Regras:\n- Pule os obstáculos ricos em carboidratos.\n- Colida com alimentos saudáveis para perder peso.\n- Evite ganhar peso acima de 300kg.\n- Evite perder peso abaixo de 45kg.",
    x = display.contentCenterX,
    y = display.contentCenterY,
    width = display.contentWidth - 40,
    font = native.systemFont,
    fontSize = 20,
    align = "center"
})
rulesText:setFillColor(0, 0, 0)
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

-- Variáveis globais para obstáculos
upperObstacles = {}
lowerObstacles = {}

-- Função para iniciar o jogo
local function startGame()
    startScreenGroup:removeSelf() -- Remove a tela de início
    startScreenGroup = nil

    -- Load character jump images and initial setup
    local characterFrames = {
        "character/imag_0_processed.png", -- Posição inicial (de pé)
        "character/imag_1_processed.png",
        "character/imag_2_processed.png",
        "character/imag_3_processed.png",
        "character/imag_6_processed.png" -- Final position to reset to standing
    }

    local character = display.newImageRect(characterFrames[2], 120, 140) -- Iniciar com imag_1
    character.x = display.contentCenterX
    character.y = screenBottom - 150                                     -- Initial position above ground level
    physics.addBody(character, "dynamic", { radius = 30, bounce = 0 })   -- Adiciona o corpo de física
    character.isFixedRotation = true                                     -- Prevent character from rotating
    character.weight = 66                                                -- Initial weight set to 66 kg

    -- Dentro da função de atualização ou pulo do personagem
    local function updatePosition()
        character.y = math.min(character.y, screenBottom - 150) -- Limite inferior
        character.y = math.max(character.y, screenTop + 150)    -- Limite superior
        character.x = math.max(screenLeft + 150, math.min(character.x, screenRight - 150))

        -- Se o personagem estiver no chão, mudar para imag_0 (posição de pé)
        if character.y >= screenBottom - 150 then
            character.fill = { type = "image", filename = characterFrames[1] } -- imag_0
        end
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
        -- Verifica se o character ainda tem um corpo de física antes de aplicar impulso
        if character and character.applyLinearImpulse then
            character:applyLinearImpulse(0, -2, character.x, character.y) -- Controlled jump impulse
        else
            print("Error: character does not have a physics body.")
        end
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
        -- Pausa a física do jogo
        physics.pause()

        -- Remove event listeners com verificação
        pcall(function() Runtime:removeEventListener("enterFrame", updatePosition) end)
        pcall(function() Runtime:removeEventListener("touch", onScreenTouch) end)
        pcall(function() character:removeEventListener("collision", onCollision) end)

        -- Remover elementos da tela
        display.remove(character)
        for i = 1, #upperObstacles do
            display.remove(upperObstacles[i])
        end
        for i = 1, #lowerObstacles do
            display.remove(lowerObstacles[i])
        end
        display.remove(background)
        display.remove(weightBar)
        display.remove(weightText)

        -- Reproduzir o vídeo de game over
        media.playVideo("gameOver/gameOverVideo.mp4", true, function(event)
            if event.completed or event.error then
                -- Mostrar mensagem e botões após o término do vídeo ou em caso de erro
                local tryAgainText = display.newText({
                    text = "Try again?",
                    x = display.contentCenterX,
                    y = display.contentCenterY - 50,
                    font = native.systemFontBold,
                    fontSize = 36
                })
                tryAgainText:setFillColor(1, 1, 1)

                -- Botão "Yes"
                local yesButton = display.newRect(display.contentCenterX - 60, display.contentCenterY + 50, 100, 50)
                yesButton:setFillColor(0.2, 0.8, 0.2)
                local yesText = display.newText({
                    text = "Yes",
                    x = yesButton.x,
                    y = yesButton.y,
                    font = native.systemFontBold,
                    fontSize = 24
                })

                -- Botão "No"
                local noButton = display.newRect(display.contentCenterX + 60, display.contentCenterY + 50, 100, 50)
                noButton:setFillColor(0.8, 0.2, 0.2)
                local noText = display.newText({
                    text = "No",
                    x = noButton.x,
                    y = noButton.y,
                    font = native.systemFontBold,
                    fontSize = 24
                })

                -- Ação para o botão "Yes"
                local function onYesButtonTap()
                    display.remove(tryAgainText)
                    display.remove(yesButton)
                    display.remove(yesText)
                    display.remove(noButton)
                    display.remove(noText)
                    -- Reinicia o jogo
                    physics.start()
                    startGame()
                end
                yesButton:addEventListener("tap", onYesButtonTap)

                -- Ação para o botão "No"
                local function onNoButtonTap()
                    native.requestExit() -- Fecha o aplicativo
                end
                noButton:addEventListener("tap", onNoButtonTap)
            end
        end)
    end

    local function updateWeight()
        if character.weight == nil then
            character.weight = 66 -- Define um valor padrão se estiver nil
        end

        weightBar.width = character.weight
        weightText.text = tostring(character.weight) .. " kg"

        if character.weight and character.weight >= 300 then
            gameOver()
        elseif character.weight > 100 or character.weight < 45 then
            weightBar:setFillColor(1, 0, 0)
            weightText:setFillColor(0, 0, 0)
        else
            weightBar:setFillColor(0, 1, 0)
            weightText:setFillColor(0, 0, 0)
        end
        print("Current weight: ", character.weight)
    end

    local function createObstacle(name, imgPath, carbs, yPosition, speed)
        local sizeScale = 70 + carbs * 0.5
        local obstacle = display.newImageRect(imgPath, sizeScale, sizeScale)

        if not obstacle then
            print("Error: obstacle creation failed for " .. name)
            return nil
        end

        obstacle.x = math.random(screenLeft + 30, screenRight - 30)
        obstacle.y = yPosition
        physics.addBody(obstacle, "static")
        obstacle.name = name
        obstacle.carbs = carbs

        local function moveObstacle()
            if obstacle and obstacle.x then -- Verifica se obstacle não é nil e tem a propriedade x
                if obstacle.x < screenLeft - 50 then
                    obstacle.x = screenRight + math.random(100, 200)
                else
                    obstacle.x = obstacle.x - speed
                end
            end
        end
        Runtime:addEventListener("enterFrame", moveObstacle)
        return obstacle
    end

    -- Criar obstáculos superiores e inferiores
    upperObstacles = {}
    lowerObstacles = {}

    local upperObstacleInfo = {
        { name = "crossfit",         path = "obstacles/crossfit.png",         carbs = 10 },
        { name = "run",              path = "obstacles/run.png",              carbs = 90 },
        { name = "barbecue_healthy", path = "obstacles/barbecue_healthy.png", carbs = 15 },
        { name = "strawberry",       path = "obstacles/strawberry.png",       carbs = 5 },
        { name = "eggplant",         path = "obstacles/eggplant.png",         carbs = 3 },
        { name = "gym",              path = "obstacles/gym.png",              carbs = 0 },
        { name = "meat",             path = "obstacles/meat.png",             carbs = 0 },
    }

    local lowerObstacleInfo = {
        { name = "bread",                path = "obstacles/bread.png",                carbs = 60 },
        { name = "rice",                 path = "obstacles/rice.png",                 carbs = 40 },
        { name = "noodle",               path = "obstacles/noodle.png",               carbs = 45 },
        { name = "estresse",             path = "obstacles/estresse.png",             carbs = 55 },
        { name = "work_a_lot",           path = "obstacles/work_a_lot.png",           carbs = 75 },
        { name = "ice_cream",            path = "obstacles/ice_cream.png",            carbs = 50 },
        { name = "sedentary_life_style", path = "obstacles/sedentary_life_style.png", carbs = 125 },
    }

    for _, info in ipairs(upperObstacleInfo) do
        local obstacle = createObstacle(info.name, info.path, info.carbs, screenTop + 450, 2)
        if obstacle then
            table.insert(upperObstacles, obstacle)
        end
    end

    for _, info in ipairs(lowerObstacleInfo) do
        local obstacle = createObstacle(info.name, info.path, info.carbs, screenBottom - 150, 1.5)
        if obstacle then
            table.insert(lowerObstacles, obstacle)
        end
    end

    local function onCollision(event)
        if event.phase == "began" and event.other and event.other.carbs ~= nil then
            if event.other.carbs > 20 then
                character.weight = (character.weight or 66) + 5
            else
                character.weight = (character.weight or 66) - 2
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
