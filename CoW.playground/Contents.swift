import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// Copy on Write implementation for custom structure


//MARK: - Native types of collections have CoW optimization. Example is below:
print("Start example !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n")

var firstArray = [1, 2, 3, 4]
firstArray.withUnsafeBufferPointer { print("firstArray memory link's: ", $0) }

var secondArray = firstArray
secondArray.withUnsafeBufferPointer { print("secondArray memory link's: ", $0) }

firstArray.append(5)
firstArray.withUnsafeBufferPointer { print("firstArray memory link's: ", $0) }
secondArray.withUnsafeBufferPointer { print("secondArray memory link's: ", $0) }

print("\nThe end of example !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n")


//MARK: - Manual way of implementation CoW:
struct Model {
    var id: Int
    var name: String
}

final class Reference<T> {
    
    var value: T
    
    init(value: T) {
        self.value = value
    }
}

struct Box<T> {
        
    var value: T {
        get { reference.value }
        set {
            guard isKnownUniquelyReferenced(&reference) else {
                reference = Reference(value: newValue)
                return
            }
            reference.value = newValue
        }
    }
    
    var reference: Reference<T>
    
    init(value: T) {
        reference = Reference(value: value)
    }
}

print("Start manual way\n")

let model = Model(id: 1, name: "Jhon")
var box = Box(value: model)
withUnsafePointer(to: box) { print("address of box = ", $0) }
print("Reference memoryLink of box.reference = ", Unmanaged.passUnretained(box.reference).toOpaque())

var anotherBox = box
withUnsafePointer(to: anotherBox) { print("address of anotherBox = ", $0) }
print("Reference memoryLink of anotherBox.reference = ", Unmanaged.passUnretained(anotherBox.reference).toOpaque())

anotherBox.value.id = 2
withUnsafePointer(to: anotherBox) { print("address of anotherBox with changed values = ", $0) }
print("Reference memoryLink of anotherBox.reference with changed values = ", Unmanaged.passUnretained(anotherBox.reference).toOpaque())

print("\nThe end manual way")
