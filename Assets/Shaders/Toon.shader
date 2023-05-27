Shader "Unlit/Toon"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ShadowTex ("Shadow", 2D) = "white" {}
        _Color ("Base Color", Color) = (1, 1, 1, 1)
        [Toggle] _IsGloss("Is Glossy", Float) = 0
        _Gloss ("Gloss", Float) = 1
        _ShadowCutOff ("Shadow Cut Off", Range(0, 1)) = .6
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            sampler2D _ShadowTex;
            float4 _Color;
            float _IsGloss;
            float _Gloss;
            float _ShadowCutOff;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 worldPos: TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = v.normal;
                o.worldPos =  mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 tex = tex2D(_MainTex, i.uv); 
                fixed4 shadow = tex2D(_ShadowTex, i.uv); 
                float3 normal = normalize(i.normal);

                // Lights
                float3 lightDir = _WorldSpaceLightPos0; // For directional light this s a vector
                float4 lightColor = _LightColor0;

                // Defusse light
                float lightFallOff = saturate(dot(lightDir, normal));
                //lightFallOff = step(0.01, lightFallOff); // Cel shading part
                //float4 deffuseLight = lightFallOff * lightColor;
                if(lightFallOff < _ShadowCutOff)
                {
                    tex *= shadow;
                }

                // Specular light (Phong)
                float3 viewDir = normalize(i.worldPos - _WorldSpaceCameraPos); // Vector from the fragment to the camera
                float3 viewReflect = reflect(viewDir, normal);
                float specularFallOff = saturate(dot(viewReflect, lightDir));
                specularFallOff = pow(specularFallOff, _Gloss); // Remaped Gloss
                specularFallOff = step(0.1, specularFallOff) * _IsGloss; // Cel shading part
                float4 specularLight = specularFallOff * lightColor;

                // Outline

                //return float4(specularFallOff.xxx, 0);
                return tex * _Color + specularLight;
            }
            ENDCG
        }
    }
}
