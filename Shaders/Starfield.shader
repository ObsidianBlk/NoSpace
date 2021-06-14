shader_type canvas_item;
/* ----------------------------------------------------------------------------
* Starfield shader based on code presented by...
* https://geeks3d.com/newz/item?id=61
* ---------------------------------------------------------------------------*/

uniform int num_layers = 6;
uniform float starfield_scale = 4.0;
uniform float star_scale : hint_range(0.0, 1.0) = 0.4;
uniform float star_color_saturation : hint_range(0.0, 1.0) = 1.0;
uniform float flare_range : hint_range(0.0, 1.0) = 0.2;
uniform float flare_intensity : hint_range(0.0, 1.0) = 1.0;
uniform float anim_scale : hint_range(0.0, 1.0) = 1.0;

mat2 rotation(float a){
	float s = sin(a);
	float c = cos(a);
	return mat2(vec2(c, -s), vec2(s, c));
}

float star(vec2 uv, float flare){
	float d = length(uv);
	float m = (.1 * star_scale)/d;
	
	if (flare > 0.0){
		float rays = max(0.0, 1.0 - abs(uv.x * uv.y * 1000.0));
		m += rays * flare;
		uv *= rotation(3.14159/4.0);
		rays = max(0.0, 1.0 - abs(uv.x * uv.y * 1000.0));
		m += rays * 0.3 * flare;
	}
	
	m *= smoothstep(1.0, 0.2, d);
	return m;
}

float hash21(vec2 p){
	p = fract(p * vec2(455.654, 165.234));
	p += dot(p, p * 534.324);
	return fract(p.x * p.y);
}

vec3 starLayer(vec2 uv) {
	vec3 color = vec3(0.0);
	
	vec2 gv = fract(uv) - 0.5;
	vec2 id = floor(uv);
	
	for (int y = -1; y <= 1; y++){
		for (int x = -1; x <= 1; x++){
			vec2 offset = vec2(float(x), float(y));
			
			float n = hash21(id + offset);
			float size = fract(n * 345.34);
			float flare = smoothstep(1.0 - flare_range, 1.0, size) * flare_intensity;
			float star = star(gv - (offset - (vec2(n, fract(n * 43.0)) - 0.5)), flare);
			vec3 scol = sin(vec3(0.9, 0.2, 0.5) * fract(n*4352.34) * 123.324) * 0.5 + 0.5;
			// Color filter... reduce the green and increase the blue for larger stars.
			scol =  mix(vec3(1.0), scol * vec3(1.0, 0.25, 1.0 + size), star_color_saturation);
			color += star * size * scol;
		}
	}
	return color;
}

void fragment(){
	vec2 resolution = 1.0/SCREEN_PIXEL_SIZE;
	vec2 uv = (FRAGCOORD.xy - 0.5 * resolution) / resolution.y;
	uv *= starfield_scale;
	vec3 color = vec3(0);
	float t = TIME * 0.1 * anim_scale;
	
	for (float i = 0.0; i < 1.0; i += 1.0/float(num_layers)){
		float depth = fract(i + t);
		float fade = depth * smoothstep(1.0, 0.9, depth);
		float scale = mix(20.0, 0.5, depth);
		color += starLayer(uv * scale + (i * 323.34)) * fade;
	}
	
	COLOR = vec4(color, 1.0);
}




