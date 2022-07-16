#pragma once

#define UNITY_PI 3.14159265359f

//DFG

float GGXNormalDistributionFunction(float NdotH, float roughness)
{
	float d = ( NdotH * roughness - NdotH ) * NdotH + 1;	
	return roughness / (UNITY_PI * d * d);			
}

float BeckmanGeometricShadowingFunction(float NdotL, float NdotV, float roughness){

    float roughnessSqr = roughness * roughness;
    float NdotLSqr = NdotL * NdotL;
    float NdotVSqr = NdotV * NdotV;

    float calulationL = (NdotL) / (roughnessSqr * sqrt(1- NdotLSqr));
    float calulationV = (NdotV) / (roughnessSqr * sqrt(1- NdotVSqr));

    float SmithL = calulationL < 1.6 ? (((3.535 * calulationL) + (2.181 * calulationL * calulationL))/(1 + (2.276 * calulationL) + (2.577 * calulationL * calulationL))) : 1.0;
    float SmithV = calulationV < 1.6 ? (((3.535 * calulationV) + (2.181 * calulationV * calulationV))/(1 + (2.276 * calulationV) + (2.577 * calulationV * calulationV))) : 1.0;

	float Gs =  (SmithL * SmithV);
	return Gs;
}

float3 FresnelEquation(float3 F0 , float vh)
{
    float3 F = F0 + (1 - F0) * exp2((-5.55473 * vh - 6.98316) * vh);
    return F;
}

float PHBeckmann(float nDotH, float m)
{
	float alpha = acos(nDotH);
	float tanAlpha = tan(alpha);
	float value = exp(-(tanAlpha * tanAlpha) / (m * m)) / (m * m * pow(nDotH, 4.0));
	return value;
}

float fresnelReflectance(float3 halfDir, float3 viewDir, float F0)
{
	float base = 1.0 - dot(viewDir, halfDir);
	float exponential = pow(base, 5.0);
	return exponential + F0 * (1.0 - exponential);
}

float DisneyDiffuse(float NdotV, float NdotL, float LdotH, float roughness, float3 baseColor)
{
    float fd90 = 0.5 + 2 * LdotH * LdotH * roughness;
    float lightScatter = (1 + (fd90 - 1) * pow((1 - NdotL), 5));
    float viewScatter = (1 + (fd90 - 1) * pow((1 - NdotV), 5));
    return (baseColor / UNITY_PI) * lightScatter * viewScatter;
}
