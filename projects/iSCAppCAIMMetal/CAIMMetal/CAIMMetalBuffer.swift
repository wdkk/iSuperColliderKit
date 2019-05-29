//
// CAIMMetalGeometrics.swift
// CAIM Project
//   https://kengolab.net/CreApp/wiki/
//
// Copyright (c) Watanabe-DENKI Inc.
//   https://wdkk.co.jp/
//
// This software is released under the MIT License.
//   https://opensource.org/licenses/mit-license.php
//

#if os(macOS) || (os(iOS) && !arch(x86_64))

import Foundation
import Metal

public enum CAIMMetalBufferType : Int
{
    case alloc
    case shared
}

// Metalバッファを出力できるようにするプロトコル
public protocol CAIMMetalBufferAllocatable {
    var metalBuffer:MTLBuffer? { get }
}
public extension CAIMMetalBufferAllocatable {
    var metalBuffer:MTLBuffer? { return CAIMMetalAllocatedBuffer( self ).metalBuffer }
}

public class CAIMMetalAllocatedBuffer : CAIMMetalBufferAllocatable
{
    private var _length:Int
    private var _mtlbuf:MTLBuffer?
    public var metalBuffer:MTLBuffer? { return _mtlbuf }
    
    // 指定したオブジェクトのサイズで確保＆初期化
    public init<T>( _ obj:T ) {
        _length = MemoryLayout<T>.stride
        _mtlbuf = self.allocate( [obj], length:_length )
    }
    // 指定したオブジェクト配列で確保＆初期化
    public init<T>( elements:[T] ) {
        _length = MemoryLayout<T>.stride * elements.count
        _mtlbuf = self.allocate( UnsafeMutablePointer( mutating: elements ), length:_length )
    }
    // 指定したバイト数を確保（初期化はなし）
    public init( length:Int ) {
        _length = length
        _mtlbuf = self.allocate( _length )
    }
    // 指定したバイト数で確保＆ポインタ先からコピーして初期化
    public init( _ buf:UnsafeRawPointer, length:Int ) {
        _length = length
        _mtlbuf = self.allocate( buf, length: _length )
    }
    // 指定した頂点プールの内容とサイズで確保＆初期化
    public init<T>( vertice:LLAlignedMemory16<T> ) {
        _length = vertice.allocatedLength
        _mtlbuf = self.allocate( vertice.pointer, length:_length )
    }
    // 指定した頂点プールの内容とサイズで確保＆初期化(4Kアラインメントデータ)
    public init<T>( vertice:LLAlignedMemory4K<T> ) {
        _length = vertice.allocatedLength
        _mtlbuf = self.allocate( vertice.pointer, length:_length )
    }
    
    // 更新
    public func update<T>( _ obj:T ) {
        let sz:Int = MemoryLayout<T>.stride
        if( _length != sz ) { _mtlbuf = self.allocate( sz ) }
        memcpy( _mtlbuf!.contents(), [obj], sz )
    }
    
    public func update<T>( elements:[T] ) {
        let sz:Int = MemoryLayout<T>.stride * elements.count
        if _length != sz { _mtlbuf = self.allocate( sz ) }
        if sz == 0 { return }
        memcpy( _mtlbuf!.contents(), UnsafeMutablePointer( mutating: elements ), sz )
    }
    
    public func update( _ buf:UnsafeRawPointer?, length:Int ) {
        let sz:Int = length
        if _length != sz { _mtlbuf = self.allocate( sz ) }
        if buf == nil { return }
        if sz == 0 { return }
        memcpy( _mtlbuf!.contents(), buf, sz )
    }

    public func update<T>( vertice:LLAlignedMemory4K<T> ) {
        let sz:Int = vertice.allocatedLength
        if( _length != sz ) { _mtlbuf = self.allocate( sz ) }
        memcpy( _mtlbuf!.contents(), vertice.pointer, sz )
    }
    
    public func update<T>( vertice:LLAlignedMemory16<T> ) {
        let sz:Int = vertice.allocatedLength
        if( _length != sz ) { _mtlbuf = self.allocate( sz ) }
        memcpy( _mtlbuf!.contents(), vertice.pointer, sz )
    }
    
    //// メモリ確保
    private func allocate( _ buf:UnsafeRawPointer?, length:Int ) -> MTLBuffer? {
        if length == 0 { return nil }
        if buf == nil { return nil }
        return CAIMMetal.device!.makeBuffer( bytes: buf!, length: length, options: .storageModeShared )
    }
    
    private func allocate( _ length:Int ) -> MTLBuffer? {
        if length == 0 { return nil }
        return CAIMMetal.device!.makeBuffer( length: length, options: .storageModeShared )
    }
}

public class CAIMMetalSharedBuffer : CAIMMetalBufferAllocatable
{
    private var _length:Int
    private var _mtlbuf:MTLBuffer?
    public var metalBuffer:MTLBuffer? { return _mtlbuf }
    
    // 指定したオブジェクト全体を共有して確保・初期化
    public init<T>( vertice:LLAlignedMemory4K<T> ) {
        _length = vertice.allocatedLength
        if( _length == 0 ) { _mtlbuf = nil }
        else { _mtlbuf = self.nocopy( vertice.pointer!, length:_length ) }
    }
    
    // 指定したバイト数で確保＆ポインタ先からコピーして初期化
    public init( _ buf:UnsafeRawPointer, length:Int ) {
        _length = length
        _mtlbuf = self.nocopy( UnsafeMutableRawPointer(mutating: buf), length: _length )
    }
    
    public func update<T>( vertice:LLAlignedMemory4K<T> ) {
        _mtlbuf = self.nocopy( vertice.pointer!, length: vertice.allocatedLength )
    }
    
    private func nocopy( _ buf:UnsafeMutableRawPointer, length:Int ) -> MTLBuffer {
        return CAIMMetal.device!.makeBuffer( bytesNoCopy: buf, length: length, options: .storageModeShared, deallocator: nil )!
    }
}

#endif
