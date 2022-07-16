Shader "URP/Hair"
{
	Properties
	{
		[Header(Texture)]
		_MainColor("Main Texture", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "white" {}
		_AnisotropyTexture("Anisotropy Map", 2D) = "white" {}

		_DiffuseColor("Diffuse Color", Color) = (1,1,1,1)

		_Anisotropy("Anisotropy", Range(0.0, 1.0)) = 0.5

		[Header(First Specular Settings)]
		_FirstSpecularColor("First Specular Color", Color) = (1,1,1,1)
		_FirstWidth("FirstWidth", Range(0, 40)) = 2
		_FirstStrength("FirstStrength", Range(0.0, 8.0)) = 4
		_FirstOffset("First Offset", Range(-2,2)) = -0.5

		[Header(Second Specular Settings)]
		_SecondSpecularColor("Second Specular Color", Color) = (1,1,1,1)
		_SecondWidth("Second Width", Range(0.0, 300.0)) = 2
		_SecondStrength("Second Strength", Range(0.0, 8.0)) = 1.0
		_SecondOffset("_SecondOffset", Range(-2, 2)) = 0.0

		[Header(GGX Specular Settings)]
		_Smoothness1("Smoothness1", Range(0, 1)) = 0.5
		_Smoothness2("Smoothness2", Range(0, 1)) = 0.5
		_GGXAnisotropy("GGXAnisotropy", Range(0, 1)) = 0.7

		[Header(Alpha Settings)]
		_ClipValue("Clip Value", Range(0.0, 1.0)) = 0.2
		_Float_1("Float 1", Range(0, 5 )) = 1
		_Float_2("Float 2", Range(0.8, 1.0)) = 1

		[Toggle(_AdditionalLights)] _AdditionalLights("_AdditionalLights", float) = 1
		[Toggle(_EnviromentLighting)]_EnviromentLighting("_EnviromentLighting", float) = 1
	}

	SubShader
	{
		Tags { "RenderPipeline" = "UniversalPipeline"  "IgnoreProjector"="True" "Queue" = "Transparent" }

		Pass
		{
			Name "Draw Back"
			Tags{"LightMode" = "UniversalForward"}
			Blend SrcAlpha OneMinusSrcAlpha 
			Cull Back
			ZWrite Off
			

			HLSLPROGRAM

			#pragma vertex Vertex
			#pragma fragment Frag

			#pragma target 4.5

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "./HairBase.hlsl"

			ENDHLSL
		}

		Pass
		{
			Name "Draw Front"
			Blend SrcAlpha OneMinusSrcAlpha 
			Cull Front
			ZWrite Off
 
			HLSLPROGRAM

			#pragma vertex Vertex
			#pragma fragment Frag

			#pragma target 4.5

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "./HairBase.hlsl"

			ENDHLSL
		}
	}

	FallBack "VertexLit"
}