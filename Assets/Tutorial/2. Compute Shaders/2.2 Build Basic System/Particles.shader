Shader "Unlit/Particles"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {},
        _Scale ("Scale", float) = 0.05; 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            float _Scale;

            struct particle
            {
                float3 position;
                float3 velocty;
            };

            StructuredBuffer<particle> ParticleBuffer;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                //  to access the buffer
                uint iid : SV_InstanceID;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            // helpful utilities 

            #include "../Shared/Matrix.hlsl"

            v2f vert (appdata v)
            {
                particle p = ParticleBuffer[v.iid];

                // make particle face camera
                float3 pToCam = normalize(p.position - _WorldSpaceCameraPos);
                float3 quadNorm = float3(0,0,1);

                // Angle Between
                float angle = acos(dot(quadNorm, pToCam));
                float3 axis = normalize(cross(quadNorm, pToCam));

                // transform with matrix
                float4x4 transform = scale_rotate_translate(
                    float3(_Scale,_Scale,_Scale),
                    angle,
                    axis,
                    p.position
                )

                v.vertex = mul(transform, v.vertex);

                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
