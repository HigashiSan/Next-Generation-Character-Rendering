#pragma once
#include "./Structure.hlsl"
#include "./Lighting.hlsl"
#include "./Scheuermann.hlsl"
#include "./GGX.hlsl"

TEXTURE2D(_MainColor);    
float4 _MainColor_ST;
SAMPLER(sampler_MainColor);

TEXTURE2D(_NormalMap);
float4 _NormalMap_ST;
SAMPLER(sampler_NormalMap);

TEXTURE2D(_AnisotropyTexture);
float4 _AnisotropyTexture_ST;
SAMPLER(sampler_AnisotropyTexture);

float4 _DiffuseColor;
float4 _FirstSpecularColor;
float4 _SecondSpecularColor;

float _FirstStrength;
float _FirstWidth;
float _FirstOffset;

float _SecondStrength;
float _SecondWidth;
float _SecondOffset;

float _ClipValue;
float _Float_1;
float _Float_2;

float _Anisotropy;

//GGX Values
float _Smoothness1;
float _Smoothness2;
float _GGXAnisotropy;

#pragma shader_feature _AdditionalLights
#pragma shader_feature _EnviromentLighting

float CalculateAlpha(float alpha)
{
    float weekness = 1.0 / _Float_1;
    
    float weekenedAlpha = pow(alpha, weekness);

    return smoothstep(0.0, _Float_2, weekenedAlpha);
}


VertexOutput Vertex(VertexInput v)
{
    VertexOutput o;

    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    o.pos = TransformObjectToHClip(v.vertex);
    
    o.uv_MainTex = v.texcoord.xy * _MainColor_ST.xy + _MainColor_ST.zw;
    o.uv_NormalTex = v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;

    float3 worldPos = TransformObjectToWorld(v.vertex);

    VertexNormalInputs normalInput = GetVertexNormalInputs(v.normal, v.tangent);

    o.worldNormalDir = float4(normalInput.normalWS, worldPos.x);
    o.worldTangentDir = float4(normalInput.tangentWS, worldPos.y);
    o.worldBitangentDir = float4(normalInput.bitangentWS, worldPos.z);
    o.worldBinormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
    o.worldPos = worldPos;

    return o;
}

float3 CalculateAdditionalLight(VertexOutput vertexOutput, float4 _DiffuseColor, float3 normal, float3 basicColor)
{
    float3 finalColor;
    float3 Diffuse;
    float3 Specular;

    int lightCount = GetAdditionalLightsCount();
    for(int lightIndex = 0; lightIndex < lightCount; lightIndex++)
    {
        Light light = GetAdditionalLight(lightIndex, vertexOutput.worldPos);
        LightingData lightingData = CalculateLightingData(vertexOutput, normal, light.direction);

        Diffuse = max(0, 0.75 * lightingData.NoL + 0.25) * _DiffuseColor.rgb * basicColor;

        float shift = SAMPLE_TEXTURE2D(_AnisotropyTexture, sampler_AnisotropyTexture, vertexOutput.uv_MainTex) - 0.5;
        float3 shiftedTangent1 = lerp(vertexOutput.worldBitangentDir.xyz + _FirstOffset , ShiftTangent(vertexOutput, shift + _FirstOffset), _Anisotropy);
        float3 shiftedTangent2 = lerp(vertexOutput.worldBitangentDir.xyz + _SecondOffset, ShiftTangent(vertexOutput, shift + _SecondOffset), _Anisotropy);

        float3 FirstSpecular = _FirstSpecularColor.rgb * AnisotropySpecular(vertexOutput, lightingData, _FirstWidth, _FirstStrength, shiftedTangent1);
        float3 SecondSpecular = _SecondSpecularColor.rgb * AnisotropySpecular(vertexOutput, lightingData, _SecondWidth, _SecondStrength, shiftedTangent2);

        float clampedNdotV = max(lightingData.NoV, 0.0001);
        float clampedNdotL = saturate(lightingData.NoL);
        Specular = (FirstSpecular + SecondSpecular) * saturate(lightingData.NoL * lightingData.NoV) * clampedNdotL;

        finalColor += (Specular / lightCount + Diffuse / lightCount) * light.color;
    }

    return finalColor;
}

