Shader "Custom/GeometryBreak"
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
            Tags{ "LightMode" = "UniversalForward"}

            HLSLPROGRAM
            #pragma vertex vert
            #pragma hull hull
            #pragma domain domain
            #pragma geometry geom
            #pragma fragment frag
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

            struct v2h
            {
                float4 vertex : POS;
                float2 uv : TEXCOORD0;
            };

            struct HsControlPointOut
            {
                float3 vertex : POS;
                float2 uv : TEXCOORD0;
            };

            struct HsConstantOut
            {
                float tessFactor[3] : SV_TessFactor;
                float insideTessFactor : SV_InsideTessFactor;
            };

            struct d2g
            {
                float3 vertex : POS;
                float2 uv : TEXCOORD0;
            };

            struct g2f
            {
                float2 uv : TEXCOORD0;
                float fogFactor : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float3 vertexWS : TEXCOORD2;
            };

            v2h vert (appdata v)
            {
                v2h o;

                o.vertex = v.vertex;
                o.uv = v.uv;

                return o;
            }

            [domain("tri")]
            [partitioning("integer")]
            [outputtopology("triangle_cw")]
            [patchconstantfunc("hullConst")]
            [outputcontrolpoints(3)]
            HsControlPointOut hull (InputPatch<v2h, 3> i, uint id : SV_OutputControlPointID)
            {
                HsControlPointOut o;
                
                o.vertex = i[id].vertex.xyz;
                o.uv = i[id].uv;
                
                return o;
            }

            HsConstantOut hullConst (InputPatch<v2h, 3> i)
            {
                HsConstantOut o;

                o.tessFactor[0] = _TessFactor;
                o.tessFactor[1] = _TessFactor;
                o.tessFactor[2] = _TessFactor;

                o.insideTessFactor = _InsideTessFactor;

                return o;
            }

            [domain("tri")]
            d2g domain (
                HsConstantOut hsConst,
                const OutputPatch<HsControlPointOut, 3> i,
                float3 bary : SV_DomainLocation)
            {
                d2g o;

                float3 positionOS =
                    bary.x * i[0].vertex +
                    bary.y * i[1].vertex +
                    bary.z * i[2].vertex;

                o.uv = 
                    bary.x * i[0].uv +
                    bary.y * i[1].uv + 
                    bary.z * i[2].uv;

                o.vertex = positionOS;
                
                return o;
            }

            [maxvertexcount(3)]
            void geom (triangle d2g input[3], inout TriangleStream<g2f> outStream)
            {
                // float3 vec1 = input[1].vertex - input[0].vertex;
                // float3 vec2 = input[2].vertex - input[0].vertex;
                // float3 poriNormal = normalize(cross(vec1, vec2));

                // float3 center = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;

                // float r = rand(center.xy);

                [unroll]
                for (int i = 0; i < 3; i++)
                {
                    g2f o;
                    
                    float3 vert = input[i].vertex;
                    // float3 vert = input[i].vertex + poriNormal * _Amount * _BreakStrength * r;

                    o.vertex = TransformObjectToHClip(vert);
                    o.vertexWS = TransformObjectToWorld(vert);
                    o.uv = TRANSFORM_TEX(input[i].uv, _MainTex);
                    o.fogFactor = ComputeFogFactor(o.vertex.xyz);
 
                    outStream.Append(o);
                }

                outStream.RestartStrip();
            }

            half4 frag (g2f i) : SV_Target
            {
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _MainColor;

                Light mainLight = GetMainLight();

                col.rgb = MixFog(col.rgb, i.fogFactor);

                col.rgb *= col.a;
                return col;
            }
            ENDHLSL
        }
    }
}
