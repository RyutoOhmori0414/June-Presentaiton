Shader "Unlit/GeometryBreak"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma hull hull
            #pragma domain domain
            #pragma geometry geom
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : POS;
            };

            struct HsControlPointOut
            {
                float3 vertex : POS;
            };

            struct HsConstantOut
            {
                float tessFactor[3] : SV_TessFactor;
                float insideTessFactor : SV_InsideTessFactor;
            };

            struct d2g
            {
                float3 vertex : POS;
            };

            struct g2f
            {
                float fogFactor : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2h vert (appdata v)
            {
                v2h o;

                o.vertex = v.vertex;
            }

            [domain("tri")]
            [partitioning("integer")]
            [outputtopology("triangle_cw")]
            [patchconstantfunc("hullConst")]
            [outputcontrolpoints(3)]
            HsControlPointOut hull (InputPatch<v2h, 3> i, uint id : SV_OutputControlPointID)
            {
                HsControlPointOut o;
                
                o.vertex = i[id].vertex;
                
                return o;
            }

            HsConstantOut hullConst (InputPatch<v2h, 3> i)
            {
                HsConstantOut o;

                o.tessFactor[0] =
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDHLSL
        }
    }
}
