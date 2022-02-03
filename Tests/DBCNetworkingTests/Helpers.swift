import Foundation
import XCTest
import DBCNetworking

func loadJson(named name: String) -> Data {
    let url = Bundle.module.url(forResource: name, withExtension: "json")
    return try! Data(contentsOf: url!)
}

extension InputStream {
    var data: Data {
        open()
        let bufferSize: Int = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        var data = Data()
        while hasBytesAvailable {
            let readDat = read(buffer, maxLength: bufferSize)
            data.append(buffer, count: readDat)
        }
        buffer.deallocate()
        close()
        return data
    }
}
