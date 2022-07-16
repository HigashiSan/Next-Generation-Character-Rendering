#pragma once
LightingData CalculateLightingData(VertexOutput vertexOutput, float3 sampledNormal)
{
    LightingData lightingData;

	lightingData.worldPos = float3(vertexOutput.worldNormalDir.w, vertexOutput.worldTangentDir.w, vertexOutput.worldBitangentDir.w);
    //lightingData.worldNormal = vertexOutput.worldNormalDir;
	lightingData.worldLightDir = normalize(_MainLightPosition.xyz);
	lightingData.worldViewDir = normalize(_WorldSpaceCameraPos.xyz - lightingData.worldPos);

	// float3 TtoW1 = float3(vertexOutput.worldTangentDir.x,vertexOutput.worldBitangentDir.x,vertexOutput.worldNormalDir.x);
    // float3 TtoW2 = float3(vertexOutput.worldTangentDir.y,vertexOutput.worldBitangentDir.y,vertexOutput.worldNormalDir.y);
    // float3 TtoW3 = float3(vertexOutput.worldTangentDir.z,vertexOutput.worldBitangentDir.z,vertexOutput.worldNormalDir.z);

	lightingData.TtoW_Matrix = transpose(float3x3(vertexOutput.TtoW1, vertexOutput.TtoW2, vertexOutput.TtoW3));

	lightingData.worldNormal = mul(sampledNormal, lightingData.TtoW_Matrix);

	float3 H = normalize(lightingData.worldLightDir + lightingData.worldViewDir).xyz;
    lightingData.H = H;

	lightingData.R = normalize(reflect(-lightingData.worldViewDir, lightingData.worldNormal));

	lightingData.NoL = saturate(dot(lightingData.worldLightDir, lightingData.worldNormal));
	lightingData.NoV = saturate(dot(lightingData.worldNormal, lightingData.worldViewDir));
	lightingData.NoH = saturate(dot(lightingData.worldNormal, H));
	lightingData.LoH = saturate(dot(lightingData.worldLightDir, H));
    lightingData.RoV = saturate(dot(lightingData.worldViewDir, reflect(lightingData.worldLightDir, lightingData.worldNormal)));
	lightingData.VoH = saturate(dot(lightingData.worldViewDir, lightingData.H));
    
	return lightingData;
}

LightingData CalculateLightingData(VertexOutput vertexOutput, float3 sampledNormal, float3 worldLightDir)
{
    LightingData lightingData;

	lightingData.worldPos = float3(vertexOutput.worldNormalDir.w, vertexOutput.worldTangentDir.w, vertexOutput.worldBitangentDir.w);
    //lightingData.worldNormal = vertexOutput.worldNormalDir;
	//lightingData.worldLightDir = normalize(_MainLightPosition.xyz);
	lightingData.worldLightDir = normalize(worldLightDir);
	lightingData.worldViewDir = normalize(_WorldSpaceCameraPos.xyz - lightingData.worldPos);

	lightingData.TtoW_Matrix = float3x3(vertexOutput.TtoW1, vertexOutput.TtoW2, vertexOutput.TtoW3);

	lightingData.worldNormal = mul(lightingData.TtoW_Matrix, sampledNormal);

	float3 H = normalize(lightingData.worldLightDir + lightingData.worldViewDir);
    lightingData.H = H;

	lightingData.NoL = saturate(dot(lightingData.worldLightDir, lightingData.worldNormal));
	lightingData.NoV = saturate(dot(lightingData.worldNormal, lightingData.worldViewDir));
	lightingData.NoH = saturate(dot(lightingData.worldNormal, H));
	lightingData.LoH = saturate(dot(lightingData.worldLightDir, H));
    lightingData.RoV = saturate(dot(lightingData.worldViewDir, reflect(lightingData.worldLightDir, lightingData.worldNormal)));
	lightingData.VoH = saturate(dot(lightingData.worldViewDir, H));
	lightingData.ToH = dot(vertexOutput.worldTangentDir.xyz, H);
	lightingData.BoH = dot(vertexOutput.worldBitangentDir.xyz, H);
	lightingData.ToV = dot(vertexOutput.worldTangentDir.xyz, lightingData.worldViewDir);
    lightingData.BoV = dot(vertexOutput.worldBitangentDir.xyz, lightingData.worldViewDir);
    lightingData.ToL = dot(vertexOutput.worldTangentDir.xyz, lightingData.worldLightDir);
    lightingData.BoL = dot(vertexOutput.worldBitangentDir.xyz, lightingData.worldLightDir);
    
    lightingData.R = normalize(reflect(-lightingData.worldViewDir, lightingData.worldNormal));

	return lightingData;
}
