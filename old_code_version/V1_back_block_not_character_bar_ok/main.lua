
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

-- Load and set background image
local background = display.newImageRect("background/background.jpg", display.contentWidth, display.contentHeight)
background.x = display.contentCenterX
background.y = display.contentCenterY

-- Load character jump images
local characterFrames = {
    "character/imag_0_processed.png",
    "character/imag_1_processed.png",
    "character/imag_2_processed.png",
    "character/imag_3_processed.png",
    "character/imag_4_processed.png",
    "character/imag_5_processed.png",
    "character/imag_6_processed.png"
}

-- Setup character sprite for jumping
local character = display.newImageRect(characterFrames[1], 100, 120)  -- Increased initial size
character.x = display.contentCenterX
character.y = display.contentCenterY + 200
physics.addBody(character, "dynamic", {radius=30})
character.weight = 200  -- Initial weight based on BMI

-- Define jump sequence
local jumpIndex = 1
local function characterJump()
    jumpIndex = jumpIndex + 1
    if jumpIndex > #characterFrames then jumpIndex = 1 end
    character.fill = { type="image", filename=characterFrames[jumpIndex] }
    character:applyLinearImpulse(0, -1.2, character.x, character.y)  -- Reduced impulse to prevent leaving screen
end

-- Define weight bar
local weightBar = display.newRect(display.contentCenterX, 20, character.weight / 3, 20)  -- Scaling bar size
weightBar:setFillColor(0, 1, 0)

-- Adding obstacles dynamically with carb-based scaling
local obstacles = {
    {name = "bread", img = "obstacles/bread.png", carbs = 60},
    {name = "rice", img = "obstacles/rice.png", carbs = 40},
    {name = "oat", img = "obstacles/oat.png", carbs = 50},
    {name = "meat", img = "obstacles/meat.png", carbs = 0},
    {name = "crossfit", img = "obstacles/crossfit.png", carbs = 0},
    {name = "strawberry", img = "obstacles/strawberry.png", carbs = 5},
}

for _, obs in ipairs(obstacles) do
    local sizeScale = 50 + obs.carbs * 0.5
    local obstacle = display.newImageRect(obs.img, sizeScale, sizeScale)
    obstacle.x = math.random(screenLeft + 50, screenRight - 50)
    obstacle.y = math.random(screenBottom - 300, screenBottom - 50)  -- Randomize vertical positioning
    physics.addBody(obstacle, "static")
    obstacle.name = obs.name
    obstacle.carbs = obs.carbs
end

-- Update weight bar and game over check
local function updateWeight()
    weightBar.width = character.weight / 3
    if character.weight >= 300 then
        print("Game Over: Weight reached 300kg")
    end
end

-- Character movement and collision handling
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
