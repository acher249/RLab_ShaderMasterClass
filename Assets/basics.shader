Shader "RLab/basics"
{
    Properties
    {
        // Adam - Everything in properties is accesible in Untiy Editor
        // Similar to public variables - grab vertors etc.
        _MainTex ("Texture", 2D) = "white" {}

        // Expose this in editor.. default to zero values
        _ColorValues("Color Values", vector) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        // Cull Front
        // Cull Back
        // Cull Off

        // single pass shader
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // unity's built in function
            #include "UnityCG.cginc"

            // thing that go into the vert program and out of the vert program into the fragment shader
            // frag program learns what happens to the geometry based on the vert program
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            // redifne what comes in from the properties above.
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _ColorValues;
            float4 newColor;

            v2f vert (appdata v)
            {
                // creates new vert object from struct above.. has those attributes.. uv and vertex
                // o for out i for i
                v2f o;
                // o.vertex = UnityObjectToClipPos(v.vertex);
                
                // this is what is animating the object
                float3 offset = float3(0, sin(v.vertex.x*10+_Time.y*3)*.2,0);
                o.vertex = UnityObjectToClipPos(v.vertex + offset);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                // v is coming from the mesh
                // o.color = v.color;
                // o.color = float4(offset.y*5,0,0,0);
                o.color = float4(offset.y*5,0,0,0);
                return o;
            }


            // corloras and frag in frag section...
            // move verticies above in vert section.. animation etc, 
            // hard work in vertex shader
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture - return RGBA color
                // fixed4 col = tex2D(_MainTex, i.uv);

                // Waves
                float uvOffsetX = sin(_Time.w+i.uv.y*6.28*10)*.01;
                fixed4 col = tex2D(_MainTex, i.uv + float2(uvOffsetX, 0));
                // return .5;
                // return float4(i.uv.x, i.uv.y,-1,1);
                // return float4(sin(_Time.z), i.uv.y,0,0);
                // _Time.x = time*20 , _Time.x = time , _Time.z = time*2

                // Use exposed variables to manipulate shaders
                // float4 strobe = float4( sin(_Time.z*_ColorValues.x),0,0,0);
                // return col;
                return i.color;
            }
            ENDCG
        }
    }
}
