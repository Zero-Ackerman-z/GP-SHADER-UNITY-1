Shader "Custom/TextureWithSpecularAndNormalMap"
{
    Properties
    {
        _MainTex("Flag Texture", 2D) = "white" {}
        _BumpMap("Normal Map", 2D) = "bump" { }
        _WindStrength("Wind Strength", Range(0, 1)) = 0.5
        _WaveSpeed("Wave Speed", Range(0, 10)) = 1.0
        _MySpecColor("Specular Color", Color) = (1, 1, 1, 1)
        _Shininess("Shininess", Range(1, 128)) = 32
        _AmbientColor("Ambient Color", Color) = (0.5, 0.5, 0.5, 1)
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

                sampler2D _MainTex;
                sampler2D _BumpMap;  // Normal map
                float _WindStrength;
                float _WaveSpeed;
                float4 _MySpecColor;
                float _Shininess;
                float4 _AmbientColor;

                v2f vert(appdata v)
                {
                    v2f o;

                    float wave = sin(v.uv.x * 10.0 + _Time.y * _WaveSpeed) * _WindStrength;
                    v.vertex.y += wave;

                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;

                    o.worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                    o.viewDir = normalize(_WorldSpaceCameraPos - o.worldPos);

                    return o;
                }

                float4 frag(v2f i) : SV_Target
                {
                    // Sample normal from the normal map
                    float3 normal = normalize(tex2D(_BumpMap, i.uv).rgb * 2.0 - 1.0);

                    // Combine with the original world normal
                    float3 N = normalize(i.worldNormal + normal);

                    float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                    float3 lightColor = _LightColor0.rgb;

                    float3 ambient = _AmbientColor.rgb * tex2D(_MainTex, i.uv).rgb;

                    float NdotL = max(0, dot(N, lightDir));
                    float3 diffuse = tex2D(_MainTex, i.uv).rgb * lightColor * NdotL;

                    float3 reflectDir = reflect(-lightDir, N);
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
