//
// Shaders.metal
// CAIM Project
//   https://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//
// This software is released under the MIT License.
//   https://opensource.org/licenses/mit-license.php
//

#include <metal_stdlib>

using namespace metal;

// 入力頂点情報
struct VertexIn {
    float2 pos;
    float2 uv;
    float4 rgba;
};

// 出力頂点情報
struct VertexOut {
    float4 pos [[position]];
    float2 uv;
    float4 rgba;
};

// 頂点シェーダー(2Dピクセル座標系)
vertex VertexOut vert2d(device VertexIn *vin [[ buffer(0) ]],
                        constant float4x4 &proj_matrix [[ buffer(1) ]],
                        uint idx [[ vertex_id ]]) {
    VertexOut vout;
    // float2に、z=0,w=1を追加 → float4を作成し、行列を使って座標変換
    vout.pos = proj_matrix * float4(vin[idx].pos, 0, 1);
    vout.uv  = vin[idx].uv;
    vout.rgba = vin[idx].rgba;
    return vout;
}

// フラグメントシェーダー(無加工)
fragment float4 fragStandard(VertexOut vout [[ stage_in ]]) {
    // voutで受け取った色をそのまま結果とする(returnで返した色が画面に反映される)
    return vout.rgba;
}

// フラグメントシェーダー(円を描く)
fragment float4 fragCircle(VertexOut vout [[ stage_in ]]) {
    // 中心からのuv距離の二乗
    float dist2 = vout.uv[0] * vout.uv[0] + vout.uv[1] * vout.uv[1];
    // uv距離の二乗が1.0以上 = 円の外 (discard_fragment()を呼ぶとピクセルが破棄される)
    if(dist2 >= 1.0) { discard_fragment(); }
    
    return vout.rgba;
}

// フラグメントシェーダー(Cosカーブを使って滑らかな変化の円を描く)
fragment float4 fragCircleCosCurve(VertexOut vout [[ stage_in ]]) {
    // 中心からのuv距離の二乗
    float dist2 = vout.uv[0] * vout.uv[0] + vout.uv[1] * vout.uv[1];
    // uv距離
    float dist = sqrt(dist2);
    // uv距離が1.0以上 = 円の外 (discard_fragment()を呼ぶとピクセルが破棄される)
    if(dist >= 1.0) { discard_fragment(); }
    // cosを用いて新しいアルファをもつ色情報をつくる(rgba[3]=アルファ)
    float4 rgba = vout.rgba;
    rgba[3] = vout.rgba[3] * (1.0 + cos(M_PI_F * dist)) / 2.0;
    return rgba;
}

// フラグメントシェーダー(リングを描く)
fragment float4 fragRing(VertexOut vout [[ stage_in ]]) {
    // 中心からのuv距離の二乗
    float dist2 = vout.uv[0] * vout.uv[0] + vout.uv[1] * vout.uv[1];
    // uv距離
    float dist = sqrt(dist2);
    // uv距離が0.8以下か1.0以上ならピクセル破棄(リングの外)
    if(dist <= 0.8 || 1.0 <= dist) { discard_fragment(); }
    
    // リングの中心骨はdist=0.9とする。kは中心骨との距離。これを10倍するとk=0.0~1.0になる。
    // このkをcosに用いてリングを柔らかくする
    float k = fabs(0.9 - dist) * 10.0;
    // cosを用いて新しいアルファをもつ色情報をつくる(rgba[3]=アルファ)
    float4 rgba = vout.rgba;
    rgba[3] = vout.rgba[3] * (1.0 + cos(M_PI_F * k)) / 2.0;
    return rgba;
}
