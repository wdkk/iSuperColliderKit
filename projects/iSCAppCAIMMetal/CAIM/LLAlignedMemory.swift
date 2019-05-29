//
// LLAlignedMemory.h
// Lily Library
//
// Copyright (c) 2017- Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//

import Foundation

public class LLAlignedAllocator {
    fileprivate var _memory:UnsafeMutableRawPointer?
    public var pointer:UnsafeMutableRawPointer? { return _memory }
    
    public private(set) var alignment:Int
    public private(set) var length:Int
    public private(set) var allocatedLength:Int
    
    // アラインメントを含んだメモリ確保量を計算
    private func calcAlignedSize( length:Int ) -> Int {
        let mod = length % alignment
        return length + ( mod > 0 ? alignment - mod : 0 )
    }
    
    // メモリの確保
    private func allocate( length:Int ) {
        if( length == 0 ) {
            self.length = 0
            self.allocatedLength = 0
            _memory?.deallocate()
            _memory = nil
            return
        }
        
        if( calcAlignedSize( length: length ) <= self.allocatedLength ) { return }
        
        let copy_length = min( self.length, length )
        self.length = length
        self.allocatedLength = calcAlignedSize( length: self.length )
        
        if _memory != nil {
            let tmp_memory = UnsafeMutableRawPointer.allocate( byteCount: self.allocatedLength, alignment: alignment )
            memcpy( tmp_memory, _memory, copy_length )
            _memory?.deallocate()
            _memory = tmp_memory
        }
        else {
            _memory = UnsafeMutableRawPointer.allocate( byteCount: self.allocatedLength, alignment: alignment )
        }
    }
    
    // メモリの追加
    private func allocateAppending( length newleng:Int ) {
        let new_aligned_length = calcAlignedSize( length: newleng )
        // もし余分も含めてオーバーした場合メモリの再確保
        var next_length = self.allocatedLength
        while(true) {
            if( new_aligned_length <= next_length ) { break }
            next_length *= 2
        }
        allocate( length: next_length )
    }
    
    public init( alignment:Int, length:Int ) {
        self.alignment = alignment
        self.length = 0
        self.allocatedLength = 0
        allocate( length: length )
    }
    
    deinit {
        clear()
    }
    
    public func resize( length:Int ) {
        allocate( length: length )
    }
    
    public func clear() {
        allocate( length: 0 )
    }
    
    public func append( _ buf:UnsafeRawPointer, length add_length:Int ) {
        let new_length = self.length + add_length
        let last_ptr = self.length
        allocateAppending( length: new_length )
        memcpy( _memory! + last_ptr, buf, add_length )
    }
}

// アラインメントを考慮したメモリクラス
public class LLAlignedMemory4K<T> {
    fileprivate var _allocator:LLAlignedAllocator?
    public private(set) var count:Int = 0
    public private(set) var unit:Int = 0
    
    public var length:Int { return _allocator!.length }
    public var allocatedLength:Int { return _allocator!.allocatedLength }
    public var pointer:UnsafeMutableRawPointer? { return _allocator?.pointer }
    
    public init( unit:Int, count:Int = 0 ) {
        _allocator = LLAlignedAllocator( alignment: 4096, length: 0 )
        self.unit = unit
        self.resize( count: count )
    }
    
    // メモリのクリア
    public func clear() { _allocator?.clear() }
    
    // メモリのリサイズ
    public func resize( count:Int ) {
        self.count = count
        _allocator?.resize( length: count * MemoryLayout<T>.stride * unit )
    }
    
    // メモリの追加
    public func append( _ element:T ) {
        self.count += 1
        withUnsafePointer( to: element ) {
            _allocator?.append( $0, length: MemoryLayout<T>.stride )
        }
    }
    
    // メモリの追加
    public func append( _ elements:[T] ) {
        self.count += elements.count
        withUnsafePointer( to: elements ) {
            _allocator?.append( $0, length: MemoryLayout<T>.stride * elements.count )
        }
    }
}

// アラインメントを考慮したメモリクラス
public class LLAlignedMemory16<T> {
    fileprivate var _allocator:LLAlignedAllocator?
    public private(set) var count:Int = 0
    public private(set) var unit:Int = 0
    
    public var length:Int { return _allocator!.length }
    public var allocatedLength:Int { return _allocator!.allocatedLength }
    public var pointer:UnsafeMutableRawPointer? { return _allocator?.pointer }
    
    public init( unit:Int, count:Int = 0 ) {
        _allocator = LLAlignedAllocator( alignment: 16, length: 0 )
        self.unit = unit
        self.resize( count: count )
    }
    
    // メモリのクリア
    public func clear() { _allocator?.clear() }
    
    // メモリのリサイズ
    public func resize( count:Int ) {
        self.count  = count
        _allocator?.resize( length: count * MemoryLayout<T>.stride * unit )
    }
    
    // メモリの追加
    public func append( _ element:T ) {
        self.count += 1
        withUnsafePointer(to: element ) {
            _allocator?.append( $0, length: MemoryLayout<T>.stride )
        }
    }
    
    // メモリの追加
    public func append( _ elements:[T] ) {
        self.count += elements.count
        withUnsafePointer(to: elements) {
            _allocator?.append( $0, length: MemoryLayout<T>.stride * elements.count )
        }
    }
}
