#!/usr/bin/swift

import Foundation

let numberFormmater = NumberFormatter()

struct ColumnInfo {
    let value: Int       // Number of observable
    let description: String   // for example MAY 2015

    init(value: Int,
         description: String) {
        self.value = value
        self.description = description
    }

    init?(stringRepresentation: String) {
        guard let firstWhitespaceIndex = stringRepresentation.firstIndex(of: " ") else { return nil }
        let stringNumber = String(stringRepresentation[stringRepresentation.startIndex ..< firstWhitespaceIndex])
        guard let number = numberFormmater.number(from: stringNumber) else { return nil }
        self.value = number.intValue
        self.description = String(stringRepresentation[firstWhitespaceIndex..<stringRepresentation.endIndex])
    }
}

/// Height of full picture (e.g. returned strings length) equals to heightOfChart + descriptionStringLength. Graph is attached to the top, descriptions are aligned by the bottom
/// Pass columnInfo nil in order to  read from stdin
func update(heightOfChart: Int,
            widthOfString: Int?,
            descriptionStringLength: Int,
            maxValue: Int,
            columnInfo: [ColumnInfo]? = nil) -> [String] {

    // Define the data structure for future picture

    var lines: [String] = Array(repeating: "", count: heightOfChart + descriptionStringLength)

    // Draw

    func processMonth(_ column: ColumnInfo) {
        let percentFill = Double(column.value) / Double(maxValue)
        let percentSkip = 1 - percentFill
        let linesToSkip = Int((Double(heightOfChart) * percentSkip).rounded())

        for line in 0 ..< heightOfChart {
            let isEmpty = linesToSkip > line
            lines[line].append(isEmpty ? " " : "*")
        }

        for (index, character) in column.description.enumerated() {
            let spareLines = max(descriptionStringLength - column.description.count, 0)
            lines[index + heightOfChart + spareLines].append(character)
        }

        for lineIndex in 0 ..< lines.count {
            lines[lineIndex].append(" ")
        }
    }

    if let columnInfo = columnInfo {
        columnInfo.forEach(processMonth)
    } else {
        while let line = readLine() {
            ColumnInfo(stringRepresentation: line).map(processMonth)
        }
    }

    // Clipping string's head to limit view width
    func cut(value: String) -> String {
        guard let widthOfString = widthOfString, value.count > widthOfString else { return value }

        let startIndex = value.index(value.endIndex, offsetBy: -widthOfString)

        return String(value[startIndex ..< value.endIndex])
    }

    return lines.map(cut)
}

// Playground

let params: [Int] = CommandLine.arguments[1...].compactMap { numberFormmater.number(from: $0)?.intValue }

let result: [String]

if params.count == 3 {
    result = update(heightOfChart: params[0], widthOfString: nil, descriptionStringLength: params[1], maxValue: params[2], columnInfo: nil)
} else if CommandLine.arguments.contains("demo") {

    let months: [String] = DateFormatter().shortMonthSymbols

    var columnInfo: [ColumnInfo] = []

    for step in 0 ..< 50 {
        let month = months[step % months.count]
        let year = 2000 + step / months.count
        let value = step * step * step
        columnInfo.append(ColumnInfo(value: value, description: "\(month) \(year)"))
    }

    let maxValue = columnInfo.reduce(0, { max($0, $1.value) })

    result = update(heightOfChart: 80, widthOfString: 80, descriptionStringLength: 9, maxValue: maxValue, columnInfo: columnInfo)
} else {
    result = ["Wrong format. Expected integer values for heightOfChart descriptionStringLength maxValue. Or use demo"]
}

for string in result {
    print(string)
}
