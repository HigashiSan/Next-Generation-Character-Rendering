#pragma once
#include "./Structure.hlsl"
#include "../Lighting.hlsl"
#include "./PBRFunctions.hlsl"

TEXTURE2D(_MainColor);    
float4 _MainColor_ST;
SAMPLER(sampler_MainColor);

TEXTURE2D(_MainNormalTex);    
float4 _MainNormalTex_ST;
SAMPLER(sampler_MainNormalTex);

TEXTURE2D(_DetailNormalTex);    
float4 _DetailNormalTex_ST;
SAMPLER(sampler_DetailNormalTex);

float _MainNormalStrength;
float _DetailNormalStrength;

float2 _MainColor_TexelSize;

TEXTURE2D(_SSSTex);    
float4 _SSSTex_ST;
SAMPLER(sampler_SSSTex);

TEXTURE2D(_BentNormalTex);    
float4 _BentNormalTex_ST;
SAMPLER(sampler_BentNormalTex);

// TEXTURE2D(_SSSTex);    
// float4 _SSSTex_ST;
// SAMPLER(sampler_SSSTex);

TEXTURE2D(_ThicknessTex);    
float4 _ThicknessTex_ST;
SAMPLER(sampler_ThicknessTex);

TEXTURE2D(_KelemenLUT);    
float4 _KelemenLUT_ST;
SAMPLER(sampler_KelemenLUT);

TEXTURE2D(_RoughnessTex);    
float4 _RoughnessTex_ST;
SAMPLER(sampler_RoughnessTex);

TEXTURE2D(_SpecularMask);    
float4 _SpecularMask_ST;
SAMPLER(sampler_SpecularMask);

TEXTURE2D(_Ao);    
float4 _Ao_ST;
SAMPLER(sampler_Ao);

TEXTURE2D(_SpecularOcclusion);    
float4 _SpecularOcclusion_ST;
SAMPLER(sampler_SpecularOcclusion);

float _OcculusionStrength;

float4 _SpecularColor;

float _SSSStrength;

float _CurveIntensity;

float _SpecularStrength;

float _Smooth;

float _Distortion;
float _ScatteringPow;
float _ScatteringScale;
float4 _ScatteringColor;

float _Fresnel;

float _LodeA;
float _LodeB;
float _MixValue;

float _test;

#pragma shader_feature _ShowSSS
#pragma shader_feature _ShowCurve
#pragma shader_feature _ShowSpecular

VertexOutput Vertex(VertexInput v)
{
    VertexOutput o;

    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    o.pos = TransformObjectToHClip(v.vertex);
    
    o.uv = v.texcoord.xy * _MainColor_ST.xy + _MainColor_ST.zw;

    float3 worldPos = TransformObjectToWorld(v.vertex);

    VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal, v.tangent);

    o.worldNormalDir = float4(normalInput.normalWS, worldPos.x);
    o.worldTangentDir = float4(normalInput.tangentWS, worldPos.y);
    o.worldBitangentDir = float4(normalInput.bitangentWS, worldPos.z);

    o.TtoW1 = float3(o.worldTangentDir.x,o.worldBitangentDir.x,o.worldNormalDir.x);
    o.TtoW2 = float3(o.worldTangentDir.y,o.worldBitangentDir.y,o.worldNormalDir.y);
    o.TtoW3 = float3(o.worldTangentDir.z,o.worldBitangentDir.z,o.worldNormalDir.z);

    float3x3 rotation = transpose(float3x3(o.TtoW1, o.TtoW2, o.TtoW3));

    o.worldPos = worldPos;

    o.tangentViewDir = mul(rotation, normalize(_WorldSpaceCameraPos.xyz - worldPos));
    o.tangentLightDir = mul(rotation, normalize(_MainLightPosition.xyz));
    
    return o;
}

float CalculateCurveValue(float3 worldBump, float3 worldPos, float curveFactor)
{
    float deltaWorldNormal = length(fwidth(worldBump));
    float deltaWorldPos = length(fwidth(worldPos));

    float curveValue = deltaWorldNormal / deltaWorldPos;

    return saturate(curveValue * curveFactor);
}

float4 CalculateSSSDiffuse(LightingData lightingData, float curveValue)
{
    return SAMPLE_TEXTURE2D(_SSSTex, sampler_SSSTex, float2(lightingData.NoL * 0.6 + 0.4, curveValue));
}

float CalculateBasicDiffuse(LightingData lightingData, VertexOutput vertexOutput)
{
    //Disney Diffuse
    float roughness = SAMPLE_TEXTURE2D(_RoughnessTex, sampler_RoughnessTex, vertexOutput.uv).r;
    float FD90 = 0.5 + 2 * lightingData.VoH * lightingData.VoH * roughness;
	float FdV = 1 + (FD90 - 1) * pow((1 - lightingData.NoV), 5);
	float FdL = 1 + (FD90 - 1) * pow((1 - lightingData.NoL), 5);
	//return (1 / 3.14159) * FdV * FdL;

    return lightingData.NoL * 0.5 + 0.5;
}

