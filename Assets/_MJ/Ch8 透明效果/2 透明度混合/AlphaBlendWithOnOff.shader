Shader "_MJ/Ch8/AlphaBlendWithOnOff"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Main Tint", Color) = (1,1,1,1)
        _AlphaScale ("Alpha Scale", Range(0,1)) = 1 //AlphaScale用于在透明纹理的基础上控制整体的透明度

        [Header(Blend Setting)]
        [Enum(UnityEngine.Rendering.BlendOp)] blendOperation("BlendOp", Float) = 0  //Add
		[Enum(UnityEngine.Rendering.BlendMode)] SrcBlend ("SrcBlend", Float) = 5    //SrcAlpha
		[Enum(UnityEngine.Rendering.BlendMode)] DstBlend ("DstBlend", Float) = 10   //OneMinusSrcAlpha
        [Enum(UnityEngine.Rendering.CullMode)] cullMode("CullMode", Float) = 2    //0=Off, 1= Front, 2=Back  默认背面剔除
    }
    SubShader
    {
        //通常， 使用了透明度混合的Shader都应该在SubShader中设置这3个标签。
        Tags 
        {
        "Queue"="Transparent"        //在Unity中透明度测试使用的渲染队列是名为AlphaTest的队列
        "IgnoreProjector"="True"   //这个Shader不会受到投影器(Projectors)的影响
        "RenderType"="Transparent"//RenderType标签可以让Unity把这个Shader归入到提前定义的组中，用来指明该Shader是一个使用了透明度混合的Shader。RenderType标签通常被用于着色器替换功能。
        }

        Pass
        {
            //为了让Unity能够按前向渲染路径的方式为我们正确提供各个光照变量
            Tags { "LightMode"="ForwardBase" }

            ZWrite Off

            //MJ 使用透明混合动态开关
            BlendOp [blendOperation]
            Blend [SrcBlend] [DstBlend]
            Cull [cullMode]

            //我们将源颜色（该片元着色器产生的颜色） 的混合因子设为SrcAlpha， 把目标颜色（已经存在于颜色缓冲中的颜色） 的混合因子设为OneMinusSrcAlpha， 以得到合适的半透明效果。
            //Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"//为了使用Unity内置的一些变量， 如_LightColor0

            struct appdata
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed _AlphaScale;

            v2f vert (appdata v)
            {
                //在顶点着色器计算出世界空间的法线方向和顶点位置以及变换后的纹理坐标， 再把它们传递给片元着色器
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 texColor = tex2D(_MainTex, i.uv);

                //计算得到环境光照和漫反射光照， 把它们相加后再进行输出                
                fixed3 albedo = texColor.rgb * _Color.rgb;

                return fixed4(albedo, texColor.a * _AlphaScale);
            }
            ENDCG
        }

        
    }

    Fallback "Transparent/VertexLit"
}
