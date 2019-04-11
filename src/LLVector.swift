//
//  LLVector.swift
//  LLVector
//
//  Created by Liuliet.Lee on 29/3/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import CoreFoundation

public class LLVector<T> {
    typealias Pointer = UnsafeMutableRawPointer
    
    private var pointer: Pointer!
    private var length: Int!
    private(set) var capacity: Int!
    private var stride: Int!
    
    public var byteCount: Int { return stride * length }
    public var memory: UnsafeMutableRawPointer { return pointer }
    public var memoryLength: Int {
        let alignment = Int(getpagesize())
        let size = stride * length
        return (size + alignment - 1) & (~(alignment - 1))
    }

    public init() { 
        stride = MemoryLayout<T>.stride
        capacity = 8
        length = 0
        pointer = __allocate(stride * capacity)
    }
    
    public init(capacity: Int) {
        stride = MemoryLayout<T>.stride
        pointer = __allocate(stride * capacity)
        length = 0
        self.capacity = capacity
    }
    
    public init(repeaing value: T, count length: Int) {
        stride = MemoryLayout<T>.stride
        self.length = length
        capacity = length
        pointer = __allocate(byteCount)
        __fill_memory(pointer, length, value)
    }
    
    private init(_ pointer: Pointer, _ length: Int, _ capacity: Int) {
        stride = MemoryLayout<T>.stride
        self.pointer = pointer
        self.length = length
        self.capacity = capacity
    }
    
    deinit {
        __deallocate(pointer)
    }
    
    public func deallocate() {
        __deallocate(pointer)
        length = 0
        capacity = 0
    }
    
    public func copy() -> LLVector<T> {
        let addr = __ptrcpy(pointer, stride * capacity)
        let newVector = LLVector(addr, length, capacity)
        return newVector
    }
}

// MARK: - Element operation

extension LLVector {
    public subscript(index: Int) -> T {
        get {
            assert(0 <= index && index < length, "out of range")
            return get(index)
        }
        set(newValue) {
            assert(0 <= index && index < length, "out of range")
            set(index, newValue)
        }
    }
    
    public func get(_ index: Int) -> T {
        return pointer.load(fromByteOffset: stride * index, as: T.self)
    }
    
    public func set(_ index: Int, _ value: T) {
        pointer.storeBytes(of: value, toByteOffset: stride * index, as: T.self)
    }

    // MARK: - append functions
    
    public func append(_ value: T) {
        if length >= capacity {
            capacity <<= 1
            let newAddr = __allocate(stride * capacity)
            memcpy(newAddr, pointer, byteCount)
            __deallocate(pointer)
            pointer = newAddr
        }
        
        set(length, value)
        length += 1
    }
    
    public func append(contentsOf array: [T]) {
        if length + array.count > capacity {
            repeat {
                capacity <<= 1
            } while length + array.count > capacity
            
            let newAddr = __allocate(stride * capacity)
            memcpy(newAddr, pointer, byteCount)
            __deallocate(pointer)
            pointer = newAddr
        }
        
        var currentArray = array
        memcpy(pointer.advanced(by: stride * length), &currentArray, stride * array.count)
        length += array.count
    }
    
    public func append(contentsOf vector: LLVector<T>) {
        if length + vector.count > capacity {
            repeat {
                capacity <<= 1
            } while length + vector.count > capacity
            
            let newAddr = __allocate(stride * capacity)
            memcpy(newAddr, pointer, byteCount)
            __deallocate(pointer)
            pointer = newAddr
        }
        
        memcpy(pointer.advanced(by: stride * length), vector.memory, stride * vector.count)
        length += vector.count
    }
    
    // MARK: - insert functions
    
    public func insert(_ value: T, at index: Int) {
        assert(0 <= index && index <= length, "out of range")
        if index == length {
            append(value)
            return
        }
        
        let src = pointer.advanced(by: stride * index)
        if length >= capacity {
            capacity <<= 1
            let newAddr = __allocate(stride * capacity)
            memcpy(newAddr, pointer, stride * index)
            
            let dst = newAddr.advanced(by: stride * (index + 1))
            memcpy(dst, src, stride * (length - index))
            __deallocate(pointer)
            pointer = newAddr
        } else {
            let dst = pointer.advanced(by: stride * (index + 1))
            memcpy(dst, src, stride * (length - index))
        }
        
        set(index, value)
        length += 1
    }
    
