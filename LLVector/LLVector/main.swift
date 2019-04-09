//
//  main.swift
//  LLVector
//
//  Created by Liuliet.Lee on 29/3/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import Foundation
import simd

let v = LLVector<Int>()
var a = Array<Int>()

func cal_vector() {
    let start = DispatchTime.now()
    
    for i in 0..<100000000 {
        v.append(i)
    }
    
    let end = DispatchTime.now()
    
    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
    let timeInterval = Double(nanoTime) / 1_000_000_000
    
    var sum = 0
    //for val in v {
    //    sum += val
    //}
    
    for i in 0..<v.count {
        sum += v[i]
    }
    
    print(timeInterval)
    
    print(sum)
}

func cal_array() {
    let start = DispatchTime.now()
    
    for i in 0..<10000 {
        a.append(i)
    }
    
    let end = DispatchTime.now()
    
    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
    let timeInterval = Double(nanoTime) / 1_000_000_000
    
    var sum = 0
    //for val in a {
    //    sum += val
    //}
    
    for i in 0..<a.count {
        sum += a[i]
    }
    
    
    print(timeInterval)
    
    print(sum)
}

cal_vector()

//for i in 0..<10 {
//    v.append(float4(repeating: Float(i)))
//}
//
//v.insert(float4(repeating: 1000.0), at: 5)
//v.remove(at: 5)
//
//v.insert(
//    contentsOf: [
//        float4(repeating: 10.0),
//        float4(repeating: 100.0),
//        float4(repeating: 1000.0),
//        float4(repeating: 10000.0)
//    ],
//    at: 3
//)
//
//v.sort() { $0.x < $1.x }
//v.removeSubrange(1..<4)
//
//if let i = v.firstIndex(of: float4(repeating: 9.0)) {
//    v[i] = float4(repeating: 3.0)
//}
//
//for coor in v {
//    print(coor.x)
//}
//
//print(v.isEmpty)

//let nv = LLVector<float4>()
//
//nv.append(float4(repeating: 10.0))
//nv.append(float4(repeating: 100.0))
//nv.append(float4(repeating: 1000.0))
//nv.append(float4(repeating: 10000.0))

//v.append(contentsOf: [
//    float4(repeating: 10.0),
//    float4(repeating: 100.0),
//    float4(repeating: 1000.0),
//    float4(repeating: 10000.0)
//])

//for t in v {
//    print(t)
//}

//let nv = v.sorted() { $0.x < $1.x }

//for t in v {
//    print(t)
//}

//for t in nv {
//    print(t)
//}

//let pointer = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<Int>.stride * 10000, alignment: MemoryLayout<Int>.alignment)

//for _ in 0..<100000000 {
//    for _ in 0..<100000000 {
//        let _ = UnsafeMutableRawBufferPointer.init(start: pointer, count: MemoryLayout<Int>.stride * 10000)
//    }
//}

//let p1 = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<Int>.stride * 3, alignment: MemoryLayout<Int>.alignment)
//
//let p2 = p1.advanced(by: MemoryLayout<Int>.stride * 2)
//
//print(p2 == p1.advanced(by: MemoryLayout<Int>.stride * 2))
