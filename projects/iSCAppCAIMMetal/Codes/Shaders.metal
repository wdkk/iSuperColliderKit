// Shaders.metal

#include <metal_stdlib>

using namespace metal;

struct VertexIn
{
    packed_float4 pos;
    packed_float4 rgba;
    packed_float2 uv;
};

struct VertexOut
{
    float4 pos [[position]];
    float4 rgba;
    float2 uv;
};

struct Uniforms
{
    float4x4 matrix;
};

struct Pixels
{
    packed_float4 rgba;
};

struct Particle
{
    float2 xy;
    float  radius;
    float  reserve;
    float4 rgba;
};

struct PixelInfo
{
    int2 size;
    float alpha;
};

///////////////////////////////////////////////////////////////////////////////

// 頂点シェーダ本体
vertex VertexOut vertexShader(device VertexIn *vin [[ buffer(0) ]],
                            constant Uniforms &uniforms [[ buffer(1) ]],
                                uint vidx [[vertex_id]])
{
    VertexOut vout;
    vout.pos = uniforms.matrix * float4(vin[vidx].pos);
    vout.rgba = vin[vidx].rgba;
    vout.uv = vin[vidx].uv;
    return vout;
}

// フラグメントシェーダ本体
fragment float4 fragmentShader(VertexOut vout [[ stage_in ]])
{
    float d2 = vout.uv.x * vout.uv.x + vout.uv.y * vout.uv.y;
    if(d2 >= 1.0)
    {
        discard_fragment();
    }
    
    float alpha = 1.0 - cos(d2 * 3.141592 / 2.0);
    
    return vout.rgba * float4(1.0, 1.0, 1.0, 1.0-alpha);
}
