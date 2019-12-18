# LLVector
> Page-aligned array for MetalKit

It’s a very inconvenient thing to manipulate pointers directly in Swift, so I wrote this class. You can use it as a normal Swift array and create MTLBuffer by `makeBuffer(bytesNoCopy: _, ...)` with it.

## Installation
Move [src\LLVector.swift](https://github.com/LiulietLee/LLVector/blob/master/src/LLVector.swift) to your project.

## Usage
### Initialization
```swift
let v = LLVector<SIMD4<Float> >()
// Or
let v = LLVector<SIMD4<Float> >(capacity: 2333)
// Or
let v = LLVector(repeaing: SIMD4<Float>(repeating: 1.0), count: 100)
```
### Access elements
```swift
let n = v[0]
v[0] = SIMD4<Float>(0.5, 0.5, 1.0, 1.0)

// If you need to access elements outside the valid range (0..<length of the vector)
// for some weird reason, use get and set methods.
let n = v.get(-1)
v.set(v.count + 3, SIMD4<Float>(...))
```
### Appending
```swift
// Add a new element to the end of the vector
v.append(SIMD4<Float>(0.0, 0.5, 1.0, 1.0))

// Or add the entire array to the end of the vector
v.append(contentsOf: [
    SIMD4<Float>(0.5, -0.5, 1.0, 1.0),
    SIMD4<Float>(-0.5, 0.5, 1.0, 1.0)
])

// Or add anthor vector to the end of the vector
v.append(contentsOf: another_vector)
```
### Inserting
```swift
// Insert methods are similar to append methods
v.insert(SIMD4<Float>(0.7, 0.3, 1.0, 1.0), at: 1)
v.insert(
    contentsOf: [
        SIMD4<Float>(0.2, 0.7, 1.0, 1.0),
        SIMD4<Float>(0.1, 0.6, 1.0, 1.0)
    ],
    at: 2
)
v.insert(contentsOf: another_vector, at: 3)
```
### Removing
```swift
// Use remove methods to delete elements in the vector
v.remove(at: 2)
v.removeSubrange(1..<3)
if let last = v.removeLast() { ... }
```
### Traversing
```swift
for coor in v {
    print("(\(coor.x), \(coor.y))") 
}

for i in 0..<v.count {
    v[i].y += 0.1
    print(v[i])
}
```
### Other methods
```swift
// Copy data to a new LLVector
let nv = v.copy()

// Sort elements in the vector
v.sort() { $0.x < $1.x }
let sortedVector = v.sorted() { ... }

// LLVector implements Sequence, RandomAccessCollection and
// MutableCollection. So you can use the methods in these protocols.
if let element = v.first(where: { 0.2 < $0.x && $0.y < 0.7 }) {
    print("first = \(element)")
}
```
### Create MTLBuffer
```swift
let buffer = device.makeBuffer(
    bytesNoCopy: v.pointer,
    length: v.byteSize,
    options: [],
    deallocator: nil // Here you don't need to manually free the memory
)
```

## Attention
Although there is nothing wrong with my personal test, I am not sure that this class will work correctly at all times. It‘s not recommended to use it in a production environment.
