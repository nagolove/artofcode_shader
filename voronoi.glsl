extern float iTime;

vec2 N22(vec2 p) {
    vec3 a = fract(p.yxy * vec3(98.2, 24.2, 9014.3));
    a += dot(a, a - 141.34145);
    return fract(vec2(a.x * a.y, a.z * a.y));
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = (2. * screen_coords - love_ScreenSize.xy) / love_ScreenSize.y;
    //vec2 uv = (screen_coords - .5 * love_ScreenSize.xy) / love_ScreenSize.y;
    float m = 0;
    float t = iTime;
    float minDist = 100.;
    for (float i = 0.; i < 50.; i++) {
        vec2 n = N22(vec2(i));
        vec2 p = sin(n * t);
        float d = length(uv - p);
        m += smoothstep(0.2, 0.1, d);

        if (d < minDist) {
            minDist = d;
        }
    }

    vec3 col = vec3(minDist);
    return vec4(col, 1.);
}

