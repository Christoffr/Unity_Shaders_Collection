Shader "Custom/Hologram"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _MainColor("Hologram Color", Color) = (0, 0, 1, 0)
        _Alpha ("Hologram Alpha", Range(0.0, 1.0)) = 1
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
            float4 _MainColor;
            fixed4 _Alpha;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;                
                float2 uv : TEXCOORD0;
                float2 screenUV : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                return float4(_MainColor);
            }
            ENDCG
        }
    }
}
