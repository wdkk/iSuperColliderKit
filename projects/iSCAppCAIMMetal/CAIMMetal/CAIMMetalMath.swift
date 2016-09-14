//
//  CAIMMetalMath.swift
//  ios_caim_metal
//
//  Created by kengo on 2016/08/16.
//  Copyright © 2016年 TUT Creative Application. All rights reserved.
//

import Foundation

func randomFloat() -> Float32 { return Float32(arc4random() % 1000) / 1000.0 }
func randomFloat(max:Float32) -> Float32 { return Float32(arc4random() % 1000) / 1000.0 * max }
func randomFloat(max:Int32) -> Float32 { return Float32(arc4random() % 1000) / 1000.0 * Float32(max) }
func randomFloat(max:Int) -> Float32 { return Float32(arc4random() % 1000) / 1000.0 * Float32(max) }
