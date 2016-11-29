/**
 ImageToolBox.swift

 Copyright (c) 2015 Watanabe-DENKI Inc.

 This software is released under the MIT License.
 http://opensource.org/licenses/mit-license.php
*/

import Foundation

// 画像処理ツールクラス
class ImageToolBox
{
    // 画像全体を赤で塗りつぶす関数
    static func fillRed(img:CAIMImage)
    {
        // 画像のデータを取得
        let mat:CAIMColorMatrix = img.matrix  // 画像のピクセルデータ
        let wid:Int = img.width   // 画像の横幅
        let hgt:Int = img.height  // 画像の縦幅
        
        // (y,x)=(0,0)の1ピクセルの色を塗る
        for y:Int in 0 ..< hgt
        {
            for x:Int in 0 ..< wid
            {
                mat[y][x].R = 1.0
                mat[y][x].G = 0.0
                mat[y][x].B = 0.0
                mat[y][x].A = 1.0
            }
        }
    }
}