#pragma once
struct VertexInput
{
	float4 vertex : POSITION;
	float4 normal : NORMAL;
	float4 tangent: TANGENT;
	float2 texcoord : TEXCOORD0;
};

struct VertexOutput
{
	float4 pos : SV_POSITION;

    float2 uv : TEXCOORD0;

	float4 worldNormalDir : TEXCOORD2;
	float4 worldTangentDir : TEXCOORD3;
	float4 worldBitangentDir : TEXCOORD4;

    float3 TtoW1 : TEXCOORD5;
    float3 TtoW2 : TEXCOORD6;
    float3 TtoW3 : TEXCOORD7;

    float3 worldPos : TEXCOORD8;

    float3 tangentViewDir : TEXCOORD9;
    float3 tangentLightDir : TEXCOORD10;

};

struct LightingData
{
    float3 worldPos;
    float3 worldNormal;
    float3 worldLightDir;
    float3 worldViewDir;
    
    float3 H;

    float NoL;
    float NoV;
    float NoH;
    float LoH;
    float RoV;
    float VoH;
    float ToH;
    float BoH;
    float ToV;
    float BoV;
    float ToL;
    float BoL;
	
    float R;

    float3x3 TtoW_Matrix;
};