//
//  main.swift
//  ProjectConnect4
//
//  Created by Владимир Моторкин on 28.01.2022.
//

import Foundation

// Исключения при вводе размера доски.
enum DimensionsError: Error {
    case invalidInput
    case rowsOutOfBounds
    case colsOutOfBounds
}

// Получение размеров доски, переводит строку в кортеж с размерами.
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

// Основной класс игры.
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
    
    // Печатает доску
    func drawBoard() {
        for i in 0..<cols {
            print(" \(i+1)", terminator: "")
        }
        print("")
        for _ in 0..<rows {
            for _ in 0...cols {
                print("║ ", separator: "", terminator: "")
            }
            print("")
        }
        print("╚═", separator: "", terminator: "")
        for _ in 1..<cols {
            print("╩═", separator: "", terminator: "")
        }
        print("╝")
    }
}

// Функция для ввода данных.
func inputAllData() -> (player1 : String, player2 : String, rows : Int, cols: Int) {
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

    return (player1!, player2!, dimensions.0, dimensions.1)
}

let (player1, player2, rows, cols) = inputAllData()
print("\(player1) VS \(player2)")
print("\(rows) X \(cols) board")
let gameCore = GameCore(player1: player1, player2: player2, rows: rows, cols: cols)
gameCore.drawBoard()



