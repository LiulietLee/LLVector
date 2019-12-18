//
//  main.swift
//  LLVector
//
//  Created by Liuliet.Lee on 29/3/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import simd
import MetalKit

let v = LLVector<SIMD4<Float> >(capacity: 2333)

v.append(SIMD4<Float>(0.0, 0.5, 1.0, 1.0))
v.append(contentsOf: [
    SIMD4<Float>(0.5, -0.5, 1.0, 1.0),
    SIMD4<Float>(-0.5, 0.5, 1.0, 1.0)
])

v.insert(SIMD4<Float>(0.7, 0.3, 1.0, 1.0), at: 2)
v.insert(
    contentsOf: [
        SIMD4<Float>(0.2, 0.7, 1.0, 1.0),
        SIMD4<Float>(0.1, 0.6, 1.0, 1.0)
    ],
    at: 1
)

for coor in v { print("(\(coor.x), \(coor.y))") }

v.removeFirst()
v.removeSubrange(1..<3)

v.sort() { $0.x < $1.x }

for i in 0..<v.count {
    v[i].y += 0.1
    print(v[i])
}

let nv = v.copy()

if let element = nv.first(where: { 0.2 < $0.x && $0.y < 0.7 }) {
    print("first = \(element)")
}

let device = MTLCreateSystemDefaultDevice()!
let buffer = device.makeBuffer(
    bytesNoCopy: v.pointer,
    length: v.byteSize,
    options: [],
    deallocator: nil
)
