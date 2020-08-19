local imgui = require "imgui"

local tween = require "tween"

local gr = love.graphics
local progs = {}

function findShaders()
    local files = love.filesystem.getDirectoryItems("")
    local filteredFiles = {}
    for k, v in pairs(files) do
        if v:match(".*%.glsl") then
            table.insert(progs, gr.newShader(v))
            table.insert(filteredFiles, v)
        end
    end
    return filteredFiles
end

love.load = function()
    files = findShaders()
end

local img = gr.newImage("pic1.png")

local twObject = { qTime = 0.5 }
local tw = tween.new(30., twObject, { qTime = 1 }, "outBounce")

local w, h = gr.getDimensions()
local vertices = {
    {
        0, 0,
        0, 0,
        1, 1, 1, 1
    },
    {
        w, h,
        0, 0,
        1, 1, 1, 1
    },
    {
        0, h,
        0, 0,
        1, 1, 1, 1
    },

    {
        w, h,
        0, 0,
        1, 1, 1, 1
    },
    {
        w, 0,
        0, 0,
        1, 1, 1, 1
    },
    {
        0, 0,
        0, 0,
        1, 1, 1, 1
    },
}
local mesh = gr.newMesh(vertices, "triangles", "static")

local iCount = 10.

local currentShader

function safesend(shader, name, ...)
    if shader:hasUniform(name) then
        shader:send(name, ...)
    end
end

local selectedFile = 1

love.draw = function()
    gr.setColor{1, 1, 1, 1}
    --gr.clear(1, 1, 1)
    local w, h = gr.getDimensions()

    --gr.setShader(sh1)
    --gr.rectangle("fill", 0, 0, w, h)

    --gr.setShader(sh2)
    

    mesh:setTexture(img)
    local mx, my = love.mouse.getPosition()
    if currentShader then
        safesend(currentShader, "iTime", love.timer.getTime())
        safesend(currentShader, "qTime", twObject.qTime)
        safesend(currentShader, "iTex", img)
        safesend(currentShader, "iCount", iCount)
        safesend(currentShader, "iResolution", {w, h})
        safesend(currentShader, "iMouse", {mx, my})

        gr.setShader(currentShader);
    end
    gr.draw(mesh)
    gr.setShader()

    gr.setColor(0, 0, 1)
    gr.print(string.format("fps %d", love.timer.getFPS()), 0, 0)

    imgui.Begin("programs")
    local num, selected = imgui.ListBox("programs", selectedFile, files, #files, 5)
    if selected then
        selectedFile = num
        currentShader = progs[selectedFile]
    end
    imgui.End()
    imgui.Render()
end

love.update = function(dt)
    imgui.NewFrame()
    print("twObject.qTime", twObject.qTime)
    tw:update(dt)
    local lk = love.keyboard
    if lk.isDown("z") then
        iCount = iCount + .1
    elseif lk.isDown("x") then
        iCount = iCount - .1
    end
end

function love.textinput(t)
   imgui.TextInput(t)
   if not imgui.GetWantCaptureKeyboard() then
       -- Pass event to the game
   end
end

function love.keypressed(_, key)
   imgui.KeyPressed(key)
   if not imgui.GetWantCaptureKeyboard() then
       tw = tween.new(30., twObject, { qTime = 1 }, "outBounce")
       if key == "a" then
           safesend(currentShader, "useFast", true)
       elseif key == "z" then
           safesend(currentShader, "useFast", false)
       end
       -- Pass event to the game
   end
end

function love.keyreleased(key)
   imgui.KeyReleased(key)
   if not imgui.GetWantCaptureKeyboard() then
       -- Pass event to the game
   end
end

function love.mousemoved(x, y)
   imgui.MouseMoved(x, y)
   if not imgui.GetWantCaptureMouse() then
       -- Pass event to the game
   end
end

function love.mousepressed(x, y, button)
   imgui.MousePressed(button)
   if not imgui.GetWantCaptureMouse() then
       -- Pass event to the game
   end
end

function love.mousereleased(x, y, button)
   imgui.MouseReleased(button)
   if not imgui.GetWantCaptureMouse() then
       -- Pass event to the game
   end
end

function love.wheelmoved(x, y)
   imgui.WheelMoved(y)
   if not imgui.GetWantCaptureMouse() then
       -- Pass event to the game
   end
end

