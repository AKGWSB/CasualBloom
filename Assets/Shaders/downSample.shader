Shader "Shaders/downSample"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            int _downSampleBlurSize;
            float _downSampleBlurSigma;

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;

            float GaussWeight2D(float x, float y, float sigma)
            {
                float PI = 3.14159265358;
                float E  = 2.71828182846;
                float sigma_2 = pow(sigma, 2);

                float a = -(x*x + y*y) / (2.0 * sigma_2);
                return pow(E, a) / (2.0 * PI * sigma_2);
            }

            float3 GaussNxN(sampler2D tex, float2 uv, int n, float2 stride, float sigma)
            {
                float3 color = float3(0, 0, 0);
                int r = n / 2;
                float weight = 0.0;

                for(int i=-r; i<=r; i++)
                {
                    for(int j=-r; j<=r; j++)
                    {
                        float w = GaussWeight2D(i, j, sigma);
                        float2 coord = uv + float2(i, j) * stride;
                        color += tex2D(tex, coord).rgb * w;
                        weight += w;
                    }
                }

                color /= weight;
                return color;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 color = float4(0,0,0,1);
                float2 uv = i.uv;
                float2 stride = _MainTex_TexelSize.xy;   // 上一级 mip 纹理的 texel size

                color.rgb = GaussNxN(_MainTex, uv, _downSampleBlurSize, stride, _downSampleBlurSigma);

                return color;
            }
            ENDCG
        }
    }
}
