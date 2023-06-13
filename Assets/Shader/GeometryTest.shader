Shader "Unlit/GeometryTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR]_MainColor ("Color", Color) = (1, 1, 1, 1)
        _TessFactor ("TessFactor", Float) = 30.0
        _InsideTessFactor ("InsideTessFactor", Float) = 10.0
        _Amount ("Amount", Range(0, 1)) = 0.0
        _BreakStrength ("BreakStrength", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom
            // make fog work
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Assets/Shader/Library/GeometryBreakInput.hlsl"
            #include "Assets/Shader/Library/Random.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2g
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct g2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2g vert (appdata v)
            {
                v2g o;

                o.vertex = v.vertex;
                o.uv = v.uv;
                
                return o;
            }

            [maxvertexcount(3)]
            void geom (triangle v2g input[3], inout TriangleStream<g2f> outStream)
            {
                float3 vec1 = input[1].vertex - input[0].vertex;
                float3 vec2 = input[2].vertex - input[0].vertex;
                float3 poriNormal = normalize(cross(vec1, vec2));

                float3 center = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;

                float r = rand(center.xy);

                [unroll]
                for (int i = 0; i < 3; i++)
                {
                    g2f o;
                    
                    float3 dir = poriNormal * _Amount * _BreakStrength * r;

                    o.vertex = TransformObjectToHClip(dir + input[i].vertex);
                    o.uv = TRANSFORM_TEX(input[i].uv, _MainTex);
 
                    outStream.Append(o);
                }
            }

            half4 frag (g2f i) : SV_Target
            {
                // sample the texture
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                return col;
            }
            ENDHLSL
        }
    }
}
