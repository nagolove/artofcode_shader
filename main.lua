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
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = screen_coords / love_ScreenSize.xy;
    vec3 col = vec3(0.5);
    vec2 gv = fract(uv * 5.0) - .5;
    //float d = length(gv);
    float m = 0.;

    for (float y = -1.; y <= 1.; y++) {
        for (float x = -1.; x <= 1.; x++) {
            vec2 offs = vec2(x, y);
            float d = length(gv + offs);
            //float r = 0.1;
            //m += smoothstep(r, r * 0.9, d);
            float r = mix(0.3, 0.5, sin(iTime) * 0.5 + 0.5);
            m += smoothstep(r, r * 0.9, d);
        }
    }

    col.rg = gv;
    col += m;
    //col += smoothstep(0.1, 0.11, uv.x);
    return vec4(col, 1.0);
}
]])

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

love.draw = function()
    --gr.setColor{1, 1, 0, 1}
    --gr.clear(1, 1, 1)
    local w, h = gr.getDimensions()

    --gr.setShader(sh1)
    --gr.rectangle("fill", 0, 0, w, h)

    --gr.setShader(sh2)
    sh3:send("iTime", love.timer.getTime())
    gr.setShader(sh3);
    gr.rectangle("fill", 0, 0, w, h)

    --gr.draw(mesh)
end
