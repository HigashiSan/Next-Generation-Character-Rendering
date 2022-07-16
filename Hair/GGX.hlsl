#pragma once

float GGXAnisotropySpecular(LightingData lightingData, VertexOutput vertexOutput, float3 tangent, float roughness, float anisotropy)
{
    float anisoAspect = sqrt(1.0 - 0.9 * anisotropy);
    float roughnessT = roughness / anisoAspect;
    float roughnessB = roughness * anisoAspect;

    float f = dot(tangent, lightingData.H) * dot(tangent, lightingData.H) / (roughnessT * roughnessT) 
            + dot(vertexOutput.worldBitangentDir, lightingData.H) * dot(vertexOutput.worldBitangentDir, lightingData.H) / (roughnessB * roughnessB) 
            + lightingData.NoH * lightingData.NoH;

    return 1.0 / (roughnessT * roughnessB * f * f);
}