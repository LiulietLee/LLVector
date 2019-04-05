//
//  LLVector.swift
//  LLVector
//
//  Created by Liuliet.Lee on 29/3/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import Foundation

class LLVector<T> {
    
    typealias Pointer = UnsafeMutableRawPointer
    
    private var pointer: Pointer!
    private(set) var length: Int!
    private(set) var capacity: Int!
    
    private var stride: Int {
        return MemoryLayout<T>.stride
    }

    init() {
        pointer = __allocate(stride)
        capacity = 1
        length = 1
    }
    
    init(_ length: Int) {
        pointer = __allocate(stride * length)
        self.length = length
        capacity = length
    }
    
    init(_ length: Int, _ value: T) {
        pointer = __allocate(stride * length)
        self.length = length
        capacity = length
        for i in 0..<length {
            pointer.storeBytes(of: value, toByteOffset: stride * i, as: T.self)
        }
    }
    
    private init(_ pointer: Pointer, _ length: Int) {
        self.pointer = pointer
        self.length = length
        capacity = length
    }
    
    deinit {
        __destory(pointer)
    }
    
    func copy() -> LLVector<T> {
        let addr = __allocate(stride * length)
        memcpy(addr, pointer, stride * length)
        let newVector = LLVector(addr, length)
        return newVector
    }
    
    subscript(index: Int) -> T {
        get { return get(index) }
        set(newValue) {
            pointer.storeBytes(of: newValue, toByteOffset: stride * index, as: T.self)
        }
    }
    
    func get(_ index: Int) -> T {
        return pointer.load(fromByteOffset: stride * index, as: T.self)
    }
}

extension LLVector {
    private func __allocate(_ size: Int) -> Pointer {
        var memory: UnsafeMutableRawPointer? = nil
        let alignment = Int(getpagesize())
        let allocationSize = (size + alignment - 1) & (~(alignment - 1))
        posix_memalign(&memory, alignment, allocationSize)
        if let addr = memory {
            return addr
        } else {
            fatalError("out of memory")
        }
    }
    
    private func __destory(_ addr: Pointer) {
        free(addr)
    }
}
