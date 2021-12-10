//: [Previous](@previous)

/*:
 > [https://refactoring.guru/design-patterns/decorator](https://refactoring.guru/design-patterns/decorator)
 
 ![UML](https://refactoring.guru/images/patterns/diagrams/decorator/example-2x.png?id=4891323a27d5601a174e)
 */

import Foundation

protocol DataSource {
    func write(data: Data?)
    func read() -> Data?
}

class FileDataSource: DataSource {
    let fileName: String
    
    init(fileName: String) {
        self.fileName = fileName
    }
    
    func write(data: Data?) {
        print("Write data into file: \(fileName)")
    }
    
    func read() -> Data? {
        print("Read data from file: \(fileName)")
        return nil
    }
}

class DataSourceDecorator: DataSource {
    let wrapee: DataSource
    
    init(dataSource: DataSource) {
        wrapee = dataSource
    }
    
    func write(data: Data?) {
        wrapee.write(data: data)
    }
    
    func read() -> Data? {
        return wrapee.read()
    }
}

class EncryptionDecorator: DataSourceDecorator {
    override func write(data: Data?) {
        print("Encrypt data before writing")
        super.write(data: data)
    }
    
    override func read() -> Data? {
        let data = super.read()
        print("Decrypt data after read")
        return data
    }
}

class CompressionDecorator: DataSourceDecorator {
    override func write(data: Data?) {
        print("Compress data before writing")
        super.write(data: data)
    }
    
    override func read() -> Data? {
        let data = super.read()
        print("Decompress data after read")
        return data
    }
}


var dataSource: DataSource = FileDataSource(fileName: "demo.dat")
let data = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.".data(using: .utf8)

// write data to file
dataSource.write(data: data)

dataSource = EncryptionDecorator(dataSource: dataSource)
// encrypt data -> write data into file
dataSource.write(data: data)

dataSource = CompressionDecorator(dataSource: dataSource)
// compress data -> encrypt data -> write data into file
dataSource.write(data: data)

//: [Next](@next)
