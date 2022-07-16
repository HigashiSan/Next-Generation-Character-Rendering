#pragma once

float3 ShiftTangent(VertexOutput vertexOutput, float shift)
{
    return normalize(vertexOutput.worldBitangentDir + vertexOutput.worldNormalDir * shift).xyz;
}

float AnisotropySpecular(VertexOutput vertexOutput, LightingData lightingData, float width, float strength, float3 shiftedTangent)
{
    //With HDRP Anisotropy
    //float dotTH = dot(shiftedTangent, lightingData.H);
    //Without HDRP Anistropy

    //float3 lerpTangent = lerp(vertexOutput.worldBitangentDir.xyz, shiftedTangent, _Anisotropy);

    float3 H = (lightingData.worldLightDir + lightingData.worldViewDir) * rsqrt(max(2.0 * dot(lightingData.worldLightDir, lightingData.worldViewDir) + 2.0, FLT_EPS));

    float dotTH = dot(shiftedTangent, H);
    //float dotTH = dot(shiftedTangent, lightingData.H);

    float sinTH = max(0.01, sqrt(1 - pow(dotTH, 2)));
    float dirAtten = smoothstep(-1, 0, dotTH);
    return dirAtten * pow(sinTH, width * 10.0) * strength;
    //return dirAtten * pow(sinTH, width * 10.0);
}
