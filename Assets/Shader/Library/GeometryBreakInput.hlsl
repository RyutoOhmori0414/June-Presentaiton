#ifndef CUSTOM_GEOMETRYBREAK_INPUT_INCLUDED
#define CUSTOM_GEOMETRYBREAK_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

CBUFFER_START(UnityPerMaterial)
float4 _MainTex_ST;
half4 _MainColor;
float _TessFactor;
float _InsideTessFactor;
float _Amount;
float _BreakStrength;

CBUFFER_END

#endif