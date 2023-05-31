// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ToonBenDay"
{
    Properties
    {
        [Header(Surface Options)]
        _MainTex ("Main Texture", 2D) = "white" {}
        _ShadowTex ("Shadow Texture", 2D) = "white" {}
        _MainColor ("Main Color", Color) = (1, 1, 1, 1)
        [Toggle]_IsGloss("Is Glossy", Float) = 1
        _Gloss ("Gloss", Float) = 0.6
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"


            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _ShadowTex;
            float4 _ShadowTex_ST;
            
            float4 _MainColor;
            float _IsGloss;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;

            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = v.normal;
                o.worldPos = mul( unity_ObjectToWorld, v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed4 shadow = tex2D(_ShadowTex, i.uv);

                float3 normal = normalize(i.normal);

                float3 lightDir = _WorldSpaceLightPos0.xyz;;
                float3 lightColor = _LightColor0.xyz;
                float lightFalloff = dot(lightDir, normal);

                // Lambertion light
                float3 deffusse = lightColor * lightFalloff;

                // Specular light
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos); 
                float3 viewReflect = reflect(-viewDir, normal);
                float specularFalloff = saturate(dot(viewReflect, lightDir));
                float specular = pow(specularFalloff, _Gloss);

                if(lightFalloff >= 0.06)
                {
                    tex = tex;
                }
                else
                {
                    tex *= shadow;
                }

                if(specular >= 0.6)
                {
                    specular = 1 * _IsGloss;
                }
                else
                {
                    specular = 0 * _IsGloss;
                }


                return tex * _MainColor + specular;
            }
            ENDCG
        }

        // shadow caster rendering pass, implemented manually
        // using macros from UnityCG.cginc
        Pass
        {
            Tags {"LightMode"="ShadowCaster"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f { 
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }

        
    }
}
