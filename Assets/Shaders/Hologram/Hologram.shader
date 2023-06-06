Shader "Custom/Hologram"
{
    Properties
    {
        [Header(Surface)]
        _MainTex ("Main Texture", 2D) = "white" {}
        _MainColor("Main Color", Color) = (0, 1, 1, 0) 
        [Header(Scanlines)]
        _HologramTex ("Scanelines Texture", 2D) = "white" {}
        _ScreenTexScale ("Screen Texture Scale", Vector) = (1, 1, 1, 1)
        _Speed ("Speed", Float) = 0.05
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent"}

        Cull Off
        ZWrite Off
        Blend One One

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _HologramTex;
            float4 _HologramTex_ST;
            float4 _MainColor;
            float4 _ScreenTexScale;
            float _Speed;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;            
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _HologramTex);
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 screenUV = i.screenPos.xy / i.screenPos.w;
                screenUV = screenUV * 0.5 + 0.5; // Normalize screen coordinates to [0, 1] range
                screenUV *= _ScreenTexScale.xy; // Scale the screen coordinates if desired

                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed4 hologram = tex2D(_HologramTex , screenUV - _Time.y * _Speed);

                return  tex.r * hologram * _MainColor;
            }
            ENDCG
        }
    }
}
