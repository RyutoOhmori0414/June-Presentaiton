#ifndef CUSTOM_DISSOLVETOON_INPUT_INCLUDED
#define CUSTOM_DISSOLVETOON_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

// テクスチャデータは、Matirial毎に違うことが多くデータ量が多くメモリを圧迫するためSRP Batcherを適用させない
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
TEXTURE2D(_DissolveTex);
SAMPLER(sampler_DissolveTex);

CBUFFER_START(UnityPerMaterial)
half4 _MainTex_ST;
half4 _MainColor;
float _Alpha;

// Dissolve
float4 _DissolveTex_ST;
float _Amount;
float _DissolveRange;
half4 _DissolveColor;

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

float remap (float value, float outMin, float outMax)
{
    return value * ((outMax - outMin) / 1) + outMin;
}

#endif