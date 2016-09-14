//
//  CMemory.swift
//  ios_caim_metal
//
//  Created by kengo on 2016/08/17.
//  Copyright © 2016年 TUT Creative Application. All rights reserved.
//

import Foundation

// Cポインタでのメモリ確保クラス
class CMemory<T>
{
    var mem:UnsafeMutablePointer<T> = nil
    var count:Int = 0
    var mem_size:Int { return count * sizeof(T) }
    
    init(size:Int)
    {
        mem = UnsafeMutablePointer<T>.alloc(size)
        self.count = size
    }
    
    deinit { mem.dealloc(self.count) }
    
    // subscript [n] accessor
    subscript(idx:Int) -> T {
        get { return (mem + idx).memory }
        set(new_value) { (mem + idx).memory = new_value }
    }
    
    func offset(idx:Int) -> UnsafeMutablePointer<T> { return mem + idx }
    
    func set(idx:Int, array:[T])
    {
        var i:Int = idx
        for t:T in array
        {
            self[i] = t
            i += 1
        }
    }
}