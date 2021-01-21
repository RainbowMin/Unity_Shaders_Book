Shader "_MJ/Ch11/ImageSequenceAnimation"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Image Sequence", 2D) = "white" {}
        _HorizontalAmount ("Horizontal Amount", Float) = 4//该图像在水平方向的关键帧图像的个数
        _VerticalAmount ("Vertical Amount", Float) = 4//该图像在竖直方向包含的关键帧图像的个数
        _Speed ("Speed", Range(1, 100)) = 30//控制序列帧动画的播放速度
    }
    SubShader
    {
        //序列帧图像通常是透明纹理
        //序列帧图像通常包含了透明通道， 因此可以被当成是一个半透明对象。 
        //在这里我们使用半透明的“标配”来设置它的SubShader标签， 即把Queue和RenderType设置成Transparent， 把IgnoreProjector设置为True。 
        //在Pass中， 我们使用 Blend命令来开启并设置混合模式， 同时关闭了深度写入。
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        LOD 100

        Pass
        {            
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed _HorizontalAmount;
            fixed _VerticalAmount;
            fixed _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //_Time.y就是自该场景加载后所经过的时间
                float time = floor(_Time.y * _Speed);//取整来得到整数的模拟时间
                float row = floor(time / _HorizontalAmount);//求出当前对应的行索引
                float column = time - row * _HorizontalAmount;//余数则是列索引

                //写法1
                half2 uv = float2(i.uv.x / _HorizontalAmount, i.uv.y / _VerticalAmount);//先把原纹理坐标i.uv按行数和列数进行等分， 得到每个子图像的纹理坐标范围
                //我们需要使用当前的行列数对上面的结果进行偏移， 得到当前子图像的纹理坐标
                uv.x += column / _HorizontalAmount;
                uv.y -= row / _VerticalAmount;//Unity中纹理坐标竖直方向的顺序（从下到上逐渐增大） 和序列帧纹理中的顺序（播放顺序是从上到下） 是相反的。所以用减法

                //写法2
                //half2 uv = i.uv + half2(column, -row);
                //uv.x /= _HorizontalAmount;
                //uv.y /= _VerticalAmount;

                fixed4 c = tex2D(_MainTex, uv);
                c.rgb *= _Color;
                return c;
            }
            ENDCG
        }
    }
}
