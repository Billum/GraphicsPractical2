//------------------------------------------- Defines -------------------------------------------

#define Pi 3.14159265

//------------------------------------- Top Level Variables -------------------------------------

// Top level variables can and have to be set at runtime

// Matrices for 3D perspective projection 
float4x4 View, Projection, World;//, WorldInverseTranspose;
float3 Camera;

// Material parameters
float4 AmbientColor;
float AmbientIntensity;
float4 DiffuseColor;
Texture DiffuseTexture;
float3 LightSourcePosition;
float4 SpecularColor;
float SpecularIntensity;
float SpecularPower;

sampler TextureSampler
	= sampler_state { texture = <DiffuseTexture> ;
					  magfilter = LINEAR;
					  minfilter = LINEAR;
					  mipfilter = LINEAR;
					  AddressU = mirror;
					  AddressV = mirror;
					};

//---------------------------------- Input / Output structures ----------------------------------

// Each member of the struct has to be given a "semantic", to indicate what kind of data should go in
// here and how it should be treated. Read more about the POSITION0 and the many other semantics in 
// the MSDN library
struct VertexShaderInput
{
	float4 Position3D	: POSITION0;
	float3 Normal		: NORMAL0;
	float2 TexCoords	: TEXCOORD0;
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
	float4 Position2D	: POSITION0;
	float3 Normal		: TEXCOORD0;
	float4 Position3D	: TEXCOORD1;
	float2 TexCoords	: TEXCOORD2;
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

float4 Diffusement(float3 normal, float3 pos3d)
{
	float3 lightDirection = normalize(LightSourcePosition - pos3d);

	float dotN = dot (normal, lightDirection);
	if (dotN < 0) {
		dotN = 0;
	}

	float intensity = saturate (dotN);
	return intensity * DiffuseColor;
}

float4 Specularization(float3 normal, float3 pos3d)
{
	float3 lightDirection = LightSourcePosition - pos3d;
	float3 half = normalize (lightDirection + normalize(Camera - pos3d));

	float intensity = pow (saturate (dot (normal, half)), SpecularPower);
	return intensity * SpecularColor;
}

float4 PhongShadingColor(float3 normal, float3 pos3d)
{
	return saturate (  (AmbientColor * AmbientIntensity) // Ambient part
				     + Diffusement(normal, pos3d)		 // Diffusion
				     + Specularization(normal, pos3d)	 // Specular part
				    );
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
	output.Normal		 = input.Normal;
	output.Position3D	 = input.Position3D;

	return output;
}

float4 SimplePixelShader(VertexShaderOutput input) : COLOR0
{
	//float4 color = ProceduralColor(input.Normal, input.Position3D);
	//float4 color = NormalColor(input.Normal);

	//float4 color = Diffusement(input.Normal, input.Position3D);

	//float4 color = ( (AmbientColor * AmbientIntensity)
	//				 + Diffusement(input.Normal, input.Position3D)
	//			     );

	float4 color = PhongShadingColor(input.Normal, input.Position3D);

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

//---------------------------------------- Technique: Surface ----------------------------------------

VertexShaderOutput SurfaceVertexShader(VertexShaderInput input)
{
	// Allocate an empty output struct
	VertexShaderOutput output = (VertexShaderOutput)0;

	// Do the matrix multiplications for perspective projection and the world transform
	float4 worldPosition = mul(input.Position3D, World);
	float4 viewPosition  = mul(worldPosition, View);
	output.Position2D    = mul(viewPosition, Projection);
	output.Normal		 = input.Normal;
	output.Position3D	 = input.Position3D;
	output.TexCoords	 = input.TexCoords;

	return output;
}

float4 SurfacePixelShader(VertexShaderOutput input) : COLOR0
{
	return tex2D (TextureSampler, input.TexCoords);
}

technique Surface
{
	pass Pass0
	{
		VertexShader = compile vs_2_0 SurfaceVertexShader();
		PixelShader  = compile ps_2_0 SurfacePixelShader();
	}
}