local gr = love.graphics
local sh1 = gr.newShader([[
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    //vec4 texturecolor = Texel(tex, texture_coords);
    //return texturecolor * color;
    vec2 uv = screen_coords / love_ScreenSize.xy;
    vec3 col = vec3(0.1);
    float m = smoothstep(0.4, 0.6, uv.x);
    col += m;
    return vec4(col, 1.0);
}
]])
local sh2 = gr.newShader([[
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    //vec4 texturecolor = Texel(tex, texture_coords);
    //return texturecolor * color;
    vec2 uv = screen_coords / love_ScreenSize.xy;
    vec3 col = vec3(0.1);

    float d = 0.1;
    float m;

    //col += smoothstep(d, d + 0.1, uv.y) + smoothstep((0.8), (0.8) + 0.4, uv.y);

    //m = smoothstep(d, d + 0.1, uv.x);
    //col += m;

    d = 0.8;
    m = smoothstep(d, d + 0.1, uv.x);
    col += m;


    return vec4(col, 1.0);
}
]])

local sh3 = gr.newShader([[
uniform float iTime;
uniform float iCount;
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = screen_coords / love_ScreenSize.xy;
    vec3 col = vec3(0.5);
    vec2 gv = fract(uv * iCount) - .5;
    //float d = length(gv);
    float m = 0.;

    for (float y = -1.; y <= 1.; y++) {
        for (float x = -1.; x <= 1.; x++) {
            vec2 offs = vec2(x, y);
            float d = length(gv + offs);
            //float r = 0.1;
            //m += smoothstep(r, r * 0.9, d);
            float r = mix(0.3, 0.5, sin(iTime + length(uv) * 39.) * 0.5 + 0.5);
            m += smoothstep(r, r * 0.9, d);
        }
    }

    col.rg = gv;
    col += m;
    //col += smoothstep(0.1, 0.11, uv.x);
    return vec4(col, 1.0);
}
]])

local sh4 = gr.newShader([[
    #define S smoothstep

    float Feather(vec2 p) {
        //float d = length(p - vec2(clamp(p.x, -0., .3), clamp(p.y, -0., 0.3)));
        float d = length(p - vec2(0., clamp(p.y, -0.35, 0.35)));
        float r = mix(.1, .01, S(-0.3, .3, p.y));
        float m = S(.001, .0, d - r);
        float x = .9 * abs(p.x)/r;
        float wave = (1. - x) * sqrt(x) + x * (1. - sqrt(1.-x));
        float y = (p.y - wave*.2) * 40.;
        float id = floor(y);
        float n = fract(sin(id*564.)*845.);
        float shade = mix(.3, .1, n);

        float strand = S(.1, 0., abs(fract(y) - .5) - .3);

        d = length(p - vec2(0., clamp(p.y, -0.45, 0.1)));
        float stem = S(.01, .0, d);

        return strand * m * shade + stem;
    }

    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
        //vec2 uv = (screen_coords - .5 * love_ScreenSize.xy) / love_ScreenSize.xy;
        vec2 uv = (screen_coords - .5 * love_ScreenSize.xy) / love_ScreenSize.xy;
        vec3 col = vec3(.0);
        col += Feather(uv);
        return vec4(col, 1.);
    }
]])

local sh5 = gr.newShader("distortedtv.glsl")
local sh6 = gr.newShader("beginner.glsl")
local sh7 = gr.newShader("voronoi.glsl")
local img = gr.newImage("pic1.png")

--local file = io.open("pic1.png", "r")
--local data = love.data.newByteData(file:read("*a"))
--local img = gr.newImage(data)

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

love.update = function(dt)
    local lk = love.keyboard
    if lk.isDown("z") then
        iCount = iCount + .1
    elseif lk.isDown("x") then
        iCount = iCount - .1
    end
end

local currentShader

love.keypressed = function(_, key)
    if key == "1" then
        currentShader = sh1
    elseif key == "2" then
        currentShader = sh2
    elseif key == "3" then
        currentShader = sh3
    elseif key == "4" then
        currentShader = sh4
    elseif key == "5" then
        currentShader = sh5
    elseif key == "6" then
        currentShader = sh6
    elseif key == "7" then
        currentShader = sh7
    end
end

function safesend(shader, name, ...)
    if shader:hasUniform(name) then
        shader:send(name, ...)
    end
end

love.draw = function()
    --gr.setColor{1, 1, 0, 1}
    --gr.clear(1, 1, 1)
    local w, h = gr.getDimensions()

    --gr.setShader(sh1)
    --gr.rectangle("fill", 0, 0, w, h)

    --gr.setShader(sh2)
    

    mesh:setTexture(img)

    if currentShader then
        safesend(currentShader, "iTime", love.timer.getTime())
        safesend(currentShader, "iTex", img)
        safesend(currentShader, "iCount", iCount)

        gr.setShader(currentShader);
    end
    
    gr.draw(mesh)
end
