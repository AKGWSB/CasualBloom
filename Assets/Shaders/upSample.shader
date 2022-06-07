Shader "Shaders/upSample"
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

            int _upSampleBlurSize;
            float _upSampleBlurSigma;

            sampler2D _MainTex;         // 处理前的 mip[i], 尺寸为 (w, h)
            sampler2D _PrevMip;         // 处理后的 mip[i+1], 尺寸为 (w/2, h/2)
            float4 _MainTex_TexelSize;  // float4(1/w, 1/h, w, h)

            float4 frag (v2f i) : SV_Target
            {
                float4 color = float4(0,0,0,1);
                float2 uv = i.uv;

                // 上一级 mip 纹理的 texel size 是本级的一半
                float2 prev_stride = 0.5 * _MainTex_TexelSize.xy;   
                float2 curr_stride = 1.0 * _MainTex_TexelSize.xy;  

                float3 prev_mip = GaussNxN(_PrevMip, uv, _upSampleBlurSize, prev_stride, _upSampleBlurSigma);
                float3 curr_mip = GaussNxN(_MainTex, uv, _upSampleBlurSize, curr_stride, _upSampleBlurSigma);
                color.rgb = prev_mip + curr_mip;

                return color;
            }
            ENDCG
        }
    }
}