float4 CalculateGGXSpecular(VertexOutput vertexOutput, float3 normalToCalculate, float roughness, float3 tangentLightDir)
{
    // float D = GGXNormalDistributionFunction(lightingData.NoH, roughness);
    // float G = BeckmanGeometricShadowingFunction(lightingData.NoL, lightingData.NoV, roughness);
    // float F = fresnelReflectance(lightingData.H, lightingData.worldViewDir, _Fresnel);

    // float specular = (D * F * G) / (4.0 * lightingData.NoL * lightingData.NoV + 0.1);

    // return specular * _SpecularColor;

    float NoH = max(saturate(dot(normalToCalculate, normalize(vertexOutput.tangentViewDir + tangentLightDir))), 0.0001);
    float NoV = max(saturate(dot(normalToCalculate, vertexOutput.tangentViewDir)), 0.0001);
    float NoL = max(saturate(dot(tangentLightDir, normalToCalculate)), 0.0001);
    float VoH = max(saturate(dot(vertexOutput.tangentViewDir, normalize(vertexOutput.tangentViewDir + tangentLightDir))), 0.0001);

    float alpha = roughness;
	float G_L = NoL + sqrt((NoL - NoL * alpha) * NoL + alpha);
	float G_V = NoV + sqrt((NoV - NoV * alpha) * NoV + alpha);
	float G = G_L * G_V;
    float3 F0 = 0.028;
	float F = fresnelReflectance(normalize(vertexOutput.tangentViewDir + tangentLightDir), vertexOutput.tangentViewDir, 0.028);
	float alpha2 = alpha * alpha;
    float denominator = (NoH * NoH) * (alpha2 - 1) + 1;
	float D = alpha2 / (3.1415926 * denominator * denominator);
	float3 specularColor = D * G * NoL * F;

    return float4(specularColor, 1.0);
}

float4 CalculateKelemenSpecular(LightingData lightingData, VertexOutput vertexOutput)
{
    float smoothNess = SAMPLE_TEXTURE2D(_RoughnessTex, sampler_RoughnessTex, vertexOutput.uv).r * _Smooth;
    float3 kelemen = SAMPLE_TEXTURE2D(_KelemenLUT, sampler_KelemenLUT, float2(lightingData.NoH, smoothNess));

    float PH = pow(2 * kelemen, 10.0);
    float fresnel = fresnelReflectance(lightingData.H, lightingData.worldViewDir, 0.028);
    float specular = max(PH * fresnel / dot(lightingData.H, lightingData.H), 0);

    float4 color = specular * lightingData.NoL * _SpecularStrength * _SpecularColor;

    return color;
}

