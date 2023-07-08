#ifndef CUSTOM_VERTLIGHTING_INCLUDED
#define CUSTOM_VERTLIGHTING_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

float4 VertLighting(float3 positionWS, half3 normalWS)
{
    float4 vertexLightColor = 0.0;

    uint lightCount = GetAdditionalLightsCount();

    for (uint i = 0U; i < lightCount; i++)
    {
        Light light = GetAdditionalLight(i, positionWS);
        half3 lightColor = light.color * light.distanceAttenuation;
        vertexLightColor.xyz += LightingLambert(lightColor, light.direction, normalWS);
        vertexLightColor.w += dot(normalWS, light.direction);
    }

    return vertexLightColor;
}

#endif