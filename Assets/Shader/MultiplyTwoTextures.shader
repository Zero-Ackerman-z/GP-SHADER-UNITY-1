Shader "Custom/MultiplyTwoTextures"
{
    Properties
    {
        _MainTex("Texture A", 2D) = "white" {}
        _SecondTex("Texture B", 2D) = "white" {} 
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;    
            sampler2D _SecondTex;  

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 texColorA = tex2D(_MainTex, i.uv);
                fixed4 texColorB = tex2D(_SecondTex, i.uv);

                return texColorA * texColorB;
            }
            ENDCG
        }
    }
        FallBack "Diffuse"
}

