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
local winnerMusic = audio.loadStream("winner/winner_song.mp3")

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

-- Variáveis globais
local startScreenGroup
local monthSquares = {}
local upperObstacles = {}
local lowerObstacles = {}
local character

-- Função para criar limites invisíveis nas bordas da tela
local function createBounds()
    local leftBound = display.newRect(screenLeft - 50, display.contentCenterY, 10, display.contentHeight)
    physics.addBody(leftBound, "static")

    local rightBound = display.newRect(screenRight + 50, display.contentCenterY, 10, display.contentHeight)
    physics.addBody(rightBound, "static")

    local ground = display.newRect(display.contentCenterX, screenBottom - 50, display.contentWidth, 20)
    physics.addBody(ground, "static")
    ground:setFillColor(0, 0, 0, 0)
end


-- Função para criar a tela inicial
local function createStartScreen()
    if background then
        display.remove(background)
        background = nil
    end

    background = display.newImageRect("background/background_5.jpg", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    startScreenGroup = display.newGroup()

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

    -- Adiciona o hover no botão
    local function onHover(event)
        if event.phase == "began" then
            startButton:setFillColor(0.2, 0.6, 0.2)
        elseif event.phase == "ended" then
            startButton:setFillColor(0.1, 0.5, 0.1)
        end
    end
    startButton:addEventListener("mouse", onHover)

    startButton:addEventListener("tap", startGame)
end

-- Função para criar a tela do tutorial
local function createTutorialScreen()
    if startScreenGroup then
        startScreenGroup:removeSelf()
        startScreenGroup = nil
    end

    local tutorialGroup = display.newGroup()

    local tutorialBackground = display.newRect(tutorialGroup, display.contentCenterX, display.contentCenterY,
        display.contentWidth, display.contentHeight)
    tutorialBackground:setFillColor(0.9, 0.9, 0.9)

    local tutorialTitle = display.newText({
        parent = tutorialGroup,
        text = "Tutorial",
        x = display.contentCenterX,
        y = display.contentHeight * 0.2,
        font = native.systemFontBold,
        fontSize = 36
    })
    tutorialTitle:setFillColor(0, 0, 0)

    local tutorialText = display.newText({
        parent = tutorialGroup,
        text =
        "Regras:\n- Pule os obstáculos ricos em carboidratos.\n- Colida com alimentos saudáveis para perder peso.\n- Evite ganhar peso acima de 300kg.\n- Evite perder peso abaixo de 45kg.\n- O personagem fica mais lento ao pular conforme ganha peso e mais rápido conforme perde peso.",
        x = display.contentCenterX,
        y = display.contentHeight * 0.5,
        width = display.contentWidth - 40,
        font = native.systemFont,
        fontSize = 20,
        align = "center"
    })
    tutorialText:setFillColor(0, 0, 0)

    local backButton = display.newRect(tutorialGroup, display.contentCenterX, display.contentHeight * 0.8, 200, 60)
    backButton:setFillColor(0.1, 0.5, 0.8)

    local backText = display.newText({
        parent = tutorialGroup,
        text = "Voltar",
        x = backButton.x,
        y = backButton.y,
        font = native.systemFontBold,
        fontSize = 24
    })
    backText:setFillColor(1, 1, 1)

    local function onBackButtonTap()
        tutorialGroup:removeSelf()
        createStartScreen()
    end
    backButton:addEventListener("tap", onBackButtonTap)
end

-- Função para criar a tela inicial
-- Função para criar a tela inicial
local function createStartScreen()
    if background then
        display.remove(background)
        background = nil
    end

    background = display.newImageRect("background/background_5.jpg", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    startScreenGroup = display.newGroup()

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

    -- Botão "Start"
    local startButton = display.newRect(display.contentCenterX, display.contentCenterY, 200, 60)
    startButton:setFillColor(0.1, 0.5, 0.1)
    startScreenGroup:insert(startButton)

    local startText = display.newText({
        text = "Start",
        x = startButton.x,
        y = startButton.y,
        font = native.systemFontBold,
        fontSize = 30
    })
    startText:setFillColor(1, 1, 1)
    startScreenGroup:insert(startText)

    -- Botão "Tutorial" (cor amarela)
    local tutorialButton = display.newRect(display.contentCenterX, display.contentCenterY + 100, 200, 60)
    tutorialButton:setFillColor(1, 1, 0) -- Amarelo
    startScreenGroup:insert(tutorialButton)

    local tutorialText = display.newText({
        text = "Tutorial",
        x = tutorialButton.x,
        y = tutorialButton.y,
        font = native.systemFontBold,
        fontSize = 30
    })
    tutorialText:setFillColor(0, 0, 0) -- Preto para contraste
    startScreenGroup:insert(tutorialText)

    -- Função do botão "Start"
    local function onStartButtonTap()
        startScreenGroup:removeSelf()
        startScreenGroup = nil
        startGame()
    end
    startButton:addEventListener("tap", onStartButtonTap)

    -- Função do botão "Tutorial"
    local function onTutorialButtonTap()
        startScreenGroup:removeSelf()
        startScreenGroup = nil
        createTutorialScreen() -- Chama a tela do tutorial
    end
    tutorialButton:addEventListener("tap", onTutorialButtonTap)
end


-- Inicializa a tela inicial
--createStartScreen()


-- Função de Game Over
function gameOver()
    physics.pause()
    audio.stop()
    playGameOverMusic()
    display.remove(character)

    local gameOverImage = display.newImageRect("gameOver/gameOver.jpeg", display.contentWidth, display.contentHeight)
    gameOverImage.x = display.contentCenterX
    gameOverImage.y = display.contentCenterY

    local yesButton = display.newRect(display.contentWidth * 0.15, display.contentHeight * 0.4, 160, 70)
    yesButton:setFillColor(0.3, 0.9, 0.3)
    local yesText = display.newText({
        text = "Yes",
        x = yesButton.x,
        y = yesButton.y,
        font = native.systemFontBold,
        fontSize = 28
    })

    local noButton = display.newRect(display.contentWidth * 0.4, display.contentHeight * 0.4, 160, 70)
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

function winner()
    physics.pause()
    audio.stop()
    playWinnerMusic()

    local winnerScreen = display.newImageRect("winner/winner.jpeg", display.contentWidth, display.contentHeight)
    winnerScreen.x = display.contentCenterX
    winnerScreen.y = display.contentCenterY

    -- Texto "Try Again?" posicionado mais abaixo
    local tryAgainText = display.newText({
        text = "Try Again?",
        -- = display.contentCenterX,
        -- y = display.contentHeight * 100, -- Ajustado para ficar mais abaixo
        -- font = native.systemFontBold,
        x = display.contentWidth * 0.25,  -- Ajustado para a esquerda
        y = display.contentHeight * 0.75, -- Mantido centralizado verticalmente
        font = native.systemFontBold,
        fontSize = 32
    })
    tryAgainText:setFillColor(0, 0, 0) -- Cor preta para contraste

    -- Botões "Yes" e "No" mais próximos um do outro
    --local yesButton = display.newRect(display.contentCenterX - 150, display.contentHeight * 0.85, 160, 70) -- Ajustado para a esquerda
    local yesButton = display.newRect(display.contentWidth * 0.15, display.contentHeight * 0.85, 160, 70)


    yesButton:setFillColor(0.3, 0.9, 0.3)
    local yesText = display.newText({
        text = "Yes",
        x = yesButton.x,
        y = yesButton.y,
        font = native.systemFontBold,
        fontSize = 28
    })

    --local noButton = display.newRect(display.contentCenterX + 50, display.contentHeight * 0.85, 160, 70) -- Ajustado para a direita
    local noButton = display.newRect(display.contentWidth * 0.35, display.contentHeight * 0.85, 150, 60)

    noButton:setFillColor(0.9, 0.3, 0.3)
    local noText = display.newText({
        text = "No",
        x = noButton.x,
        y = noButton.y,
        font = native.systemFontBold,
        fontSize = 28
    })
    -- Função para criar partículas de glitter/confete
    -- Garantir compatibilidade com Lua 5.1 ou LuaJIT
    local unpack = unpack or table.unpack -- Define `unpack` como `table.unpack` para versões modernas

    -- Função para criar partículas de glitter/confete
    local function createConfetti()
        local colors = { { 1, 0, 0 }, { 0, 1, 0 }, { 0, 0, 1 }, { 1, 1, 0 }, { 1, 0, 1 }, { 0, 1, 1 } }
        local glitter = display.newCircle(math.random(screenLeft, screenRight), -50, math.random(3, 6))
        glitter:setFillColor(unpack(colors[math.random(#colors)])) -- Aqui usamos `unpack` compatível com a versão

        physics.addBody(glitter, "dynamic", { radius = glitter.path.radius, bounce = 0.3, density = 0.1 })
        glitter:applyLinearImpulse(math.random(-2, 2) * 0.1, math.random(2, 5) * 0.1, glitter.x, glitter.y)

        -- Remove o glitter após sair da tela
        local function removeGlitter()
            display.remove(glitter)
            glitter = nil
        end
        timer.performWithDelay(3000, removeGlitter)
    end


    -- Criar glitter continuamente por um tempo
    timer.performWithDelay(100, createConfetti, 100)
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

-- Função de início do jogo
function startGame()
    if startScreenGroup then
        startScreenGroup:removeSelf()
        startScreenGroup = nil
    end

    audio.stop()
    playGameMusic()

    local characterFrames = {
        "character/imag_0_processed.png",
        "character/imag_1_processed.png",
        "character/imag_2_processed.png",
        "character/imag_3_processed.png",
        "character/imag_4_processed.png",
        "character/imag_5_processed.png",
        "character/imag_6_processed.png"
    }

    character = display.newImageRect(characterFrames[1], 120, 140)
    character.x = display.contentCenterX
    character.y = screenBottom - 120 -- Ajustado para ficar na mesma linha dos obstáculos inferiores
    physics.addBody(character, "dynamic", { radius = 30, bounce = 0 })
    character.isFixedRotation = true
    character.weight = 60

    createBounds()

    -- Adiciona os quadrados dos meses
    for i = 1, 9 do
        local square = display.newRect(display.contentCenterX - 220 + (i * 50), 120, 40, 40)
        square:setFillColor(1, 1, 1)
        square.strokeWidth = 2
        square:setStrokeColor(0, 0, 0)
        monthSquares[i] = square
    end

    local currentMonth = 1
    local winnerAchieved = true

    local function updateMonth()
        if currentMonth <= 9 then
            if character.weight >= 52 and character.weight <= 72 then
                monthSquares[currentMonth]:setFillColor(0, 1, 0)
            else
                monthSquares[currentMonth]:setFillColor(1, 0, 0)
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

    timer.performWithDelay(5000, updateMonth, 9)

    -- Atualização da posição do personagem
    local function updatePosition()
        if character.x then
            character.x = math.max(screenLeft + 30, math.min(character.x, screenRight - 30))
        end
        if character.y and character.y < screenTop + 450 then
            character:setLinearVelocity(0, 50)
        end
    end
    Runtime:addEventListener("enterFrame", updatePosition)

    local jumpIndex = 1

    local function characterJump()
        jumpIndex = jumpIndex + 1
        if jumpIndex > #characterFrames then
            jumpIndex = 2
        end
        character.fill = { type = "image", filename = characterFrames[jumpIndex] }

        if character and character.applyLinearImpulse then
            local _, velocityY = character:getLinearVelocity()
            if character.y > (screenTop + 450) and velocityY >= 0 then
                character:applyLinearImpulse(0, -2, character.x, character.y)
            end
        end
    end

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
    -- Mantém os obstáculos inferiores e superiores e a lógica de colisão
    local function createObstacle(name, imgPath, carbs, yPosition, speed)
        local sizeScale = (name == "sedentary_life_style") and 200 or 90 + carbs * 0.5
        local obstacle = display.newImageRect(imgPath, sizeScale, sizeScale)

        obstacle.x = math.random(screenLeft + 50, screenRight - 50)
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

    local upperObstacleInfo = {
        { name = "crossfit",   path = "obstacles/crossfit.png",   carbs = 0 },
        { name = "run",        path = "obstacles/run.png",        carbs = 0 },
        { name = "strawberry", path = "obstacles/strawberry.png", carbs = 7.7 },
    }

    local lowerObstacleInfo = {
        { name = "bread", path = "obstacles/bread.png", carbs = 49 },
        { name = "rice",  path = "obstacles/rice.png",  carbs = 28 },
    }

    for i, info in ipairs(upperObstacleInfo) do
        local obstacle = createObstacle(info.name, info.path, info.carbs, screenTop + 450, 2)
        table.insert(upperObstacles, obstacle)
    end

    for i, info in ipairs(lowerObstacleInfo) do
        local obstacle = createObstacle(info.name, info.path, info.carbs, screenBottom - 120, 1.5)
        table.insert(lowerObstacles, obstacle)
    end

    local function updateWeight()
        weightBar.width = character.weight
        weightText.text = tostring(character.weight) .. " kg"

        if character.weight <= 52 or character.weight >= 300 then
            gameOver()
        else
            if character.weight > 100 then
                weightBar:setFillColor(1, 0, 0)
            else
                weightBar:setFillColor(0, 1, 0)
            end
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

createStartScreen()
