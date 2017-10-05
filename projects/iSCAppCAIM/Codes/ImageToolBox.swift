//
// ImageToolBox.swift
// CAIM Project
//   http://kengolab.net/CreApp/wiki/
//
// Copyright (c) 2016 Watanabe-DENKI Inc.
//   http://wdkk.co.jp/
//
// This software is released under the MIT License.
//   http://opensource.org/licenses/mit-license.php
//

import Foundation

// 画像処理ツールクラス
class ImageToolBox
{
    // 四角を描く関数(透明度つき)
    static func fillRect(_ img:CAIMImage, x1:Int, y1:Int, x2:Int, y2:Int, color:CAIMColor, opacity:Float=1.0) {
        // 画像のデータを取得
        let mat = img.matrix  // 画像のピクセルデータ
        let wid = img.width   // 画像の横幅
        let hgt = img.height  // 画像の縦幅
        
        // 2点の座標値の小さい方、大きい方を判別して別の変数に入れる
        let min_x:Int = min(x1, x2)
        let min_y:Int = min(y1, y2)
        let max_x:Int = max(x1, x2)
        let max_y:Int = max(y1, y2)
        
        // min_x~max_x, min_y~max_yまでの範囲を塗る
        for y in min_y ... max_y {
            for x in min_x ... max_x {
                // x,yが画像外にはみだしたら、エラー防止のためcontinueで処理をスキップする
                if(x < 0 || y < 0 || x >= wid || y >= hgt) { continue }
                
                mat[y][x].R = color.R * opacity + mat[y][x].R * (1.0-opacity)
                mat[y][x].G = color.G * opacity + mat[y][x].G * (1.0-opacity)
                mat[y][x].B = color.B * opacity + mat[y][x].B * (1.0-opacity)
                mat[y][x].A = color.A * opacity + mat[y][x].A * (1.0-opacity)
            }
        }
    }
        
    // 丸を描く関数(透明度付き)
    static func fillCircle(_ img:CAIMImage, cx:Int, cy:Int, radius:Int, color:CAIMColor, opacity:Float=1.0) {
        // 画像のデータを取得
        let mat = img.matrix  // 画像のピクセルデータ
        let wid = img.width   // 画像の横幅
        let hgt = img.height  // 画像の縦幅
        
        // 処理の範囲を決める
        let min_x:Int = cx - radius
        let min_y:Int = cy - radius
        let max_x:Int = cx + radius
        let max_y:Int = cy + radius
        
        // min_x~max_x, min_y~max_yまでの範囲を塗る
        for y in min_y ... max_y {
            for x in min_x ... max_x {
                // x,yが画像外にはみだしたら、エラー防止のためcontinueで処理をスキップする
                if(x < 0 || y < 0 || x >= wid || y >= hgt) { continue }
                
                // 中心点からの距離
                let dist:Float = sqrt(Float((x-cx)*(x-cx)) + Float((y-cy)*(y-cy)))
                
                // 中心点(cx, cy)からの距離が半径radius以内なら塗る
                if( dist <= Float(radius) ) {
                    mat[y][x].R = color.R * opacity + mat[y][x].R * (1.0-opacity)
                    mat[y][x].G = color.G * opacity + mat[y][x].G * (1.0-opacity)
                    mat[y][x].B = color.B * opacity + mat[y][x].B * (1.0-opacity)
                    mat[y][x].A = color.A * opacity + mat[y][x].A * (1.0-opacity)
                }
            }
        }
    }
    
    // Cosドーム上の円を描く
    static func fillDome(_ img:CAIMImage, cx:Int, cy:Int, radius:Int, color:CAIMColor, opacity:Float) {
        // 画像のデータを取得
        let mat = img.matrix  // 画像のピクセルデータ
        let wid = img.width   // 画像の横幅
        let hgt = img.height  // 画像の縦幅
        
        // 処理の範囲を決める
        let min_x:Int = cx - radius
        let min_y:Int = cy - radius
        let max_x:Int = cx + radius
        let max_y:Int = cy + radius
        
        // min_x~max_x, min_y~max_yまでの範囲を塗る
        for y in min_y ... max_y {
            for x in min_x ... max_x {
                // x,yが画像外にはみだしたら、エラー防止のためcontinueで処理をスキップする
                if(x < 0 || y < 0 || x >= wid || y >= hgt) { continue }
                
                // 中心点からの距離
                let dist:Float = sqrt(Float((x-cx)*(x-cx)) + Float((y-cy)*(y-cy)))
                
                // 中心点(cx, cy)からの距離が半径radius以内なら塗る
                if( dist <= Float(radius) ) {
                    // 中心からの距離でcosを計算してαとして用いる
                    var alpha = Float(cos(Double(dist) / Double(radius) * Double.pi / 2.0))
                    // αに不透明度opacityを掛ける
                    alpha *= opacity
                    
                    mat[y][x].R = color.R * alpha + mat[y][x].R * (1.0-alpha)
                    mat[y][x].G = color.G * alpha + mat[y][x].G * (1.0-alpha)
                    mat[y][x].B = color.B * alpha + mat[y][x].B * (1.0-alpha)
                    mat[y][x].A = color.A * alpha + mat[y][x].A * (1.0-alpha)
                }
            }
        }
    }
    
