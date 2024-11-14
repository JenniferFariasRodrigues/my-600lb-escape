-- Main.lua file for the game 'My 600-lb Escape'
display.setStatusBar(display.HiddenStatusBar)

-- Initialize physics
local physics = require("physics")
physics.start()
physics.setGravity(0, 9.8)

-- Load audio library
local audio = require("audio")

-- Load the background music
local startMusic = audio.loadStream("audio/start_music.mp3")
local gameMusic = audio.loadStream("audio/game_music.mp3")
local gameOverMusic = audio.loadStream("audio/game_over_song.mp3")
local winnerMusic = audio.loadStream("winner/winner_song.mp3") -- Adicionado música de vencedor

-- Function to play music at the start screen
local function playStartMusic()
    audio.play(startMusic, { loops = -1 })
end

-- Function to play game music
local function playGameMusic()
    audio.play(gameMusic, { loops = -1 })
end

-- Function to play game over music
local function playGameOverMusic()
    audio.play(gameOverMusic, { loops = 0 })
end

-- Function to play winner music
local function playWinnerMusic()
    audio.play(winnerMusic, { loops = 0 })
end

-- Screen boundaries
local screenLeft = display.screenOriginX
local screenRight = display.contentWidth - display.screenOriginX
local screenBottom = display.contentHeight - display.screenOriginY
local screenTop = display.screenOriginY

-- Load and set background image
local background = display.newImageRect("background/background_5.jpg", display.contentWidth, display.contentHeight)
background.x = display.contentCenterX
background.y = display.contentCenterY

-- Variável global para a tela inicial
local startScreenGroup
local monthSquares = {} -- Barra de progresso para 9 meses

