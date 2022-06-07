Shader "Shaders/blur"
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

            float4 frag (v2f i) : SV_Target
            {
                float4 color = float4(0,0,0,1);
                float2 uv = i.uv;

                //return tex2D(_MainTex, uv);

                int R = 100;
                //float weight = 1.0 / float(pow(R*2+1, 2));
                //float weight = 0.0;
                
                for(int i=-R; i<=R; i++)
                {
                    for(int j=-R; j<=R; j++)
                    {
                        float2 offset = float2(i, j) * _MainTex_TexelSize.xy;
                        float2 coord = uv + offset;

                        float w = GaussWeight2D(i, j, 30);
                        color.rgb += tex2D(_MainTex, coord).rgb * w;
                        //weight += w;
                        //color.rgb += tex2D(_MainTex, coord).rgb * weight;
                    }
                }
                //color.rgb /= weight;

                return color;
            }
            ENDCG
        }
    }
}
