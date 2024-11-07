Shader "Custom/TextureWithSpecular"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}         
        _CustomSpecColor("Specular Color", Color) = (1, 1, 1, 1) 
        _Shininess("Shininess", Range(1, 128)) = 32       // Controla la intensidad y el tamaño del brillo
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 200

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "Lighting.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float2 uv : TEXCOORD0;
                    float3 worldNormal : TEXCOORD1;
                    float3 viewDir : TEXCOORD2;
                };

                sampler2D _MainTex;
                float4 _CustomSpecColor;  // Cambiado a _CustomSpecColor
                float _Shininess;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.pos = UnityObjectToClipPos(v.vertex);

                    // Transforma la normal y la dirección de la vista al espacio mundial
                    o.worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                    float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    o.viewDir = normalize(_WorldSpaceCameraPos - worldPos);

                    o.uv = v.uv;
                    return o;
                }

                float4 frag(v2f i) : SV_Target
                {
                    float4 texColor = tex2D(_MainTex, i.uv);

                    float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                    float3 reflectDir = reflect(-lightDir, i.worldNormal);
                    float specFactor = pow(max(dot(reflectDir, i.viewDir), 0), _Shininess);
                    float3 specular = _CustomSpecColor.rgb * specFactor;  

                    float3 finalColor = texColor.rgb + specular;

                    return float4(finalColor, texColor.a);
                }
                ENDCG
            }
        }
            FallBack "Diffuse"
}

