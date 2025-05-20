shader_type spatial;

//varying float height;
uniform float maxY = 2.0;
uniform float minY = 0.0;

uniform float plateau = 10.0;
uniform float base = 0.0;

uniform float heightScale = 1.0;
uniform sampler2D noise;

struct Particle{
	vec2 pos;
	vec2 speed;
	float volume;
	float sediment;
};


float calcVertHeight(vec2 loc) {
	//float height = (cos(loc.x) * sin(loc.y)) + 1.0;
	float height = texture(noise, loc/50.0 + 100.0).x * heightScale;
	height = clamp(height, base, plateau);
	return height;
}

//Runs on vertices
void vertex() {
	VERTEX.y = calcVertHeight(VERTEX.xz);
	float height = (3.0 * pow(VERTEX.y, 2.0)) - (2.0 * pow(VERTEX.y, 3.0));
	height = (height - minY)/(maxY - minY);
	COLOR.xyz = vec3(height * -1.0);
	vec2 e = vec2(0.1, 0.0);
	vec3 normal = normalize(vec3(calcVertHeight(VERTEX.xz - e) - calcVertHeight(VERTEX.xz + e), 2.0 * e.x, calcVertHeight(VERTEX.xz - e.yx) - calcVertHeight(VERTEX.xz + e.yx)));
	NORMAL = normal;
}



//Runs on every pixel
void fragment() {
	
	ALBEDO = COLOR.xyz;
	
}