    public func insert(contentsOf array: [T], at index: Int) {
        assert(0 <= index && index <= length, "out of range")
        if index == length {
            append(contentsOf: array)
        }
        
        let src = pointer.advanced(by: stride * index)
        if length + array.count > capacity {
            repeat {
                capacity <<= 1
            } while length + array.count > capacity

            let newAddr = __allocate(stride * capacity)
            memcpy(newAddr, pointer, stride * index)
            
            let dst = newAddr.advanced(by: stride * (index + array.count))
            memcpy(dst, src, stride * (length - index))
            __deallocate(pointer)
            pointer = newAddr
        } else {
            let dst = pointer.advanced(by: stride * (index + array.count))
            memcpy(dst, src, stride * (length - index))
        }
        
        var currentArray = array
        memcpy(pointer.advanced(by: stride * index), &currentArray, stride * array.count)
        length += array.count
    }
    
    public func insert(contentsOf vector: LLVector, at index: Int) {
        assert(0 <= index && index <= length, "out of range")
        if index == length {
            append(contentsOf: vector)
        }

        let src = pointer.advanced(by: stride * index)
        if length + vector.count > capacity {
            repeat {
                capacity <<= 1
            } while length + vector.count > capacity
            
            let newAddr = __allocate(stride * capacity)
            memcpy(newAddr, pointer, stride * index)
            
            let dst = newAddr.advanced(by: stride * (index + vector.count))
            memcpy(dst, src, stride * (length - index))
            __deallocate(pointer)
            pointer = newAddr
        } else {
            let dst = pointer.advanced(by: stride * (index + vector.count))
            memcpy(dst, src, stride * (length - index))
        }
        
        memcpy(pointer.advanced(by: stride * index), vector.memory, stride * vector.count)
        length += vector.count
    }
    
    // MARK: - remove functions
    
    public func remove(at index: Int) {
        assert(0 <= index && index < length, "out of range")
        if index < length - 1 {
            let dst = pointer.advanced(by: stride * index)
            let src = pointer.advanced(by: stride * (index + 1))
            memcpy(dst, src, stride * (length - index - 1))
        }
        length -= 1
    }
    
    public func removeFirst() -> T? {
        if length == 0 { return nil }
        let first = get(0)
        memcpy(pointer, pointer.advanced(by: stride), stride * (length - 1))
        length -= 1
        return first
    }
    
    public func removeLast() -> T? {
        if length == 0 { return nil }
        let last = get(length - 1)
        length -= 1
        return last
    }
    
    public func removeSubrange(_ range: Range<Int>) {
        assert(
            0 <= range.startIndex && range.startIndex < length
                && 0 < range.endIndex && range.endIndex <= length,
            "out of range"
        )
        let dst = pointer.advanced(by: stride * range.startIndex)
        let src = pointer.advanced(by: stride * range.endIndex)
        memcpy(dst, src, stride * (length - range.endIndex + 1))
        length -= range.endIndex - range.startIndex
    }
}

// MARK: - Sorting methods

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

// MARK: - Memory management

extension LLVector {
    private func __allocate(_ size: Int) -> Pointer {
        var addr: Pointer? = nil
        let alignment = Int(getpagesize())
        let allocationSize = (size + alignment - 1) & (~(alignment - 1))
        posix_memalign(&addr, alignment, allocationSize)
        if let ptr = addr {
            return ptr
        } else {
            fatalError("out of memory")
        }
    }
    
    private func __deallocate(_ ptr: Pointer) {
        free(ptr)
    }
    
    private func __fill_memory(_ ptr: Pointer, _ len: Int, _ val: T) {
        var idx = 1
        ptr.storeBytes(of: val, as: T.self)
        while (idx << 1) <= len {
            let dst = ptr.advanced(by: stride * idx)
            memcpy(dst, ptr, stride * idx)
            idx <<= 1
        }
        if idx < len {
            let dst = ptr.advanced(by: stride * idx)
            memcpy(dst, ptr, stride * (len - idx))
        }
    }
    
    private func __ptrcpy(_ ptr: Pointer, _ size: Int) -> Pointer {
        let addr = __allocate(size)
        memcpy(addr, ptr, size)
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
                return pointer.load(
                    fromByteOffset: MemoryLayout<T>.stride * current,
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

// MARK: - Implement RandomAccessCollection and MutableCollection

extension LLVector: RandomAccessCollection {
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return length }
}

extension LLVector: MutableCollection {}
