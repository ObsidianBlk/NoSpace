shader_type canvas_item;

uniform vec4 pal_col_1 : hint_color = vec4(0.6992, 0.6992, 0.6992, 1.0);
uniform vec4 pal_col_2 : hint_color = vec4(0.6, 0.6, 0.6, 1.0);
uniform vec4 pal_col_3 : hint_color = vec4(0.8, 0.8, 0.8, 1.0);
uniform vec4 pal_col_4 : hint_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform vec4 replace_col_1 : hint_color = vec4(0.6992, 0.6992, 0.6992, 1.0);
uniform vec4 replace_col_2 : hint_color = vec4(0.6, 0.6, 0.6, 1.0);
uniform vec4 replace_col_3 : hint_color = vec4(0.8, 0.8, 0.8, 1.0);
uniform vec4 replace_col_4 : hint_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform float precision : hint_range(0.0, 1.0) = 0.1;

uniform float alpha : hint_range(0.0, 1.0) = 1.0;


vec4 SwapColor(vec4 c){
	vec4 palette[4] = vec4[4] (pal_col_1, pal_col_2, pal_col_3, pal_col_4);
	vec4 replace[4] = vec4[4] (replace_col_1, replace_col_2, replace_col_3, replace_col_4);
	for (int i=0; i < 4; i++){
		if (distance(c, palette[i]) <= precision){
			return replace[i];
		}
	}
	return c;
}

void fragment(){
	vec4 c = SwapColor(texture(TEXTURE, UV));
	COLOR = vec4(c.rgb, c.a * alpha);
}

