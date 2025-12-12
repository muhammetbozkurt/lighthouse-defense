shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, unshaded;// billboard_keep_scale;

uniform sampler2D noise_texture;
uniform sampler2D noise_texture2;
uniform vec4 root_color : source_color = vec4(1.0, 0.75, 0.3, 1.0);
uniform vec4 tip_color : source_color = vec4(1.0, 0.03, 0.001, 1.0);
uniform float fire_alpha : hint_range(0.0, 1.0) = 1.0;
uniform vec2 fire_speed = vec2(0.0, 1.0);
uniform float fire_aperture : hint_range(0.0, 3.0) = 0.22;

void vertex() {
	// Billboard is handled by render_mode billboard_keep_scale
	
	// Vertex displacement for wobble effect
	// We use the same UV logic for noise lookup to keep it consistent
	float noise_val = texture(noise_texture, UV + TIME * fire_speed).r;
	
	// Displace vertices.
	// Since we are in billboard mode, we should be careful with axes.
	// Usually VERTEX.x is width, VERTEX.y is height in local space before rotation.
	VERTEX.x += (noise_val - 0.5) * 0.2 * (1.0 - UV.y); // Wobble more at the top (low UV.y)
	// We remove Z displacement because it's a flat billboard facing the camera
}

void fragment() {
	vec2 uv = UV;
	
	// Noise lookup
	vec2 noise_uv = uv + TIME * fire_speed;
	float noise_val = texture(noise_texture, noise_uv).r;
	float noise_val2 = texture(noise_texture2, noise_uv + vec2(0.3, 0.2)).r;
	float combined_noise = (noise_val + noise_val2) * 0.5;
	
	// Shape Logic
	// UV.y: 0.0 (Top) -> 1.0 (Bottom)
	// We want the fire to be wide at the bottom and narrow at the top.
	float vertical_gradient = uv.y; // 0 at top, 1 at bottom
	
	// Horizontal distance from center
	float dist_from_center = abs(uv.x - 0.5);
	
	// Calculate dynamic width based on height (gradient) and aperture
	float flame_width = vertical_gradient * fire_aperture;
	
	// Smoothstep for soft anti-aliased edges
	// We ensure the edge1 > edge0 by adding a small epsilon or scaling
	// If dist < flame_width, we are inside.
	float shape_mask = 1.0 - smoothstep(flame_width - 0.05, flame_width, dist_from_center);
	
	// Erosion
	// We erode the shape using noise. 
	// The noise effect should be stronger at the top (low vertical_gradient) to break up the tip.
	float erosion_amount = (1.0 - vertical_gradient) * 0.5 + 0.1;
	float fire_mask = step(erosion_amount, combined_noise * shape_mask);
	
	// Color ramp
	// Root (Bottom/High Grad) -> Tip (Top/Low Grad)
	vec3 final_color = mix(tip_color.rgb, root_color.rgb, vertical_gradient);
	
	ALBEDO = final_color;
	ALPHA = clamp(shape_mask * fire_mask * fire_alpha, 0.0, 1.0);
	
	// Emission
	EMISSION = final_color * 2.0;
}