    // Cosドーム上の円を描く
    static func fillDomeFast(_ img:CAIMImage, cx:Int, cy:Int, radius:Int, color:CAIMColor, opacity:Float) {
        // 画像のデータを取得
        let mat = img.matrix  // 画像のピクセルデータ
        let wid = img.width   // 画像の横幅
        let hgt = img.height  // 画像の縦幅
        
        // 処理の範囲を決める(はみ出し処理込み)
        let min_x:Int = max(cx - radius, 0)
        let min_y:Int = max(cy - radius, 0)
        let max_x:Int = min(cx + radius, wid-1)
        let max_y:Int = min(cy + radius, hgt-1)
        
        let r2:Int = radius * radius
        let k:Float = 1.0 / Float(r2) * Float.pi / 2.0
        
        // min_x~max_x, min_y~max_yまでの範囲を塗る
        for y in min_y ... max_y {
            let dy2:Int = (y-cy)*(y-cy)
            for x in min_x ... max_x {
                // 中心点からの距離
                let dx2:Int = (x-cx)*(x-cx)
                let dist2:Int = dx2 + dy2
                
                // 中心点(cx, cy)からの距離が半径radius以内なら塗る
                if( dist2 <= r2 ) {
                    // 中心からの距離でcosを計算してαとして用いる
                    let alpha:Float = cos(Float(dist2) * k) * opacity
                    let beta:Float = 1.0-alpha
                    
                    mat[y][x].R = color.R * alpha + mat[y][x].R * beta
                    mat[y][x].G = color.G * alpha + mat[y][x].G * beta
                    mat[y][x].B = color.B * alpha + mat[y][x].B * beta
                    mat[y][x].A = color.A * alpha + mat[y][x].A * beta
                }
            }
        }
    }
    
    // 直線を引く
    static func drawLine(_ img:CAIMImage, x1:Int, y1:Int, x2:Int, y2:Int, color:CAIMColor, opacity:Float) {
        // 画像のデータを取得
        let mat = img.matrix  // 画像のピクセルデータ
        let wid = img.width   // 画像の横幅
        let hgt = img.height  // 画像の縦幅
        
        let dx:Int = x2 - x1    // xの移動量(マイナス含む)
        let dy:Int = y2 - y1    // yの移動量(マイナス含む)
        var px:Int = x1
        var py:Int = y1
        
        var next_step_f:Float = 0.0
        
        // x方向の1ステップの移動量(正負方向の判定)
        var step_x:Int = 1
        if(dx < 0) { step_x = -1 }
        // y方向の1ステップの移動量(正負方向の判定)
        var step_y:Int = 1
        if(dy < 0) { step_y = -1 }
        
        // 移動量の絶対値
        let absdx:Int = abs(dx)
        let absdy:Int = abs(dy)
        
        // 指定した最初の1点を、はみ出していなければ描画する
        if(px >= 0 && py >= 0 && px < wid && py < hgt) {
            mat[py][px].R = color.R * opacity + mat[py][px].R * (1.0-opacity)
            mat[py][px].G = color.G * opacity + mat[py][px].G * (1.0-opacity)
            mat[py][px].B = color.B * opacity + mat[py][px].B * (1.0-opacity)
            mat[py][px].A = color.A * opacity + mat[py][px].A * (1.0-opacity)
        }
        
        // 横方向移動量が多い時,xを1ずつ移動させながら、y方向はどこで1移動させるかをnext_step_fで判断しながら処理する
        if(absdx > absdy) {
            let sf:Float = Float(absdy) / Float(absdx)
            next_step_f = sf
            
            // x方向移動を1ピクセルずつ行っていく
            while(px != x2) {
                // next_step_fが0.5を超えたらy方向にも1ピクセル移動する
                if(next_step_f >= 0.5) {
                    py += step_y
                    next_step_f -= 1.0  // 1.0減らして改めて計算し直す
                }
                // x方向に1ピクセル移動する
                px += step_x
                next_step_f += sf  // ステップの値をsf増やす
            
                // はみ出し防止(はみ出していたらcontinueで処理をスキップ)
                if(px < 0 || py < 0 || px >= wid || py >= hgt) { continue }
                
                // ピクセルの色を塗る。opacityの値で
                mat[py][px].R = color.R * opacity + mat[py][px].R * (1.0-opacity)
                mat[py][px].G = color.G * opacity + mat[py][px].G * (1.0-opacity)
                mat[py][px].B = color.B * opacity + mat[py][px].B * (1.0-opacity)
                mat[py][px].A = color.A * opacity + mat[py][px].A * (1.0-opacity)
            }
        }
        // 縦方向移動量が多い場合、yを1ずつ移動させながら、x方向はどこで1移動させるかをnext_step_fで判断しながら処理する
        else {
            let sf:Float = Float(absdx) / Float(absdy)
            next_step_f = sf
            
            // 終了点にたどり着くまで続ける
            while(py != y2) {
                // next_step_fが0.5を超えたらx方向にも1ピクセル移動する
                if(next_step_f >= 0.5) {
                    px += step_x
                    next_step_f -= 1.0  // 1.0減らして改めて計算し直す
                }
                // y方向に1ピクセル移動する
                py += step_y
                next_step_f += sf  // ステップの値をsf増やす

                if(px < 0 || py < 0 || px >= wid || py >= hgt) { continue }
                
                mat[py][px].R = color.R * opacity + mat[py][px].R * (1.0-opacity)
                mat[py][px].G = color.G * opacity + mat[py][px].G * (1.0-opacity)
                mat[py][px].B = color.B * opacity + mat[py][px].B * (1.0-opacity)
                mat[py][px].A = color.A * opacity + mat[py][px].A * (1.0-opacity)
            }
        }
    }
    
}

