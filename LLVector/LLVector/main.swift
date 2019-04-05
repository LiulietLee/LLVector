//
//  main.swift
//  LLVector
//
//  Created by Liuliet.Lee on 29/3/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import Foundation
import simd

let v = LLVector(10, float4(repeating: 1.0))
v[3] = float4(repeating: 0.0)

for t in v {
    print(t)
}