float4 Frag(VertexOutput vertexOutput) : SV_Target
{
    Light light = GetMainLight();

    float4 BasicColor = SAMPLE_TEXTURE2D(_MainColor, sampler_MainColor, vertexOutput.uv);
    float thicknessValue = (1 - SAMPLE_TEXTURE2D(_ThicknessTex, sampler_ThicknessTex, vertexOutput.uv).r) * _Distortion;
    float specularMask = pow((1 - SAMPLE_TEXTURE2D(_SpecularMask, sampler_SpecularMask, vertexOutput.uv).r), 1.8);
    float ao = SAMPLE_TEXTURE2D(_Ao, sampler_Ao, vertexOutput.uv);
    float4 specularOcclusion = SAMPLE_TEXTURE2D(_SpecularOcclusion, sampler_SpecularOcclusion, vertexOutput.uv) * _OcculusionStrength;

    float3 mainTexNormal = UnpackNormal(SAMPLE_TEXTURE2D(_MainNormalTex, sampler_MainNormalTex, vertexOutput.uv));
    float3 detailTexNormal = UnpackNormal(SAMPLE_TEXTURE2D(_DetailNormalTex, sampler_DetailNormalTex, vertexOutput.uv));
    float3 bentNormal = UnpackNormal(SAMPLE_TEXTURE2D(_BentNormalTex, sampler_BentNormalTex, vertexOutput.uv));

    LightingData lightingData;

    float4 FinalColor = float4(0, 0, 0, 1);

    lightingData = CalculateLightingData(vertexOutput, bentNormal, light.direction);
    float curveValue = CalculateCurveValue(lightingData.worldNormal, lightingData.worldPos, _CurveIntensity);
    float4 sssDiffuse = CalculateSSSDiffuse(lightingData, curveValue);
    FinalColor += sssDiffuse * BasicColor * 0.5;

    lightingData = CalculateLightingData(vertexOutput, mainTexNormal, light.direction);
    float4 basicDiffuse = CalculateBasicDiffuse(lightingData, vertexOutput) * BasicColor;
    float4 kelemenSpecularColor = CalculateKelemenSpecular(lightingData, vertexOutput);
    FinalColor += basicDiffuse;

    float3 translightDir = lightingData.worldLightDir + lightingData.worldNormal;
	float transDot = pow(saturate(dot(-translightDir, lightingData.worldViewDir)) * thicknessValue * thicknessValue, _ScatteringPow) * _ScatteringScale;
	float4 lightScattering = transDot * _ScatteringColor;
    FinalColor += lightScattering * BasicColor;

    lightingData = CalculateLightingData(vertexOutput, mainTexNormal, light.direction);
    float mainRoughness = SAMPLE_TEXTURE2D(_RoughnessTex, sampler_RoughnessTex, vertexOutput.uv).r * _LodeA;
    float4 GGXMainSpecular = CalculateGGXSpecular(vertexOutput, mainTexNormal, mainRoughness, vertexOutput.tangentLightDir);
    FinalColor += GGXMainSpecular * _MixValue * specularMask;

    lightingData = CalculateLightingData(vertexOutput, detailTexNormal, light.direction);
    float detailRoughness = SAMPLE_TEXTURE2D(_RoughnessTex, sampler_RoughnessTex, vertexOutput.uv).r * _LodeB;
    float4 GGXDetailSpecular = CalculateGGXSpecular(vertexOutput, detailTexNormal, detailRoughness, vertexOutput.tangentLightDir);
    FinalColor += GGXDetailSpecular * (1 - _MixValue) * specularMask;

    int lightCount = GetAdditionalLightsCount();
    [unroll]
    for(int lightIndex = 0; lightIndex < lightCount; lightIndex++)
    {
        Light lightAdditional = GetAdditionalLight(lightIndex, vertexOutput.worldPos);
        lightingData = CalculateLightingData(vertexOutput, mainTexNormal, lightAdditional.direction);

        float3x3 rotation = transpose(float3x3(vertexOutput.TtoW1, vertexOutput.TtoW2, vertexOutput.TtoW3));
        float3 tangentLightDir = mul(rotation, lightAdditional.direction.xyz);
        GGXMainSpecular = CalculateGGXSpecular(vertexOutput, mainTexNormal, detailRoughness, tangentLightDir) * specularMask;

        basicDiffuse = CalculateBasicDiffuse(lightingData, vertexOutput) * BasicColor * 0.04;

        //kelemenSpecularColor = CalculateKelemenSpecular(lightingData, vertexOutput) * specularMask;

        translightDir = lightingData.worldLightDir + lightingData.worldNormal;
        transDot = pow(saturate(dot(-translightDir, lightingData.worldViewDir)) * thicknessValue * thicknessValue, _ScatteringPow) * _ScatteringScale;
        lightScattering = transDot * _ScatteringColor;

        lightingData = CalculateLightingData(vertexOutput, bentNormal, lightAdditional.direction);
        curveValue = CalculateCurveValue(lightingData.worldNormal, lightingData.worldPos, _CurveIntensity);
        sssDiffuse = CalculateSSSDiffuse(lightingData, curveValue);

        lightingData = CalculateLightingData(vertexOutput, detailTexNormal, lightAdditional.direction);
        GGXDetailSpecular = CalculateGGXSpecular(vertexOutput, detailTexNormal, detailRoughness, tangentLightDir) * specularMask;

        FinalColor += sssDiffuse * BasicColor * 0.2 + GGXMainSpecular * _MixValue + GGXDetailSpecular * (1 - _MixValue) + lightScattering * BasicColor + basicDiffuse;
        //FinalColor += sssDiffuse * BasicColor * 0.5;
    }
    //lightingData = CalculateLightingData(vertexOutput, mainTexNormal, light.direct);
    //float4 basicDiffuse = CalculateBasicDiffuse(lightingData, vertexOutput) * BasicColor;
	//float4 diffuse = sssDiffuse * BasicColor + basicDiffuse;

    // lightingData = CalculateLightingData(vertexOutput, mainTexNormal, light.direction);
    // float4 kelemenSpecularColor = CalculateKelemenSpecular(lightingData, vertexOutput);

    // #ifdef _SSS

    //     FinalColor = sssDiffuse;

    // #else

    //     FinalColor = BasicColor;

    // #endif

    #ifdef _ShowCurve
        return float4(curveValue, curveValue, curveValue,1.0);
    #endif

    #ifdef _ShowSSS
        return sssDiffuse;
    #endif

    return FinalColor * float4(ao, ao, ao, 1.0);// * specularOcclusion;
    //return kelemenSpecularColor;
}