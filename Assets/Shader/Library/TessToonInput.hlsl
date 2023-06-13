#ifndef CUSTOM_TESSTOON_INPUT_INCLUDED
#define CUSTOM_TESSTOON_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// テクスチャデータは、Matirial毎に違うことが多くデータ量が多くメモリを圧迫するためSRP Batcherを適用させない
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
TEXTURE2D(_HeightTex);
SAMPLER(sampler_HeightTex);

CBUFFER_START(UnityPerMaterial)
float4 _MainTex_ST;
float4 _HeightTex_ST;
float _DisplacementStrength;
half4 _MainColor;
float _Alpha;

// Tessellation
float _MinDist;
float _MaxDist;
float _TessStrength;

// Shade1
half4 _Shade1Color;
float _Shade1Amount;

// Shade2
half4 _Shade2Color;
float _Shade2Amount;

// Outline Properties
half4 _OutlineColor; 
float _OutlineRange;
CBUFFER_END

// 距離でTessellationの係数を変えるための関数
float TessellationFactor (float4 vertex, float minDist, float maxDist, float tess)
{
    float3 vertexWS = TransformObjectToWorld(vertex.xyz);
    float dist = distance(vertexWS, GetCameraPositionWS());
    return clamp((maxDist - minDist) / (dist * minDist), 0.01, 70) * tess;
}
#endif