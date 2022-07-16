#pragma once

struct VertexInput
{
	float4 vertex : POSITION;
	float4 normal : NORMAL;
	float4 tangent: TANGENT;
	float4 texcoord : TEXCOORD0;
};

struct VertexOutput
{
	float4 pos : SV_POSITION;

    float2 uv_MainTex : TEXCOORD0;
    float2 uv_NormalTex : TEXCOORD1;
	float4 worldNormalDir : TEXCOORD2;
	float4 worldTangentDir : TEXCOORD3;
	float4 worldBitangentDir : TEXCOORD4;
    
    float3 worldBinormal : TEXCOORD5;
    float3 worldPos : TEXCOORD6;
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
    float ToH;
    float BoH;

    float R;
};


