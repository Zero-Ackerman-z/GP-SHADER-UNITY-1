Shader "Custom/ColorInterpolationShader"
{
    Properties
    {
        _ColorA("Color A", Color) = (1, 0, 0, 1) // Rojo
        _ColorB("Color B", Color) = (0, 0, 1, 1) // Azul
        _Interpolation("Interpolation Factor", Range(0, 1)) = 0.5
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
                float4 color : COLOR;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float4 color : COLOR;
            };

            fixed4 _ColorA;
            fixed4 _ColorB;
            float _Interpolation;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = lerp(_ColorA, _ColorB, _Interpolation); 
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
        FallBack "Diffuse"
}
