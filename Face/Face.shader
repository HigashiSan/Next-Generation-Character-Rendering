Shader "URP/Face"
{
	Properties
	{
		[Header(Textures)]
		_MainColor("Main Texture", 2D) = "white" {}
		_MainNormalTex("Main Normal Texture", 2D) = "white" {}
		//_MainNormalStrength("Main Normal Strength", Range(0, 2)) = 1.0
		_DetailNormalTex("Detail Normal Texture", 2D) = "white" {}
		//_DetailNormalStrength("Detail Normal Strength", Range(0, 2)) = 1.0
		_BentNormalTex("Bent Normal Tex", 2D) = "white" {}
		_KelemenLUT("KelemenLUT", 2D) = "white" {}
		_SSSTex("SSS Lut", 2D) = "white" {}
		_ThicknessTex("Thickness Texture", 2D) = "white" {}
		_RoughnessTex("Roughness Texture", 2D) = "white" {}
		_SpecularMask("Specular Mask", 2D) = "white" {}
		_Ao("Ao", 2D) = "white" {}
		_SpecularOcclusion("Specular Occlusion", 2D) = "white" {}
		_OcculusionStrength("Occulusion Strength", Range(1.0, 2.0)) = 1.5

		[Header(Double Specular Settings)]
		_LodeA("Lode A", Range(0, 1)) = 0.5
		_LodeB("Lode B", Range(0, 1)) = 0.5
		_MixValue("Mix Value", Range(0, 1)) = 0.5

		[Header(Specular)]
		_SpecularColor("SpecularColor", Color) = (1,1,1,1)
		_SpecularStrength("SpecularStrength", Range(0,1200)) = 1
		_CurveIntensity("Curve Intensity", Range(0.0001, 0.03)) = 0.0005
		_Smooth("Kelemen Specular Smooth", Range(0, 1)) = 0.5

		[Header(Transmittence)]
		_Distortion("Distortion", float) = 1.0
		_ScatteringPow("ScatteringPow", float) = 1.0
		_ScatteringScale("ScatteringScale", float) = 1.0
		_ScatteringColor("ScatteringColor", Color) = (1,1,1,1)

		_Fresnel("Fresnel", Range(0, 0.2)) = 0.028

		[Header(Test)]
		_test("test", Range(0, 2)) = 1.0

		[Toggle(_ShowSSS)] _ShowSSS("_ShowSSS", float) = 1
		[Toggle(_ShowCurve)] _ShowCurve("_ShowCurve", float) = 1
		[Toggle(_ShowSpecular)] _ShowSpecular("_ShowSpecular", float) = 1
	}

	SubShader
	{
        Tags 
		{
            "IgnoreProjector"="True"
            "RenderPipeline" = "UniversalPipeline"
        }

		Pass
		{
			Name "ForwardLit"
			Tags { "LightMode" = "UniversalForward" }

			//Blend SrcAlpha OneMinusSrcAlpha
			//ZWrite Off
			Cull Off

			HLSLPROGRAM

			#pragma vertex Vertex
			#pragma fragment Frag

			#pragma target 3.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "FaceBase.hlsl"

			ENDHLSL
		}

		// Pass
		// {
		// 	Name "ForwardLit"
		// 	Tags { "LightMode" = "UniversalForward" }

		// 	//Blend SrcAlpha OneMinusSrcAlpha
		// 	//ZWrite Off
		// 	Cull Off

		// 	HLSLPROGRAM

		// 	#pragma vertex Vertex
		// 	#pragma fragment Frag

		// 	#pragma target 3.0

        //     #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        //     #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
		// 	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
		// 	#include "FaceBase.hlsl"

		// 	ENDHLSL
		// }
	}

	FallBack "VertexLit"
}