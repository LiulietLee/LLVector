//
//  LLVector.swift
//  LLVector
//
//  Created by Liuliet.Lee on 29/3/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import Foundation

public class LLVector<T> {
    typealias Pointer = UnsafeMutableRawPointer
    
    private var pointer: Pointer!
    private(set) var length: Int!
    private(set) var capacity: Int!
    
    private var stride: Int {
        return MemoryLayout<T>.stride
    }

    public init() {
        pointer = __allocate(stride)
        capacity = 1
        length = 1
    }
    
    public init(_ length: Int) {
        pointer = __allocate(stride * length)
        self.length = length
        capacity = length
    }
    
    public init(_ length: Int, _ value: T) {
        pointer = __allocate(stride * length)
        self.length = length
        capacity = length
        for i in 0..<length {
            pointer.storeBytes(of: value, toByteOffset: stride * i, as: T.self)
        }
    }
    
    private init(_ pointer: Pointer, _ length: Int, _ capacity: Int) {
        self.pointer = pointer
        self.length = length
        self.capacity = capacity
    }
    
    deinit {
        __destory(pointer)
    }
    
    public func copy() -> LLVector<T> {
        let addr = __ptrcpy(pointer)
        let newVector = LLVector(addr, length, capacity)
        return newVector
    }
    
    public subscript(index: Int) -> T {
        get { return get(index) }
        set(newValue) { set(index, newValue) }
    }
    
    public func get(_ index: Int) -> T {
        return pointer.load(fromByteOffset: stride * index, as: T.self)
    }
    
    public func set(_ index: Int, _ value: T) {
        pointer.storeBytes(of: value, toByteOffset: stride * index, as: T.self)
    }
}

// MARK: - Memory management

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
    
    private func __ptrcpy(_ ptr: Pointer) -> Pointer {
        let addr = __allocate(stride * capacity)
        memcpy(addr, ptr, stride * capacity)
        return addr
    }
}

// MARK: - Implement Sequence protocol

extension LLVector: Sequence {
    public struct Iterator: IteratorProtocol {
        var current = 0
        var pointer: Pointer
        var length: Int
        
        init(_ pointer: Pointer, _ length: Int) {
            self.pointer = pointer
            self.length = length
        }
        
        mutating public func next() -> T? {
            if current < length {
                defer {
                    current += 1
                }
                return pointer.load(fromByteOffset:
                    MemoryLayout<T>.stride * current,
                    as: T.self
                )
            } else {
                return nil
            }
        }
    }
    
    public __consuming func makeIterator() -> Iterator {
        return Iterator(pointer, length)
    }
}

// MARK: - Sorting method

extension LLVector {
    public func sorted(comp: (T, T) -> Bool) -> LLVector<T> {
        let vector = copy()
        vector.sort(comp: comp)
        return vector
    }
    
    public func sort(comp: (T, T) -> Bool) {
        let p = pointer.assumingMemoryBound(to: T.self)
        var array = UnsafeMutableBufferPointer(start: p, count: length)
        array.sort(by: comp)
    }
}

extension LLVector where T: Comparable {
    public func sort() { sort() { $0 < $1 } }
    public func sorted() -> LLVector { return sorted() { $0 < $1 } }
}
