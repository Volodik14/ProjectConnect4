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
    // Преобразования для получения корректного формата.
    var lowercasedDimensions = dimensions.lowercased()
    lowercasedDimensions.removeAll(where: {$0 == " "})
    // Проверки на корректный ввод.
    guard let xIndex = lowercasedDimensions.firstIndex(of: "x") else {
        throw DimensionsError.invalidInput
    }
    guard let rows = Int(lowercasedDimensions[..<xIndex]), let cols = Int(lowercasedDimensions[lowercasedDimensions.index(after: xIndex)...]) else {
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
    private var colsArrays: [[Character]]
    private var turn: Int
    private let maxTurn: Int
    
    
    init(player1: String, player2: String, rows: Int, cols: Int) {
        self.player1 = player1
        self.player2 = player2
        self.rows = rows
        self.cols = cols
        colsArrays = Array(repeating: [Character](), count: cols)
        turn = 0
        maxTurn = cols * rows
    }
    
    // Печатает доску
    func drawBoard() {
        // Номера столбцов.
        for i in 0..<cols {
            print(" \(i+1)", terminator: "")
        }
        print("")
        // Содержимое столбцов.
        for i in (0..<rows).reversed()  {
            print("║", separator: "", terminator: "")
            for j in 0..<cols {
                // Проверка, есть ли в столбце значение.
                if i >= colsArrays[j].count {
                    print(" ", separator: "", terminator: "")
                } else {
                    print(colsArrays[j][i], separator: "", terminator: "")
                }
                print("║", separator: "", terminator: "")
            }
            print("")
        }
        // Дно столбцов.
        print("╚═", separator: "", terminator: "")
        for _ in 1..<cols {
            print("╩═", separator: "", terminator: "")
        }
        print("╝")
    }
    
    
    // Несколько страшная функция, но таким образом мы не проходим дважды по уже рассмотренным элементам при проверке строк и столбцов, как например при использовании фильтра.
    // Также понял, что можно было бы рассматривать победу только для добавленной точки, это было бы быстрее и проще.
    func checkWin() -> Bool {
        // Проверка 1 столбца на 4-в-ряд.
        func checkCol(col: [Character]) -> Bool {
            // Не рассматриваем если меньше элементов.
            if col.count < 4 {
                return false
            }
            var i = 0
            var count = 1
            // Проверяем пока не останутся 4 элемента для проверки
            while col.count - i > 4 {
                if col[i] == col[i+1] {
                    count += 1
                } else {
                    count = 1
                }
                // Проверяем 4-в-ряд.
                if count == 4 {
                    return true
                }
                i += 1
            }
            // Если попадается хоть 1 не равный изначальному элемент среди оставшихся 4-х - ряд отсутствует.
            while i < col.count-1 {
                if col[i] != col[i+1] {
                    return false
                }
                i += 1
            }
            return true
        }
        
        // Проверяем 4-в-ряд в каждом ряду.
        func checkRow(rowi: Int) -> Bool {
            var i = 0
            var count = 1
            // Проверяем пока не останется 4 элемента.
            while cols - i > 4 {
                if colsArrays[i].count < rowi+1 {
                    count = 1
                } else {
                    if colsArrays[i+1].count < rowi+1  {
                        count = 1
                    } else if colsArrays[i][rowi] == colsArrays[i+1][rowi] {
                        count += 1
                    } else {
                        count = 1
                    }
                }
                // Проверяем 4-в-ряд.
                if count == 4 {
                    return true
                }
                i += 1
            }
            // Если попадается хоть 1 не равный изначальному элемент среди оставшихся 4-х - ряд отсутствует.
            while i < cols-1 {
                if colsArrays[i].count < rowi+1 || colsArrays[i+1].count < rowi+1  {
                    return false
                }
                if colsArrays[i][rowi] != colsArrays[i+1][rowi] {
                    return false
                }
                i += 1
            }
            return true
        }
        
        // Проверка диагонали на наличие ряда. Здесь уже в качестве примера использовал фильтр.
        func checkDiag(startCol: Int, startRow: Int) -> Bool {
            if colsArrays[startCol].count <= startRow {
                return false
            }
            else {
                let char = colsArrays[startCol][startRow]
                for i in (1...3) {
                    if colsArrays[startCol + i].count <= startRow + i {
                        return false
                    } else if colsArrays[startCol+i][startRow+i] != char {
                        return false
                    }
                }
            }
            return true
        }
        
        // Проверка диагонали в другую сторону.
        func checkDiagReverse(startCol: Int, startRow: Int) -> Bool {
            if colsArrays[startCol].count <= startRow {
                return false
            }
            else {
                let char = colsArrays[startCol][startRow]
                for i in (1...3) {
                    if colsArrays[startCol-i].count <= startRow + i {
                        return false
                    } else if colsArrays[startCol-i][startRow+i] != char {
                        return false
                    }
                }
            }
            return true
        }
        
        // Проверка всех столбцов.
        func checkCols() -> Bool {
            for col in colsArrays {
                if checkCol(col: col) {
                    return true
                }
            }
            return false
        }
        
        // Проверка всех строк.
        func checkRows() -> Bool {
            for rowi in (0..<rows).reversed() {
                if checkRow(rowi: rowi) {
                    return true
                }
            }
            return false
        }
        
        // Проверка всех диагоналей.
        func checkDiags() -> Bool {
            for coli in (0...cols-4) {
                for rowi in (0...rows-4) {
                    if checkDiag(startCol: coli, startRow: rowi) || checkDiagReverse(startCol: cols-coli-1, startRow: rowi) {
                        return true
                    }
                }
            }
            return false
        }
        
        // Вызов всех функций для проверки.
        return checkCols() || checkRows() || checkDiags()
    }
    
    // Функция для начала игры.
    func startGame() {
        // Ходит ли сейчас первый игрок.
        var turnFirst = true
        var input = ""
        while input != "end" {
            if turnFirst {
                print("\(player1)'s turn")
            } else {
                print("\(player2)'s turn")
            }
            // Флаг для проверки корректности ввода.
            var correct = false
            var col = 0
            while !correct {
                input = readLine()!
                // Если ввели конец игры - останавливаем игру.
                if input == "end" {
                    print("Game over!")
                    break
                }
                // Проверка номера столбца на корректность.
                if let number = Int(input) {
                    if number > cols {
                        print("The column number is out of range (1 - \(cols)")
                    } else if colsArrays[number-1].count == rows {
                        print("Column \(number) is full")
                    } else {
                        correct = true
                        col = number - 1
                    }
                } else {
                    print("Incorrect column number")
                }
            }
            // Добавляем значение в столбец.
            if turnFirst {
                colsArrays[col].append("o")
            } else {
                colsArrays[col].append("*")
            }
            drawBoard()
            // Проверяем победу, если она есть, то тот, кто только что ходил, является победителем.
            if checkWin() {
                if turnFirst {
                    print("Player \(player1) won")
                } else {
                    print("Player \(player2) won")
                }
                print("Game Over!")
                return
            }
            // Если дошли до максимально возможного хода.
            if turn == maxTurn {
                print("It is a draw")
                print("Game Over!")
                return
            }
            // Переключаемся на ход оппонента.
            turnFirst.toggle()
            turn += 1
        }
        
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

// Main.
let (player1, player2, rows, cols) = inputAllData()
print("\(player1) VS \(player2)")
print("\(rows) X \(cols) board")
let gameCore = GameCore(player1: player1, player2: player2, rows: rows, cols: cols)
gameCore.drawBoard()
gameCore.startGame()



