import Foundation

class Calculator {
    var memory: Double = 0.0
    var history: [String] = []
    var radianMode: Bool = false
    
    let constants: [String: Double] = [
        "pi": Double.pi,
        "e": M_E,
        "c": 299792458.0,
        "g": 9.80665,
        "h": 6.62607015e-34
    ]
    
    func toRadians(_ degrees: Double) -> Double {
        return degrees * Double.pi / 180.0
    }
    
    func toDegrees(_ radians: Double) -> Double {
        return radians * 180.0 / Double.pi
    }
    
    func getAngle(_ x: Double) -> Double {
        return radianMode ? x : toRadians(x)
    }
    
    func fromAngle(_ radians: Double) -> Double {
        return radianMode ? radians : toDegrees(radians)
    }
    
    func calculate(_ a: Double, _ b: Double, _ op: Character) throws -> Double {
        var result: Double
        switch op {
        case "+": result = a + b
        case "-": result = a - b
        case "*": result = a * b
        case "/":
            guard b != 0 else { throw CalculatorError.divisionByZero }
            result = a / b
        case "%":
            guard b != 0 else { throw CalculatorError.moduloByZero }
            result = a.truncatingRemainder(dividingBy: b)
        case "^":
            result = pow(a, b)
        default:
            throw CalculatorError.unknownOperator(op)
        }
        // Check for NaN or Infinity
        guard !result.isNaN else { throw CalculatorError.invalidPower }
        guard !result.isInfinite else { throw CalculatorError.overflow }
        return result
    }
    
    func factorial(_ n: Double) throws -> Double {
        guard n >= 0 && n == floor(n) else {
            throw CalculatorError.factorialDomain
        }
        guard n <= 170 else {
            throw CalculatorError.factorialOverflow
        }
        let intN = Int(n)
        if intN == 0 || intN == 1 { return 1.0 }
        var result = 1.0
        for i in 2...intN {
            result *= Double(i)
        }
        return result
    }
    
    func unaryFunction(_ x: Double, _ funcName: String) throws -> Double {
        switch funcName.lowercased() {
        case "sin": return sin(getAngle(x))
        case "cos": return cos(getAngle(x))
        case "tan":
            let angle = getAngle(x)
            guard abs(cos(angle)) >= 1e-9 else {
                throw CalculatorError.undefinedTan
            }
            return tan(angle)
        case "cot":
            let angle = getAngle(x)
            guard abs(sin(angle)) >= 1e-9 else {
                throw CalculatorError.undefinedCot
            }
            return 1.0 / tan(angle)
        case "sec":
            let angle = getAngle(x)
            guard abs(cos(angle)) >= 1e-9 else {
                throw CalculatorError.undefinedSec
            }
            return 1.0 / cos(angle)
        case "csc":
            let angle = getAngle(x)
            guard abs(sin(angle)) >= 1e-9 else {
                throw CalculatorError.undefinedCsc
            }
            return 1.0 / sin(angle)
        case "asin":
            guard x >= -1 && x <= 1 else { throw CalculatorError.asinDomain }
            return fromAngle(asin(x))
        case "acos":
            guard x >= -1 && x <= 1 else { throw CalculatorError.acosDomain }
            return fromAngle(acos(x))
        case "atan": return fromAngle(atan(x))
        case "sinh": return sinh(x)
        case "cosh": return cosh(x)
        case "tanh": return tanh(x)
        case "asinh": return asinh(x)
        case "acosh":
            guard x >= 1 else { throw CalculatorError.acoshDomain }
            return acosh(x)
        case "atanh":
            guard x > -1 && x < 1 else { throw CalculatorError.atanhDomain }
            return atanh(x)
        case "sqrt":
            guard x >= 0 else { throw CalculatorError.sqrtDomain }
            return sqrt(x)
        case "cbrt": return cbrt(x)
        case "ln":
            guard x > 0 else { throw CalculatorError.logDomain }
            return log(x)
        case "log":
            guard x > 0 else { throw CalculatorError.logDomain }
            return log10(x)
        case "exp":
            let result = exp(x)
            guard !result.isInfinite else { throw CalculatorError.overflow }
            return result
        case "abs": return abs(x)
        case "factorial": return try factorial(x)
        default:
            throw CalculatorError.unknownFunction(funcName)
        }
    }
    