local function createStartScreen()
    -- Remove o background anterior, caso ele ainda esteja na tela
    if background then
        display.remove(background)
        background = nil
    end

    -- Recria o fundo quando a tela de início for exibida
    background = display.newImageRect("background/background_5.jpg", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    background.isVisible = true -- Garanta que o fundo esteja visível

    -- Continue com o resto da criação da tela inicial
    startScreenGroup = display.newGroup()

    -- Play the background music when the start screen is created
    playStartMusic()

    local titleText = display.newText({
        text = "My 600-lb Escape",
        x = display.contentCenterX,
        y = display.contentCenterY - 300,
        font = native.systemFontBold,
        fontSize = 40
    })
    titleText:setFillColor(0, 0, 0)
    startScreenGroup:insert(titleText)

    local rulesText = display.newText({
        text =
        "Regras:\n- Pule os obstáculos ricos em carboidratos.\n- Colida com alimentos saudáveis para perder peso.\n- Evite ganhar peso acima de 300kg.\n- Evite perder peso abaixo de 45kg.\n- O personagem fica mais lento ao pular conforme ganha peso e mais rápido conforme perde peso.",
        x = display.contentCenterX,
        y = display.contentCenterY - 150,
        width = display.contentWidth - 140,
        font = native.systemFont,
        fontSize = 20,
        align = "center"
    })
    rulesText:setFillColor(0, 0, 0)
    startScreenGroup:insert(rulesText)

    -- Criação do botão de início com aumento de tamanho
    local startButton = display.newRect(display.contentCenterX, display.contentCenterY, 200, 60)
    startButton:setFillColor(0.1, 0.5, 0.1)
    startScreenGroup:insert(startButton)

    local buttonText = display.newText({
        text = "Start",
        x = startButton.x,
        y = startButton.y,
        font = native.systemFontBold,
        fontSize = 30
    })
    buttonText:setFillColor(1, 1, 1)
    startScreenGroup:insert(buttonText)

    -- Efeito hover no botão
    local function onHover(event)
        if event.phase == "began" then
            startButton:setFillColor(0.2, 0.6, 0.2)
        elseif event.phase == "ended" then
            startButton:setFillColor(0.1, 0.5, 0.1)
        end
    end
    startButton:addEventListener("mouse", onHover)

    -- Listener para o botão de início
    startButton:addEventListener("tap", startGame)
end

-- Função para iniciar o jogo
function startGame()
    if startScreenGroup then
        startScreenGroup:removeSelf() -- Remove a tela de início se ela já existir
        startScreenGroup = nil
    end

    -- Parar a música de fundo e iniciar a música do jogo
    audio.stop()
    playGameMusic()

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
    character.weight = 60                                                -- Initial weight set to 60 kg

    -- Inicializa a barra de 9 meses
    for i = 1, 9 do
        local square = display.newRect(display.contentCenterX - 220 + (i * 50), 120, 40, 40)
        square:setFillColor(1, 1, 1)
        square.strokeWidth = 2
        square:setStrokeColor(0, 0, 0)
        monthSquares[i] = square
    end

    local currentMonth = 1
    local winnerAchieved = true

    -- Função para atualizar a barra de progresso
    local function updateMonth()
        if currentMonth <= 9 then
            if character.weight >= 52 and character.weight <= 72 then
                monthSquares[currentMonth]:setFillColor(0, 1, 0) -- Verde
            else
                monthSquares[currentMonth]:setFillColor(1, 0, 0) -- Vermelho
                winnerAchieved = false
            end
            currentMonth = currentMonth + 1

            if currentMonth > 9 then
                if winnerAchieved then
                    winner()
                else
                    gameOver()
                end
            end
        end
    end

    timer.performWithDelay(5000, updateMonth, 9) -- Atualiza a cada 5 segundos

    local weightBar = display.newRect(display.contentCenterX, 60, character.weight, 20)
    weightBar:setFillColor(0, 1, 0)

    local weightText = display.newText({
        text = tostring(character.weight) .. " kg",
        x = display.contentCenterX,
        y = 60,
        font = native.systemFontBold,
        fontSize = 16
    })
    weightText:setFillColor(0, 0, 0)

    -- Função de atualização da posição do personagem
    local function updatePosition()
        local alturaMaximaPermitida = screenTop + 450 -- Limite superior para a altura do pulo
        if character and character.getLinearVelocity then
            local _, velocityY = character:getLinearVelocity()

            if character.y <= alturaMaximaPermitida and velocityY <= 0 then
                character:setLinearVelocity(0, 50)
            end

            -- Limite inferior para evitar que o personagem caia fora da tela
            character.y = math.min(character.y, screenBottom - 150)

            -- Limites laterais para impedir que o personagem saia da tela
            character.x = math.max(screenLeft + 150, math.min(character.x, screenRight - 150))

            -- Se o personagem estiver no chão, mudar para imag_0 (posição de pé)
            if character.y >= screenBottom - 150 then
                character.fill = { type = "image", filename = characterFrames[1] } -- imag_0
            end
        end
    end

    Runtime:addEventListener("enterFrame", updatePosition)

    -- Função para atualizar o peso
    local function updateWeight()
        weightBar.width = character.weight
        weightText.text = tostring(character.weight) .. " kg"

        if character.weight <= 45 or character.weight >= 300 then
            gameOver()
        else
            if character.weight > 100 then
                weightBar:setFillColor(1, 0, 0)
            else
                weightBar:setFillColor(0, 1, 0)
            end
        end
    end

    -- Função para criar obstáculos
    local function createObstacle(name, imgPath, carbs, yPosition, speed)
        local sizeScale = (name == "sedentary_life_style") and 200 or 90 + carbs * 0.5
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
            if obstacle.x < screenLeft - 50 then
                obstacle.x = screenRight + math.random(100, 200)
            else
                obstacle.x = obstacle.x - speed
            end
        end
        Runtime:addEventListener("enterFrame", moveObstacle)
        return obstacle
    end

    upperObstacles = {}
    lowerObstacles = {}

    local upperObstacleInfo = {
        { name = "crossfit",         path = "obstacles/crossfit.png",         carbs = 0 },
        { name = "run",              path = "obstacles/run.png",              carbs = 0 },
        { name = "barbecue_healthy", path = "obstacles/barbecue_healthy.png", carbs = 0 },
        { name = "strawberry",       path = "obstacles/strawberry.png",       carbs = 7.7 },
        { name = "eggplant",         path = "obstacles/eggplant.png",         carbs = 5.9 },
        { name = "gym",              path = "obstacles/gym.png",              carbs = 0 },
        { name = "meat",             path = "obstacles/meat.png",             carbs = 0 },
    }

    local lowerObstacleInfo = {
        { name = "bread",                path = "obstacles/bread.png",                carbs = 49 },
        { name = "rice",                 path = "obstacles/rice.png",                 carbs = 28 },
        { name = "noodle",               path = "obstacles/noodle.png",               carbs = 25 },
        { name = "estresse",             path = "obstacles/estresse.png",             carbs = 0 },
        { name = "work_a_lot",           path = "obstacles/work_a_lot.png",           carbs = 0 },
        { name = "ice_cream",            path = "obstacles/ice_cream.png",            carbs = 23 },
        { name = "sedentary_life_style", path = "obstacles/sedentary_life_style.png", carbs = 0 },
    }

    local obstacleSpacing = 350
    local availablePositions = {}

    for i = 1, #upperObstacleInfo + #lowerObstacleInfo do
        table.insert(availablePositions, screenLeft + (i - 1) * obstacleSpacing + 200)
    end

    local function getRandomPosition()
        if #availablePositions > 0 then
            local index = math.random(1, #availablePositions)
            return table.remove(availablePositions, index)
        end
        return screenLeft + math.random(screenRight - screenLeft)
    end

    for i, info in ipairs(upperObstacleInfo) do
        local obstacle = createObstacle(info.name, info.path, info.carbs, screenTop + 450, 2)
        if obstacle then
            obstacle.x = getRandomPosition()
            table.insert(upperObstacles, obstacle)
        end
    end

    for i, info in ipairs(lowerObstacleInfo) do
        local obstacle = createObstacle(info.name, info.path, info.carbs, screenBottom - 150, 1.5)
        if obstacle then
            obstacle.x = getRandomPosition()
            table.insert(lowerObstacles, obstacle)
        end
    end

    -- Função de colisão
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

    -- Função para detectar toque na tela para pular
    local function onScreenTouch(event)
        if event.phase == "began" then
            if character and character.applyLinearImpulse then
                local velocityX, velocityY = character:getLinearVelocity()
                if velocityX ~= nil and velocityY ~= nil then
                    if character.y > (screenTop + 450) and velocityY >= 0 then
                        character:applyLinearImpulse(0, -2, character.x, character.y)
                    end
                end
            end
        end
    end
    Runtime:addEventListener("touch", onScreenTouch)
end

-- Função de Game Over
function gameOver()
    physics.pause()
    audio.stop()
    playGameOverMusic()
    display.remove(character)

    local gameOverImage = display.newImageRect("gameOver/gameOver.jpeg", display.contentWidth, display.contentHeight)
    gameOverImage.x = display.contentCenterX
    gameOverImage.y = display.contentCenterY

    local yesButton = display.newRect(display.contentWidth * 0.15, display.contentHeight * 0.75, 160, 70)
    yesButton:setFillColor(0.3, 0.9, 0.3)
    local yesText = display.newText({
        text = "Yes",
        x = yesButton.x,
        y = yesButton.y,
        font = native.systemFontBold,
        fontSize = 28
    })

    local noButton = display.newRect(display.contentWidth * 0.4, display.contentHeight * 0.75, 160, 70)
    noButton:setFillColor(0.9, 0.3, 0.3)
    local noText = display.newText({
        text = "No",
        x = noButton.x,
        y = noButton.y,
        font = native.systemFontBold,
        fontSize = 28
    })

    local function onYesButtonTap()
        display.remove(gameOverImage)
        display.remove(yesButton)
        display.remove(yesText)
        display.remove(noButton)
        display.remove(noText)
        physics.start()
        createStartScreen()
    end
    yesButton:addEventListener("tap", onYesButtonTap)

    local function onNoButtonTap()
        print("Jogo encerrado.")
        native.requestExit()
    end
    noButton:addEventListener("tap", onNoButtonTap)
end

-- Função Winner
-- Função Winner
function winner()
    physics.pause()
    audio.stop()
    playWinnerMusic()

    local winnerScreen = display.newImageRect("winner/winner.jpeg", display.contentWidth, display.contentHeight)
    winnerScreen.x = display.contentCenterX
    winnerScreen.y = display.contentCenterY

    -- Texto "Try Again?" posicionado acima dos botões
    local tryAgainText = display.newText({
        text = "Try Again?",
        x = display.contentCenterX,
        y = display.contentHeight * 0.6, -- Ajustado para aparecer acima dos botões
        font = native.systemFontBold,
        fontSize = 32
    })
    tryAgainText:setFillColor(0, 0, 0) -- Cor preta para contraste

    -- Opções de reiniciar ou sair, ajustadas para posição mais baixa
    local yesButton = display.newRect(display.contentWidth * 0.3, display.contentHeight * 0.75, 160, 70) -- Posição ajustada
    yesButton:setFillColor(0.3, 0.9, 0.3)
    local yesText = display.newText({
        text = "Yes",
        x = yesButton.x,
        y = yesButton.y,
        font = native.systemFontBold,
        fontSize = 28
    })

    local noButton = display.newRect(display.contentWidth * 0.7, display.contentHeight * 0.75, 160, 70) -- Posição ajustada
    noButton:setFillColor(0.9, 0.3, 0.3)
    local noText = display.newText({
        text = "No",
        x = noButton.x,
        y = noButton.y,
        font = native.systemFontBold,
        fontSize = 28
    })

    local function onYesButtonTap()
        display.remove(winnerScreen)
        display.remove(tryAgainText)
        display.remove(yesButton)
        display.remove(yesText)
        display.remove(noButton)
        display.remove(noText)
        physics.start()
        createStartScreen()
    end
    yesButton:addEventListener("tap", onYesButtonTap)

    local function onNoButtonTap()
        print("Jogo encerrado.")
        native.requestExit()
    end
    noButton:addEventListener("tap", onNoButtonTap)
end

createStartScreen()
