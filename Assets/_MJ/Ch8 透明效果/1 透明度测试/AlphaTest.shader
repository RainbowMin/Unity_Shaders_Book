Shader "_MJ/Ch8/AlphaTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Main Tint", Color) = (1,1,1,1)
        _Cutoff ("Alpha CutOff", Range(0,1)) = 0.5 //决定我们调用clip进行透明度测试时使用的判断条件
    }
    SubShader
    {
        //通常， 使用了透明度测试的Shader都应该在SubShader中设置这三个标签
        Tags 
        {
        "Queue"="AlphaTest"        //在Unity中透明度测试使用的渲染队列是名为AlphaTest的队列
        "IgnoreProjector"="True"   //这个Shader不会受到投影器(Projectors)的影响
        "RenderType"="TransparentCutout"//RenderType标签可以让Unity把这个Shader归入到提前定义的组中，以指明该Shader是一个使用了透明度测试的Shader
        }

        Pass
        {
            //用于定义该Pass在Unity的光照流水线中的角色。 只有定义了正确的LightMode， 我们才能正确得到一些Unity的内置光照变量， 例如_LightColor0
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"//为了使用Unity内置的一些变量， 如_LightColor0

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            fixed _Cutoff;

            v2f vert (appdata v)
            {
                //在顶点着色器计算出世界空间的法线方向和顶点位置以及变换后的纹理坐标， 再把它们传递给片元着色器
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                fixed4 texColor = tex2D(_MainTex, i.uv);

                //Alpha test
                clip(texColor.a - _Cutoff);
                //等价于
                //if((texColor.a - _Cutoff) < 0.0)
                //{
                    //discard;
                //}

                //计算得到环境光照和漫反射光照， 把它们相加后再进行输出                
                fixed3 albedo = texColor.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

                return fixed4(ambient + diffuse, 1.0);
            }
            ENDCG
        }        
    }

    //这次我们使用内置的Transparent/Cutout/VertexLit来作为回调Shader
    //这不仅能够保证在我们编写的SubShader无法在当前显卡上工作时可以有合适的代替Shader,
    //还可以保证使用透明度测试的物体可以正确地向其他物体投射阴影
    Fallback "Transparent/Cutout/VertexLit"
}