    func addToHistory(_ entry: String) {
        if history.count >= 10 {
            history.removeFirst()
        }
        history.append(entry)
    }
    
    func showHistory() {
        if history.isEmpty {
            print("History is empty.")
        } else {
            print("\n=== History ===")
            for entry in history {
                print(entry)
            }
        }
    }
    
    func convertUnits(_ value: Double, from: String, to: String) throws -> Double {
        switch (from, to) {
        case ("m", "cm"): return value * 100
        case ("cm", "m"): return value / 100
        case ("km", "m"): return value * 1000
        case ("m", "km"): return value / 1000
        case ("deg", "rad"): return toRadians(value)
        case ("rad", "deg"): return toDegrees(value)
        default: throw CalculatorError.unsupportedConversion
        }
    }
    
    func statistics(_ data: [Double]) -> (mean: Double, stdDev: Double) {
        guard !data.isEmpty else { return (0.0, 0.0) }
        let mean = data.reduce(0, +) / Double(data.count)
        let variance = data.map { pow($0 - mean, 2) }.reduce(0, +) / Double(data.count)
        return (mean, sqrt(variance))
    }
    
    func toggleMode() {
        radianMode = !radianMode
        print("Mode: \(radianMode ? "Radians" : "Degrees")")
    }
    
    func reset() {
        memory = 0.0
        history.removeAll()
        radianMode = false
        print("Calculator reset.")
    }
}

enum CalculatorError: Error, CustomStringConvertible {
    case divisionByZero
    case moduloByZero
    case invalidPower
    case overflow
    case unknownOperator(Character)
    case factorialDomain
    case factorialOverflow
    case undefinedTan
    case undefinedCot
    case undefinedSec
    case undefinedCsc
    case asinDomain
    case acosDomain
    case acoshDomain
    case atanhDomain
    case sqrtDomain
    case logDomain
    case unknownFunction(String)
    case unsupportedConversion
    
    var description: String {
        switch self {
        case .divisionByZero: return "Division by zero"
        case .moduloByZero: return "Modulo by zero"
        case .invalidPower: return "Invalid operation (result is undefined)"
        case .overflow: return "Overflow (result too large)"
        case .unknownOperator(let op): return "Unknown operator: \(op)"
        case .factorialDomain: return "Factorial requires non-negative integer"
        case .factorialOverflow: return "Factorial overflow (n > 170)"
        case .undefinedTan: return "Undefined tan (angle near 90°)"
        case .undefinedCot: return "Undefined cot (angle near 0°)"
        case .undefinedSec: return "Undefined sec (angle near 90°)"
        case .undefinedCsc: return "Undefined csc (angle near 0°)"
        case .asinDomain: return "asin domain is [-1, 1]"
        case .acosDomain: return "acos domain is [-1, 1]"
        case .acoshDomain: return "acosh domain is [1, ∞)"
        case .atanhDomain: return "atanh domain is (-1, 1)"
        case .sqrtDomain: return "Cannot take square root of negative number"
        case .logDomain: return "log domain is (0, ∞)"
        case .unknownFunction(let f): return "Unknown function: \(f)"
        case .unsupportedConversion: return "Unsupported conversion"
        }
    }
}

func readLine(prompt: String) -> String {
    print(prompt, terminator: "")
    return Swift.readLine() ?? ""
}

func readDouble(prompt: String) -> Double {
    return Double(readLine(prompt: prompt)) ?? 0.0
}

func showMenu() {
    print("\n=== Scientific Calculator (Swift) ===")
    print("1.  Basic Operation (+, -, *, /, %, ^)")
    print("2.  Unary Function (sqrt, cbrt, ln, log, exp, abs, factorial)")
    print("3.  Trigonometry (sin, cos, tan)")
    print("4.  Inverse Trig (asin, acos, atan)")
    print("5.  Hyperbolic (sinh, cosh, tanh)")
    print("6.  Unit Conversion")
    print("7.  Statistics (mean, std dev)")
    print("8.  Memory Add (M+)")
    print("9.  Memory Subtract (M-)")
    print("10. Memory Recall (MR)")
    print("11. Memory Clear (MC)")
    print("12. Toggle Mode (Deg/Rad)")
    print("13. Show History")
    print("14. Reset")
    print("15. Exit")
}

