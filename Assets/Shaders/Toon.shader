Shader "Unlit/Toon"
{
    Properties 
    {
        [Header(Surface options)]
        [MainTexture] _MainTex ("Main Texture", 2D) = "white" {} 
        [MainColor] _MainColor("Main Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags{"RenderPipeline" = "UniversalPipeline"}

        Pass
        {
            Name "ForwardLit" // For debugging
            Tags{"LightMode" = "UniversalForward"} // Tells Unity this is the main lighting pass of this shader

            // Begin HLSL code
            HLSLPROGRAM 
            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;
            float4 _MainColor;

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolators Vertex(Attributes input) 
            {
                Interpolators output;

                VertexPositionInputs posnInputs = GetVertexPositionInputs(input.positionOS);
                
                output.positionCS = posnInputs.positionCS;
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);

                return output;
            }

            float4 Fragment(Interpolators input) : SV_TARGET 
            {
                // Sample the texture
                float2 uv = input.uv;
                float4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
                
                return tex * _MainColor;
            }

            ENDHLSL
        }

    }
}
