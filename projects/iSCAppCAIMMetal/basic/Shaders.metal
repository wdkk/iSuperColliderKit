// Shaders.metal
#include <metal_stdlib>

using namespace metal;

// バッファID番号
constant int ID_VERTEX = 0;
constant int ID_PROJECTION = 1;

// 入力頂点情報
struct VertexIn {
    packed_float4 pos;
    packed_float2 uv;
    packed_float4 rgba;
};

// 出力頂点情報
struct VertexOut {
    float4 pos [[position]];
    float2 uv;
    float4 rgba;
};

// 頂点シェーダー(2Dピクセル座標系へ変換)
vertex VertexOut vert2d(device VertexIn *vin [[ buffer(ID_VERTEX) ]],
                        constant float4x4 &proj_matrix [[ buffer(ID_PROJECTION) ]],
                        uint vid [[vertex_id]])
{
    VertexOut vout;
    vout.pos  = proj_matrix * float4(vin[vid].pos);
    vout.uv   = vin[vid].uv;
    vout.rgba = vin[vid].rgba;
    return vout;
}

// フラグメントシェーダー(素通り)
fragment float4 fragStandard(VertexOut vout [[ stage_in ]]) {
    return vout.rgba;
}

// フラグメントシェーダー(円を描く)
fragment float4 fragCircle(VertexOut vout [[ stage_in ]]) {
    // 中心からのuv距離
    float dist2 = vout.uv[0] * vout.uv[0] + vout.uv[1] * vout.uv[1];
    // uv距離が1.0以上 = 円の外 (discard_fragment()を呼ぶとピクセルが破棄される)
    if(dist2 >= 1.0) { discard_fragment(); }
    
    return vout.rgba;
}

// フラグメントシェーダー(Cosカーブを使って滑らかな変化の円を描く)
fragment float4 fragCircleCosCurve(VertexOut vout [[ stage_in ]]) {
    // 中心からのuv距離
    float dist2 = vout.uv[0] * vout.uv[0] + vout.uv[1] * vout.uv[1];
    // uv距離が1.0以上 = 円の外 (discard_fragment()を呼ぶとピクセルが破棄される)
    if(dist2 >= 1.0) { discard_fragment(); }
    // 新しい色情報をつくる
    float4 rgba = vout.rgba;
    rgba[3] = vout.rgba[3] * (1.0 + cos(M_PI_F * dist2)) / 2.0;
    return rgba;
}

// フラグメントシェーダー(リングを描く)
fragment float4 fragRing(VertexOut vout [[ stage_in ]]) {
    // 中心からのuv距離
    float dist2 = vout.uv[0] * vout.uv[0] + vout.uv[1] * vout.uv[1];
    // uv距離が0.8以下か1.0以上ならピクセル破棄(リングの外)
    if(dist2 <= 0.8 || 1.0 <= dist2) { discard_fragment(); }
    
    // リングの中心骨はdist2=0.9とする。kは中心骨との距離。これを10倍するとk=0.0~1.0になる。
    // このkをcosに用いてリングを柔らかくする
    float k = fabs(0.9 - dist2) * 10.0;
    // 新しい色情報をつくる
    float4 rgba = vout.rgba;
    rgba[3] = vout.rgba[3] * (1.0 + cos(M_PI_F * k)) / 2.0;
    return rgba;
}

