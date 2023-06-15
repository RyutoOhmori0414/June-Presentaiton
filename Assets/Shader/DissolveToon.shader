Shader "Custom/DissolveToon"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR]_MainColor ("MainColor", Color) = (1, 1, 1, 1)
        _Alpha ("Alpha", Range(0, 1)) = 1
        [Space(20)]
        [Header(Dissolve)]
        _DissolveTex ("DissolveTex", 2D) = "white" {}
        _Amount ("Amount", Range(0, 1)) = 0
        _DissolveRange ("Range", Range(0, 1)) = 0
        [HDR] _DissolveColor ("DissolveColor", Color) = (0, 0, 0, 0)
        [Space(20)]
        [Header(Shade1)]
        _Shade1Color ("Color", Color) = (0, 0, 0, 0)
        _Shade1Amount ("Amount", Range(0, 1)) = 0.3
        [Space(10)]
        [Header(Shade2)]
        _Shade2Color ("Color", Color) = (0, 0, 0, 0)
        _Shade2Amount ("Amount", Range(0, 1)) = 0.3
        [Space(20)]
        [Header(Outline)]
        [HDR]_OutlineColor ("OutlineColor", Color) = (0, 0, 0, 1)
        _OutlineRange ("Outline", Float) = 0.0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
        }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

        // Outlineを描画するPass
        Pass
        {
            Tags { "LightMode" = "ToonOutline"}
            Cull Front

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // 奥行きのFogのキーワード定義
            #pragma multi_compile_fog
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/Shader/Library/DissolveToonInput.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 duv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 duv : TEXCOORD0;
                float fogFactor : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                // 頂点を法線方向に押し出す
                v.vertex += float4(v.normal * _OutlineRange, 0);

                o.vertex = TransformObjectToHClip(v.vertex);
                o.duv = TRANSFORM_TEX(v.duv, _MainTex);
                o.fogFactor = ComputeFogFactor(o.vertex.z);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = _OutlineColor;

                float dAlpha = SAMPLE_TEXTURE2D(_DissolveTex, sampler_DissolveTex, i.duv).r;
                if (dAlpha < _Amount)
                {
                    col.a = 0;
                }

                col.a *= _Alpha;
                col.rgb = MixFog(_OutlineColor.rgb, i.fogFactor);

                col.rgb *= col.a;
                return col;
            }
            ENDHLSL
        }

        // モデル自体を描画するPass
        Pass
        {
            Tags{ "LightMode" = "UniversalForward"}

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // 奥行きのFogのキーワード定義
            #pragma multi_compile_fog
            // GPUInstancingに対応させる
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Assets/Shader/Library/DissolveToonInput.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 duv : TEXCOORD3;
                float4 vertex : SV_POSITION;
                float fogFactor : TEXCOORD1;
                float3 vertexWS : TEXCOORD2;
                float3 normal : NORMAL;
            };

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.duv = TRANSFORM_TEX(v.uv, _DissolveTex);
                o.fogFactor = ComputeFogFactor(o.vertex.z);
                o.vertexWS = TransformObjectToWorld(v.vertex.xyz);
                o.normal = TransformObjectToWorldNormal(v.normal);
                
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _MainColor;

                Light mainLight = GetMainLight();
                float dotValue = dot(i.normal, mainLight.direction);

                // 一影
                if (dotValue >= _Shade1Amount)
                {
                    col.rgb *= mainLight.color;
                }
                else
                {
                    // 二影
                    if (dotValue / _Shade1Amount > _Shade2Amount)
                    {
                        col.rgb *= _Shade1Color.rgb;
                    }
                    else
                    {
                        col.rgb *= _Shade2Color.rgb;
                    }
                }
                
                float dAlpha = SAMPLE_TEXTURE2D(_DissolveTex, sampler_DissolveTex, i.duv);
                float amount = remap(_Amount, -_DissolveRange, 1);
                if (dAlpha < amount + _DissolveRange)
                {
                    col.rgb += _DissolveColor.rgb;

                    if (dAlpha < amount)
                    {
                        col.a = 0;
                    }
                }

                Light addLight = GetAdditionalLight(0, i.vertexWS);

                col.a *= _Alpha; 
                col.rgb = MixFog(col.rgb, i.fogFactor);

                col.rgb *= col.a;
                return col;
            }
            ENDHLSL
        }
    }
}
