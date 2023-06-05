Shader "Custom/Toon"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR]_MainColor ("MainColor", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _Alpha ("Alpha", Range(0, 1)) = 1
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
            #include "Assets/Shader/Library/ToonInput.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float fogFactor : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                // 頂点を法線方向に押し出す
                v.vertex += float4(v.normal * _OutlineRange, 0);

                o.vertex = TransformObjectToHClip(v.vertex);
                o.fogFactor = ComputeFogFactor(o.vertex.z);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = _OutlineColor;
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

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/Shader/Library/ToonInput.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float fogFactor : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.fogFactor = ComputeFogFactor(o.vertex.z);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _MainColor;
                col.a *= _Alpha; 
                col.rgb = MixFog(col.rgb, i.fogFactor);

                col.rgb *= col.a;
                return col;
            }
            ENDHLSL
        }
    }
}
