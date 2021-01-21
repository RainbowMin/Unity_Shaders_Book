Shader "_MJ/Ch11/Water"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}//河流纹理
        _Color ("Color Tint", Color) = (1, 1, 1, 1)//控制整体颜色
        _Magnitude ("Distortion Magnitude", Float) = 1//控制水流波动的幅度
        _Frequency ("Distortion Frequency", Float) = 1//用于控制波动频率
        _InvWaveLength ("Distortion Inverse Wave Length", Float) = 10//控制波长的倒数（_InvWaveLength越大， 波长越小） 
        _Speed ("Speed", Float) = 0.5//控制水里面的河流纹理的移动速度
    }
    SubShader
    {
        //批处理会合并所有相关的模型， 而这些模型各自的模型空间就会丢失。 
        //而在本例中， 我们需要在物体的模型空间下对顶点位置进行偏移。 
        //因此，在这里需要取消对该Shader的批处理操作
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True"}

        Pass
        {
            //关闭了深度写入， 开启并设置了混合模式， 并关闭了剔除功能。 这是为了让水流的每个面都能显示。
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

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
            float _Frequency;
            float _InvWaveLength;
            float _Speed;
            float _Magnitude;
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;

                //我们只希望对顶点的x方向进行位移， 因此yzw的位移量被设置为0
                //然后，我们利用_Frequency属性和内置的_Time.y变量来控制正弦函数的频率
                //为了让不同位置具有不同的位移，我们对上述结果加上了模型空间下的位置分量， 并乘以_InvWaveLength来控制波长
                //最后， 我们对结果值乘以_Magnitude属性来控制波动幅度， 得到最终的位移
                //剩下的工作， 我们只需要把位移量添加到顶点位置上， 再进行正常的顶点变换即可
                v.vertex.x += sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z* _InvWaveLength) * _Magnitude;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //我们还进行了纹理动画， 即使用_Time.y和_Speed来控制在水平方向上的纹理动画
                o.uv += float2(0.0, _Time.y * _Speed);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= _Color.rgb;
                return col;
            }
            ENDCG
        }
    }
}
