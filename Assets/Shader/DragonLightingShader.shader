Shader "Custom/DragonLightingWithNormalMap"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}             
        _MySpecColor("Specular Color", Color) = (1, 1, 1, 1)  
        _Shininess("Shininess", Range(1, 128)) = 32         
        _AmbientColor("Ambient Color", Color) = (0.3, 0.3, 0.3, 1) 
        _NormalMap("Normal Map", 2D) = "bump" {}         
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
                float3 worldPos : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
            };

            // Propiedades
            sampler2D _MainTex;
            sampler2D _NormalMap;    
            float4 _MySpecColor;     
            float _Shininess;
            float4 _AmbientColor;

            v2f vert(appdata v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                o.worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                o.viewDir = normalize(_WorldSpaceCameraPos - o.worldPos);

                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0.rgb;

                float3 baseColor = tex2D(_MainTex, i.uv).rgb;

                float3 normal = tex2D(_NormalMap, i.uv).xyz * 2.0 - 1.0;
                normal = normalize(normal);  // Normalizar la normal del mapa

                float3 ambient = _AmbientColor.rgb * baseColor;

                float NdotL = max(0, dot(normal, lightDir));
                float3 diffuse = baseColor * lightColor * NdotL;

                float3 reflectDir = reflect(-lightDir, normal);
                float specFactor = pow(max(dot(reflectDir, i.viewDir), 0), _Shininess);
                float3 specular = _MySpecColor.rgb * specFactor * lightColor;

                float3 finalColor = ambient + diffuse + specular;

                return float4(finalColor, 1.0);
            }
            ENDCG
        }
    }
        FallBack "Diffuse"
}
