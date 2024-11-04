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
-- background.x = display.contentCenterX
-- background.y = display.contentCenterY
if background then
    background.x = display.contentCenterX
    background.y = display.contentCenterY
else
    print("Warning: Background image not found. Using default gray color.")
    background = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth,
        display.contentHeight)
    background:setFillColor(0.5) -- Set gray background
end

-- Load character jump images and initial setup
local characterFrames = {
    "character/imag_0_processed.png",
    "character/imag_1_processed.png",
    "character/imag_2_processed.png",
    "character/imag_3_processed.png",
    "character/imag_6_processed.png" -- Final position to reset to standing
}

-- Check if character frames are loading correctly
local character = display.newImageRect(characterFrames[1], 120, 140) -- Increased size for visibility
-- Dentro da função de atualização ou pulo do personagem
local function updatePosition()
    -- Limite vertical para o pulo, para que o personagem não saia do topo da tela
    character.y = math.min(character.y, screenBottom - 150) -- Limite inferior
    character.y = math.max(character.y, screenTop + 150)    -- Limite superior

    -- Limite horizontal, caso necessário
    character.x = math.max(screenLeft + 150, math.min(character.x, screenRight - 150))
end

-- Adicione `updatePosition()` na função de pulo ou na função de quadro para restringir a posição a cada atualização
Runtime:addEventListener("enterFrame", updatePosition)

if character then
    character.x = display.contentCenterX
    character.y = screenBottom - 150 -- Initial position above ground level
    physics.addBody(character, "dynamic", { radius = 30, bounce = 0 })
    character.isFixedRotation = true -- Prevent character from rotating
    character.weight = 98            -- Initial weight based on BMI
else
    print("Warning: Character images not found. Placeholder created.")
    character = display.newRect(display.contentCenterX, screenBottom - 150, 120, 140)
    character:setFillColor(1, 0, 0) -- Set red for visibility
    physics.addBody(character, "dynamic", { radius = 30, bounce = 0 })
end

-- Jump handling with specific sequences
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

-- Define weight bar and update dynamically
local weightBar = display.newRect(display.contentCenterX, 20, character.weight, 20) -- Scaling bar size
weightBar:setFillColor(0, 1, 0)

-- Function to update weight bar with debug print
local function updateWeight()
    weightBar.width = character.weight
    if character.weight >= 300 then
        print("Game Over: Weight reached 300kg")
    elseif character.weight < 200 then
        character.weight = 200 -- Minimum weight to prevent invisible bar
    end
    print("Current weight: ", character.weight)
end

-- Adding obstacles with automatic movement and carb-based scaling
local function createObstacle(name, imgPath, carbs, yPosition, speed)
    local sizeScale = 50 + carbs * 0.5
    local obstacle = display.newImageRect(imgPath, sizeScale, sizeScale)
    obstacle.x = math.random(screenLeft + 50, screenRight - 50)
    obstacle.y = yPosition
    physics.addBody(obstacle, "static")
    obstacle.name = name
    obstacle.carbs = carbs

    -- Move obstacle across screen
    local function moveObstacle()
        if obstacle.x < screenLeft - 50 then
            obstacle.x = screenRight + 50   -- Wrap around
        else
            obstacle.x = obstacle.x - speed -- Move left
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
    { name = "estresse",             path = "obstacles/estresse.png",             carbs = 35 },
    { name = "work_a_lot",           path = "obstacles/work_a_lot.png",           carbs = 125 },
    { name = "ice_cream",            path = "obstacles/ice_cream.png",            carbs = 75 },
    { name = "sedentary_life_style", path = "obstacles/sedentary_life_style.png", carbs = 225 },

}

-- Place upper and lower obstacles
for _, info in ipairs(upperObstacles) do
    createObstacle(info.name, info.path, info.carbs, screenTop + 450, 2)
end
for _, info in ipairs(lowerObstacles) do
    createObstacle(info.name, info.path, info.carbs, screenBottom - 150, 1.5)
end

-- Collision handling to adjust weight
local function onCollision(event)
    if event.phase == "began" and event.other.carbs ~= nil then
        if event.other.carbs > 20 then
            character.weight = character.weight + 5
            weightBar:setFillColor(1, 0, 0)
        else
            character.weight = character.weight - 2
            weightBar:setFillColor(0, 1, 0)
        end
        updateWeight()
    end
end
character:addEventListener("collision", onCollision)

-- Trigger jump on touch
local function onScreenTouch(event)
    if event.phase == "began" then
        characterJump()
    end
end
Runtime:addEventListener("touch", onScreenTouch)
