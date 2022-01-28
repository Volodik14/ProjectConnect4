//
//  main.swift
//  ProjectConnect4
//
//  Created by Владимир Моторкин on 28.01.2022.
//

import Foundation

enum DimensionsError: Error {
    case invalidInput
    case rowsOutOfBounds
    case colsOutOfBounds
}

func getDimensions(dimensions: String) throws -> (Int, Int)  {
    if dimensions == "" {
        return (6, 7)
    }
    var lowercasedDimensions = dimensions.lowercased()
    lowercasedDimensions.removeAll(where: {$0 == " "})
    guard let xIndex = lowercasedDimensions.firstIndex(of: "x") else {
        print("kek")
        throw DimensionsError.invalidInput
    }
    guard let rows = Int(lowercasedDimensions[..<xIndex]), let cols = Int(lowercasedDimensions[lowercasedDimensions.index(after: xIndex)...]) else {
        print("lol")
        throw DimensionsError.invalidInput
    }
    if rows > 9 || rows < 5 {
        throw DimensionsError.rowsOutOfBounds
    }
    if cols > 9 || cols < 5 {
        throw DimensionsError.colsOutOfBounds
    }
    return (rows, cols)
}

class GameCore {
    private let player1: String
    private let player2: String
    private let rows: Int
    private let cols: Int
    
    
    init(player1: String, player2: String, rows: Int, cols: Int) {
        self.player1 = player1
        self.player2 = player2
        self.rows = rows
        self.cols = cols
    }
}

func inputAllData() {
    print("Connect Four")
    // Ввод имён игроков.
    var player1: String? = ""
    var player2: String? = ""
    while player1 == "" {
        print("First player's name:")
        player1 = readLine()
    }
    while player2 == "" {
        print("Second player's name:")
        player2 = readLine()
    }
    // Ввод количества строк и столбцов.
    print("Set the board dimensions (Rows x Columns) \nPress Enter for default (6 x 7)")
    var dimensionsString = ""
    var correctInput = false
    var dimensions: (Int, Int) = (0, 0)
    while !correctInput {
        dimensionsString = readLine()!
        do {
            dimensions = try getDimensions(dimensions: dimensionsString)
            correctInput = true
        }
        catch DimensionsError.colsOutOfBounds {
            print("Board columns should be from 5 to 9")
        }
        catch DimensionsError.rowsOutOfBounds {
            print("Board rows should be from 5 to 9")
        }
        catch {
            print("Invalid input")
        }
    }

    print("\(player1!) VS \(player2!)")
    print("\(dimensions.0) X \(dimensions.1) board")
}

inputAllData()