//for hair outter
float4 Frag(VertexOutput vertexOutput) : SV_Target
{
    float4 basicColor = SAMPLE_TEXTURE2D(_MainColor, sampler_MainColor, vertexOutput.uv_MainTex);
    float alpha = SAMPLE_TEXTURE2D(_MainColor, sampler_MainColor, vertexOutput.uv_MainTex).a;
    float3 normal = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, vertexOutput.uv_NormalTex));

    Light mainLight = GetMainLight();

    LightingData lightingData = CalculateLightingData(vertexOutput, normal, mainLight.direction);

    float3 Diffuse = basicColor.rgb * DiffuseTerm(lightingData) * _DiffuseColor;

    float shift = SAMPLE_TEXTURE2D(_AnisotropyTexture, sampler_AnisotropyTexture, vertexOutput.uv_MainTex) - 0.5;
    float3 shiftedTangent1 = lerp(vertexOutput.worldBitangentDir.xyz + _FirstOffset , ShiftTangent(vertexOutput, shift + _FirstOffset), _Anisotropy);
    float3 shiftedTangent2 = lerp(vertexOutput.worldBitangentDir.xyz + _SecondOffset, ShiftTangent(vertexOutput, shift + _SecondOffset), _Anisotropy);

    //Scheuermann Model
    float3 FirstSpecular = _FirstSpecularColor.rgb * AnisotropySpecular(vertexOutput, lightingData, _FirstWidth, _FirstStrength, shiftedTangent1);
    float3 SecondSpecular = _SecondSpecularColor.rgb * AnisotropySpecular(vertexOutput, lightingData, _SecondWidth, _SecondStrength, shiftedTangent2);

    //HDRP Calculation
    // float hdrpShift = SAMPLE_TEXTURE2D(_AnisotropyTexture, sampler_AnisotropyTexture, vertexOutput.uv_MainTex).r;
    // float3 hdrpShiftTangent1 = lerp(vertexOutput.worldBitangentDir.xyz + _FirstOffset, ShiftTangent(vertexOutput, hdrpShift * _Anisotropy + _FirstOffset), _Anisotropy);
    // float3 hdrpShiftTangent2 = lerp(vertexOutput.worldBitangentDir.xyz + _SecondOffset, ShiftTangent(vertexOutput, hdrpShift * _Anisotropy + _SecondOffset), _Anisotropy);

    // float3 H = (lightingData.worldLightDir + lightingData.worldViewDir) * rsqrt(max(2.0 * dot(lightingData.worldLightDir, lightingData.worldViewDir) + 2.0, FLT_EPS));

    // float specularExponent = exp2(9.0 - 10.0 * PerceptualRoughnessToRoughness(PerceptualSmoothnessToPerceptualRoughness(_Smoothness1)));
    // float secondarySpecularExponent = exp2(9.0 - 10.0 * PerceptualRoughnessToRoughness(PerceptualSmoothnessToPerceptualRoughness(_Smoothness2)));

    // float3 FirstSpecular = _FirstSpecularColor.rgb * D_KajiyaKay(hdrpShiftTangent1, H, specularExponent);
    // float3 SecondSpecular = _SecondSpecularColor.rgb * D_KajiyaKay(hdrpShiftTangent2, H, secondarySpecularExponent);

    //GGXFirstSpecular Test
    //float3 GGXFirstSpecular = _FirstSpecularColor.rgb * GGXAnisotropySpecular(lightingData, vertexOutput,  vertexOutput.worldBitangentDir.xyz, _Smoothness1, _GGXAnisotropy);
    
    alpha = CalculateAlpha(alpha);
    clip(alpha - _ClipValue);

    float clampedNdotV = max(lightingData.NoV, 0.0001);
    float clampedNdotL = saturate(lightingData.NoL);
    float3 Specular = (FirstSpecular + SecondSpecular) * saturate(lightingData.NoL * lightingData.NoV) * clampedNdotL;

    float3 finalColor;

    #ifdef _EnviromentLighting

        finalColor = (Diffuse + Specular) * mainLight.color + SampleSH(lightingData.worldNormal);

    #else

        finalColor = (Diffuse + Specular) * mainLight.color;

    #endif

    #ifdef _AdditionalLights

        float3 additionalColor = CalculateAdditionalLight(vertexOutput, _DiffuseColor, normal, basicColor.rgb);
        finalColor += additionalColor;

    #endif

    return float4(finalColor, alpha);
}

//For hair inner
float4 FragBase(VertexOutput vertexOutput) : SV_Target
{
    float4 basicColor = SAMPLE_TEXTURE2D(_MainColor, sampler_MainColor, vertexOutput.uv_MainTex);
    float alpha = SAMPLE_TEXTURE2D(_MainColor, sampler_MainColor, vertexOutput.uv_MainTex).a;
    float3 normal = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, vertexOutput.uv_NormalTex));

    LightingData lightingData = CalculateLightingData(vertexOutput, normal, _MainLightPosition.xyz);

    float3 Diffuse = basicColor.rgb * DiffuseTerm(lightingData) * _DiffuseColor;

    alpha = CalculateAlpha(alpha);
    clip(alpha - _ClipValue);

    Light mainLight = GetMainLight();

    return float4((Diffuse) * mainLight.color, 1.0);
}