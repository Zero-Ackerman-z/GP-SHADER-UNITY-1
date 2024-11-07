Shader "Custom/WavingFlagShader"
{
    Properties
    {
        _MainTex("Flag Texture", 2D) = "white" {} 
        _WindStrength("Wind Strength", Range(0, 1)) = 0.5 
        _WaveSpeed("Wave Speed", Range(0, 10)) = 1.0 
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
                    float4 pos : SV_POSITION;
                    float2 uv : TEXCOORD0;
                };

                sampler2D _MainTex;         
                float _WindStrength;         
                float _WaveSpeed;            

                v2f vert(appdata v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);

                    float wave = sin(v.uv.x * 10.0 + _Time.y * _WaveSpeed) * _WindStrength;
                    v.vertex.y += wave; 
                    o.pos = UnityObjectToClipPos(v.vertex); 

                    o.uv = v.uv;
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    fixed4 texColor = tex2D(_MainTex, i.uv);
                    return texColor;
                }
                ENDCG
            }
        }
            FallBack "Diffuse"
}
