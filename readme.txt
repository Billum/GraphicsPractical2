Graphics Practical 2
--------------------

Students:

Gerwin van der Lugt	4261216
Adriaan Kisjes		4279093
Tomas Billum		4161882

Work split:

Adriaan did 1.1, 1.2, 2.1;
Tomas did 2.2, 2.4;
Gerwin did 2.3, 3.1;

Assignment comments:

1.1 Implemented in NormalColor in Simple.fx
1.2 Implemented in ProceduralColor in Simple.fx
2.1 Implemented in Diffusement in Simple.fx, to get the colors this way use: float4 color = Diffusement(input.Normal, input.Position3D);
    Used directional-light.
2.2 To get the colors this way the following is used:
    float4 color = ((AmbientColor * AmbientIntensity)
 + Diffusement(input.Normal, input.Position3D)
);
2.3 Implemented in PhongShadingColor in Simple.fx
2.4 Values calculated using NonUniformScaling and are used in Diffusement and Specularization in Simple.fx
    Used Blinn-Phong.
3.1 Edited Draw() function and added a new Technique to the Simple.fx file. (Technique: Surface)