let calc = Calculator()
var running = true

while running {
    showMenu()
    let choice = readLine(prompt: "\nSelect option: ")
    
    switch choice {
    case "1":
        let a = readDouble(prompt: "Enter first number: ")
        let opStr = readLine(prompt: "Enter operator (+, -, *, /, %, ^): ")
        let op = opStr.first ?? "+"
        let b = readDouble(prompt: "Enter second number: ")
        do {
            let result = try calc.calculate(a, b, op)
            print("Result: \(result)")
            calc.addToHistory("\(a) \(op) \(b) = \(result)")
        } catch {
            print("Error: \(error)")
        }
        
    case "2":
        let funcName = readLine(prompt: "Enter function (sqrt, cbrt, ln, log, exp, abs, factorial): ")
        let x = readDouble(prompt: "Enter value: ")
        do {
            let result = try calc.unaryFunction(x, funcName)
            print("Result: \(result)")
            calc.addToHistory("\(funcName)(\(x)) = \(result)")
        } catch {
            print("Error: \(error)")
        }
        
    case "3":
        let funcName = readLine(prompt: "Enter function (sin, cos, tan): ")
        let x = readDouble(prompt: "Enter angle: ")
        do {
            let result = try calc.unaryFunction(x, funcName)
            print("Result: \(result)")
            calc.addToHistory("\(funcName)(\(x)) = \(result)")
        } catch {
            print("Error: \(error)")
        }
        
    case "4":
        let funcName = readLine(prompt: "Enter function (asin, acos, atan): ")
        let x = readDouble(prompt: "Enter value: ")
        do {
            let result = try calc.unaryFunction(x, funcName)
            print("Result: \(result) \(calc.radianMode ? "rad" : "°")")
            calc.addToHistory("\(funcName)(\(x)) = \(result)")
        } catch {
            print("Error: \(error)")
        }
        
    case "5":
        let funcName = readLine(prompt: "Enter function (sinh, cosh, tanh): ")
        let x = readDouble(prompt: "Enter value: ")
        do {
            let result = try calc.unaryFunction(x, funcName)
            print("Result: \(result)")
            calc.addToHistory("\(funcName)(\(x)) = \(result)")
        } catch {
            print("Error: \(error)")
        }
        
    case "6":
        let value = readDouble(prompt: "Enter value: ")
        let from = readLine(prompt: "From unit (m, cm, km, deg, rad): ")
        let to = readLine(prompt: "To unit: ")
        do {
            let result = try calc.convertUnits(value, from: from, to: to)
            print("Result: \(result) \(to)")
            calc.addToHistory("\(value) \(from) = \(result) \(to)")
        } catch {
            print("Error: \(error)")
        }
        
    case "7":
        let input = readLine(prompt: "Enter numbers (space-separated): ")
        let data = input.split(separator: " ").compactMap { Double($0) }
        let stats = calc.statistics(data)
        print("Mean: \(stats.mean), Std Dev: \(stats.stdDev)")
        calc.addToHistory("Stats: mean=\(stats.mean), std=\(stats.stdDev)")
        
    case "8":
        let value = readDouble(prompt: "Value to add: ")
        calc.memory += value
        print("Memory: \(calc.memory)")
        
    case "9":
        let value = readDouble(prompt: "Value to subtract: ")
        calc.memory -= value
        print("Memory: \(calc.memory)")
        
    case "10":
        print("Memory: \(calc.memory)")
        
    case "11":
        calc.memory = 0.0
        print("Memory cleared.")
        
    case "12":
        calc.toggleMode()
        
    case "13":
        calc.showHistory()
        
    case "14":
        calc.reset()
        
    case "15":
        print("Goodbye!")
        running = false
        
    default:
        print("Invalid option.")
    }
}
