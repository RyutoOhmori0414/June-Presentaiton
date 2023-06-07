Shader "Custom/TessToon"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR]_MainColor ("MainColor", Color) = (1, 1, 1, 1)
        _HeightTex ("HeightTex", 2D) = "white" {}
        _DisplacementStrength ("DisplacementStrength", Float) = 1.0
        _Alpha ("Alpha", Range(0, 1)) = 1
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
        [Space(20)]
        [Header(Tessellation)]
        _MinDist ("MinDistance", Float) = 0.0
        _MaxDist ("MaxDistance", Float) = 40.0
        _TessStrength ("Strength", Float) = 1.0
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
            #pragma hull hull
            #pragma domain domain
            #pragma fragment frag
            // 奥行きのFogのキーワード定義
            #pragma multi_compile_fog
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Assets/Shader/Library/TessToonInput.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2h
            {
                float4 vertex : POS;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct HsControlPointOut
            {
                float3 vertex : POS;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct HsConstantOut
            {
                float tessFactor[3] : SV_TessFactor;
                float insideTessFactor : SV_InsideTessFactor;
            };

            struct d2f
            {
                float4 vertex : SV_POSITION;
                float fogFactor : TEXCOORD1;
            };

            v2h vert (appdata v)
            {
                // DomainShaderで変換を行うためvertexShaderでは変換を行わない
                v2h o;
                
                o.vertex = v.vertex;
                o.normal = v.normal;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

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
                o.normal = i[id].normal;
                o.uv = i[id].uv;

                return o;
            }

            HsConstantOut hullConst (InputPatch<v2h, 3> i)
            {
                HsConstantOut o;

                float4 p0 = i[0].vertex;
                float4 p1 = i[1].vertex;
                float4 p2 = i[2].vertex;

                float edge0 = TessellationFactor(p0, _MinDist, _MaxDist, _TessStrength);
                float edge1 = TessellationFactor(p1, _MinDist, _MaxDist, _TessStrength);
                float edge2 = TessellationFactor(p2, _MinDist, _MaxDist, _TessStrength);

                // 係数の調整
                o.tessFactor[0] = (edge1 + edge2) / 2;
                o.tessFactor[1] = (edge0 + edge2) / 2;
                o.tessFactor[2] = (edge0 + edge1) / 2;
                o.insideTessFactor = (edge0 + edge1 + edge2) / 3;

                return o;
            }

            [domain("tri")]
            d2f domain (
                HsConstantOut hsConst,
                const OutputPatch<HsControlPointOut, 3> i,
                float3 bary : SV_DomainLocation)
            {
                d2f o;

                float3 positionOS =
                    bary.x * i[0].vertex + 
                    bary.y * i[1].vertex +
                    bary.z * i[2].vertex;

                float3 normalOS = normalize(
                    bary.x * i[0].normal +
                    bary.y * i[1].normal +
                    bary.z * i[2].normal
                );

                float2 uv = bary.x * i[0].uv + bary.y * i[1].uv + bary.z * i[2].uv;


                float disp = SAMPLE_TEXTURE2D_LOD(_HeightTex, sampler_HeightTex, uv, 1);
                // 頂点方向に拡大している
                positionOS += normalOS * disp * _DisplacementStrength;
                positionOS += normalOS * _OutlineRange;
                o.vertex = TransformObjectToHClip(positionOS);
                o.fogFactor = ComputeFogFactor(o.vertex.z);

                return o;
            }

            half4 frag (d2f i) : SV_Target
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
            #pragma hull hull
            #pragma domain domain
            #pragma fragment frag
            // 奥行きのFogのキーワード定義
            #pragma multi_compile_fog
            // GPUInstancingに対応させる
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Assets/Shader/Library/TessToonInput.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2h
            {
                float4 vertex : POS;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct HsControlPointOut
            {
                float3 vertex : POS;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct HsConstantOut
            {
                float tessFactor[3] : SV_TessFactor;
                float insideTessFactor : SV_InsideTessFactor;
            };

            struct d2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float fogFactor : TEXCOORD1;
                float3 vertexWS : TEXCOORD2;
                float3 normal : NORMAL;
            };

            v2h vert (appdata v)
            {
                v2h o;
                
                // 変換はDomainShaderで行う
                o.vertex = v.vertex;
                o.uv = v.uv;
                o.normal = v.normal;

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
                o.normal = i[id].normal;
                o.uv = i[id].uv;

                return o;
            }

            HsConstantOut hullConst (InputPatch<v2h, 3> i)
            {
                HsConstantOut o;

                float4 p0 = i[0].vertex;
                float4 p1 = i[1].vertex;
                float4 p2 = i[2].vertex;

                float edge0 = TessellationFactor(p0, _MinDist, _MaxDist, _TessStrength);
                float edge1 = TessellationFactor(p1, _MinDist, _MaxDist, _TessStrength);
                float edge2 = TessellationFactor(p2, _MinDist, _MaxDist, _TessStrength);

                o.tessFactor[0] = (edge1 + edge2) / 2;
                o.tessFactor[1] = (edge0 + edge2) / 2;
                o.tessFactor[2] = (edge0 + edge1) / 2;
                o.insideTessFactor = (edge0 + edge1 + edge2) / 3;

                return o;
            }

            [domain("tri")]
            d2f domain(
                HsConstantOut hsConst,
                const OutputPatch<HsControlPointOut, 3> i,
                float3 bary : SV_DomainLocation)
            {
                d2f o;

                float3 positionOS =
                    bary.x * i[0].vertex + 
                    bary.y * i[1].vertex +
                    bary.z * i[2].vertex;

                float3 normalOS = normalize(
                    bary.x * i[0].normal +
                    bary.y * i[1].normal +
                    bary.z * i[2].normal
                );

                float2 uv =
                    bary.x * i[0].uv +
                    bary.y * i[1].uv +
                    bary.z * i[2].uv;

                o.uv = TRANSFORM_TEX(uv, _MainTex);

                float disp = SAMPLE_TEXTURE2D_LOD(_HeightTex, sampler_HeightTex, o.uv, 1);
                positionOS += normalOS * disp * _DisplacementStrength;

                o.vertex = TransformObjectToHClip(positionOS);
                o.fogFactor = ComputeFogFactor(o.vertex.xyz);
                o.vertexWS = TransformObjectToWorld(positionOS);
                o.normal = TransformObjectToWorldNormal(normalOS);

                return o;
            }

            half4 frag (d2f i) : SV_Target
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
