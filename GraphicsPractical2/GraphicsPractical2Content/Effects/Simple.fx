//------------------------------------------- Defines -------------------------------------------

#define Pi 3.14159265

//------------------------------------- Top Level Variables -------------------------------------

// Top level variables can and have to be set at runtime

// Matrices for 3D perspective projection 
float4x4 View, Projection, World;

//---------------------------------- Input / Output structures ----------------------------------

// Each member of the struct has to be given a "semantic", to indicate what kind of data should go in
// here and how it should be treated. Read more about the POSITION0 and the many other semantics in 
// the MSDN library
struct VertexShaderInput
{
	float4 Position3D : POSITION0;
	float3 Normal : NORMAL0;
};

// The output of the vertex shader. After being passed through the interpolator/rasterizer it is also 
// the input of the pixel shader. 
// Note 1: The values that you pass into this struct in the vertex shader are not the same as what 
// you get as input for the pixel shader. A vertex shader has a single vertex as input, the pixel 
// shader has 3 vertices as input, and lets you determine the color of each pixel in the triangle 
// defined by these three vertices. Therefor, all the values in the struct that you get as input for 
// the pixel shaders have been linearly interpolated between there three vertices!
// Note 2: You cannot use the data with the POSITION0 semantic in the pixel shader.
struct VertexShaderOutput
{
	float4 Position2D : POSITION0;
	float3 Normal : TEXCOORD0;
	float4 Schaak : TEXCOORD1;
};

//------------------------------------------ Functions ------------------------------------------

// Implement the Coloring using normals assignment here
float4 NormalColor(float3 normal)
{
	return float4(normal.r, normal.g, normal.b, 1);
}

// Implement the Procedural texturing assignment here
float4 ProceduralColor(float3 normal, float4 schaak)
{
	int x = (int)((schaak.x + 21) * 5);
	int y = (int)((schaak.y + 21) * 5);
	if ((x % 2 + y % 2) % 2 > 0) {
		return NormalColor(-1 * normal);
	}
	else {
		return NormalColor(normal);
	}
}

float4 DiffuseColor(float3 normal)
{
	float3 direction = float3(1, 1, 1);
	direction = normalize(direction);
	float dotn = dot(normal, direction);
	if (dotn < 0) {
		dotn = 0;
	}
	return dotn * float4(1, 0, 0, 1);
}


//---------------------------------------- Technique: Simple ----------------------------------------

VertexShaderOutput SimpleVertexShader(VertexShaderInput input)
{
	// Allocate an empty output struct
	VertexShaderOutput output = (VertexShaderOutput)0;

	// Do the matrix multiplications for perspective projection and the world transform
	float4 worldPosition = mul(input.Position3D, World);
    float4 viewPosition  = mul(worldPosition, View);
	output.Position2D    = mul(viewPosition, Projection);
	output.Normal	 = input.Normal;
	output.Schaak = input.Position3D;

	return output;
}

float4 SimplePixelShader(VertexShaderOutput input) : COLOR0
{
	//float4 color = ProceduralColor(input.Normal, input.Schaak);
	//float4 color = NormalColor(input.Normal);
	float4 color = DiffuseColor(input.Normal);

	return color;
}

technique Simple
{
	pass Pass0
	{
		VertexShader = compile vs_2_0 SimpleVertexShader();
		PixelShader  = compile ps_2_0 SimplePixelShader();
	}
}