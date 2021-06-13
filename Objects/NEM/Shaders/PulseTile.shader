shader_type canvas_item;

uniform vec4 color : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float base_intensity : hint_range(0.0, 1.0) = 0.25;
uniform float overall_intensity : hint_range(0.0, 1.0) = 1.0;
uniform float rim_thickness : hint_range(0.01, 0.5) = 0.02;
uniform float rim_fade : hint_range(0.0, 1.0) = 0.5;

vec4 calculateRim(vec2 uv){
	float fade = rim_thickness * (1.0 - rim_fade);
	float xthick = 0.5 - abs(0.5 - uv.x);
	float ythick = 0.5 - abs(0.5 - uv.y);
	vec4 base_color = vec4(color.rgb * base_intensity, color.a);
	vec4 result = base_color;
	
	if (xthick <= rim_thickness || ythick <= rim_thickness){
		float xpos = 0.0;
		float ypos = 0.0;
		if (xthick > fade)
			xpos = (xthick - fade) / (rim_thickness - fade);
		if (ythick > fade)
			ypos = (ythick - fade) / (rim_thickness - fade);
		xpos = min(xpos, ypos);
		
		result = mix(color, base_color, xpos);
	}
	
	return result;
}

void fragment(){
	vec4 clr = calculateRim(UV);
	
	COLOR = vec4(clr.rgb * overall_intensity, 1.0);
}