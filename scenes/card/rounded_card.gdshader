shader_type canvas_item;

// Rounds the corners of a card layer (a TextureRect / ColorRect stretched over the card).
// The corner test uses the layer's own pixel coordinates, not UV: a card face is a region of a
// shared card sheet (an AtlasTexture), whose UVs don't run 0..1 across the card.
// size: the layer's size in its own pixels. radius: the corner radius in the same pixels.
uniform vec2 size = vec2(250.0, 350.0);
uniform float radius = 15.0;

varying vec2 local_pos;

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	vec4 c = COLOR;
	vec2 half_size = size * 0.5;
	vec2 d = abs(local_pos - half_size) - (half_size - vec2(radius));
	float dist = length(max(d, vec2(0.0))) - radius;
	float aa = max(fwidth(dist), 0.0001);
	c.a *= clamp(0.5 - dist / aa, 0.0, 1.0);
	COLOR = c;
}
