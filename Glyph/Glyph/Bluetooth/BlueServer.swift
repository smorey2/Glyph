//
//  BlueServer.swift
//  Glyph
//
//  Created by Sky Morey on 8/22/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import Foundation

public class BlueContext {
    public let request: BlueRequest
    public let response: BlueResponse
    init(request: BlueRequest, response: BlueResponse) {
        self.request = request
        self.response = response
    }
}

public struct BlueRequest {
    public let uri: String
    public let method: String
    public let headers: [String:String]
    
    public init?(lines: [String]) {
        guard let firstLine = lines.first else { return nil }
        guard let spaceIndex = firstLine.firstIndex(of: " "), let lastSpaceIndex = firstLine.lastIndex(of: " ") else { return nil }
        method = firstLine[firstLine.startIndex...spaceIndex].trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        uri = firstLine[spaceIndex...lastSpaceIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        var headers = [String:String]()
        for line in lines[1...] {
            guard let separatorIndex = line.firstIndex(of: ":") else { fatalError() }
            let headerName = line[...separatorIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            let headerValue = line[line.index(after: separatorIndex)...].trimmingCharacters(in: .whitespacesAndNewlines)
            headers[headerName] = headerValue
        }
        self.headers = headers
    }
}

public struct BlueResponse {
    public var statusCode: Int = 0
    public var statusDescription: String? = nil
    public var headers: [String:String] = [String:String]()
    public var content: String? = nil
    
    public mutating func finish() -> String {
        if content != nil { headers["Content-Length"] = String(content!.utf8.count) }
        // main_header + headers + linebreak + optional<content>
        return [String](unsafeUninitializedCapacity: headers.count + 3) { b, initializedCount in
            var idx = 0
            b[idx] = "BLUE/1.0 \(statusCode) \(statusDescription ?? "")\n"; idx += 1
            for header in headers { b[idx] = "\(header.key): \(header.value)\n"; idx += 1 }
            b[idx] = "\n"; idx += 1
            if content != nil { b[idx] = content!; idx += 1 }
            initializedCount = idx
        }.joined()
    }
}

struct LineParser {
    func parse(input: Stream) -> [String] {
        
////        var buf = new byte[0x1000]
//        var r = [String]()
////        var b = new StringBuilder()
//        var reading = true
//        while reading {
////            var bytesRead = await input.ReadAsync(buf, 0, buf.Length)
////            var chars = Encoding.ASCII.GetChars(buf, 0, bytesRead)
////            var charsRead = chars.Length
////            for i in 0..<charsRead {
////                var c = chars[i]
////                if (c == '\n') {
////                    var line = b.ToString()
////                    b.Clear()
////                    if (line == null || line.Length == 0) reading = false
////                    else r.Add(line)
////                }
////                else if (c == '\r') { } // ignore
////                else b.Append(c)
////            }
//        }
        fatalError()
//        return r
    }
}
