# LLVector
> Page-aligned array for MetalKit

It’s a very uncomfortable thing to manipulate pointers directly in Swift, so I wrote this class. You can use it like a normal Swift array and create MTLBuffer by `makeBuffer(bytesNoCopy: _, ...)` with it.

## Installation
Move [src\LLVector.swift](https://github.com/LiulietLee/LLVector/blob/master/src/LLVector.swift) to your project.

## Usage
### Initialization
```swift
let v = LLVector<float4>()
// Or
let v = LLVector<float4>(capacity: 2333)
// Or
let v = LLVector(repeaing: float4(repeating: 1.0), count: 100)
```
### Appending
```swift
// Add a new element to the end of the vector
v.append(float4(0.0, 0.5, 1.0, 1.0))

// Or add the entire array to the end of the vector
v.append(contentsOf: [
    float4(0.5, -0.5, 1.0, 1.0),
    float4(-0.5, 0.5, 1.0, 1.0)
])

// Or add anthor vector to the end of the vector
v.append(contentsOf: another_vector)
```
### Inserting
```swift
// Insert methods are similar to append methods
v.insert(float4(0.7, 0.3, 1.0, 1.0), at: 1)
v.insert(
    contentsOf: [
        float4(0.2, 0.7, 1.0, 1.0),
        float4(0.1, 0.6, 1.0, 1.0)
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
    bytesNoCopy: v.memory,
    length: v.byteSize,
    options: [],
    deallocator: nil // Here you don't need to manually free the memory
)
```

## Attention
Although there is nothing wrong with my personal test, I am not sure that this class will work correctly at all times. It‘s not recommended to use it in a production environment.