Shader "_MJ/Ch11/ScrollingBg"
{
    Properties
    {
        _MainTex ("Base Layer (RGB)", 2D) = "white" {}//第一层（ 较远）的背景纹理
        _DetailTex ("2nd Layer (RGB)", 2D) = "white" {}//第二层（ 较近） 的背景纹理
        _ScrollX ("Base layer Scroll Speed", Float) = 1.0//水平滚动速度
        _Scroll2X ("2nd layer Scroll Speed", Float) = 1.0//水平滚动速度
        _Multiplier ("Layer Multiplier", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DetailTex;
            float4 _DetailTex_ST;
            fixed _ScrollX;
            fixed _Scroll2X;
            fixed4 _Multiplier;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //在水平方向上对纹理坐标进行偏移， 以此达到滚动的效果
                //两张纹理的纹理坐标存储在同一个变量o.uv中， 以减少占用的插值寄存器空间
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + frac(float2(_ScrollX, 0.0) * _Time.y);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetailTex) + frac(float2(_Scroll2X, 0.0) * _Time.y);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 firstLayer = tex2D(_MainTex, i.uv.xy);
                fixed4 secondLayer = tex2D(_DetailTex, i.uv.zw);

                //使用第二层纹理的透明通道来混合两张纹理， 这使用了CG的lerp函数
                fixed4 col = lerp(firstLayer, secondLayer, secondLayer.a);

                //使用_Multiplier参数和输出颜色进行相乘， 以调整背景亮度
                col.rgb * _Multiplier;
                return col;
            }
            ENDCG
        }
    }
}
