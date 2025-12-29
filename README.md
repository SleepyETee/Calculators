# 🧮 Scientific Calculator Suite

A comprehensive scientific calculator implemented in **8 languages**: C++, Java, Python, JavaScript, Rust, Swift, Haskell, and Elixir — demonstrating cross-language proficiency and software engineering best practices.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Languages](https://img.shields.io/badge/languages-8-green.svg)
![CI](https://github.com/SleepyETee/Calculators/actions/workflows/ci.yml/badge.svg)
![Tests](https://img.shields.io/badge/tests-34%20passed-brightgreen.svg)

## 📸 Screenshots

<details>
<summary>Click to view screenshots</summary>

### Web Calculator (Dark Mode)
![Web Calculator Dark](https://via.placeholder.com/600x400?text=Dark+Mode+Screenshot)

### Web Calculator (Light Mode)  
![Web Calculator Light](https://via.placeholder.com/600x400?text=Light+Mode+Screenshot)

### CLI Version
```
=== Scientific Calculator (Rust) ===
1.  Basic Operation (+, -, *, /, %, ^)
2.  Unary Function (sqrt, cbrt, ln, log, exp, abs, factorial)
3.  Trigonometry (sin, cos, tan, cot, sec, csc)
4.  Inverse Trig (asin, acos, atan)
5.  Hyperbolic (sinh, cosh, tanh, asinh, acosh, atanh)
...

Select option: 3
Enter function: sin
Enter angle: 30
Result: 0.5
```

</details>

## 🌐 Live Demo

**[Try the Web Calculator](./web/index.html)** — No installation required!

## ✨ Features

### Core Operations
- **Basic Arithmetic**: Addition, subtraction, multiplication, division, modulus, exponentiation
- **Square/Cube/Nth Roots**: `sqrt`, `cbrt`, y-th root calculations
- **Factorial**: Support for non-negative integers

### Scientific Functions
- **Trigonometry**: `sin`, `cos`, `tan`, `cot`, `sec`, `csc`
- **Inverse Trigonometry**: `asin`, `acos`, `atan`, `acot`, `asec`, `acsc`
- **Hyperbolic Functions**: `sinh`, `cosh`, `tanh`, `coth`, `sech`, `csch`
- **Inverse Hyperbolic**: `asinh`, `acosh`, `atanh`, `acoth`, `asech`, `acsch`
- **Logarithms**: Natural log (`ln`), base-10 log (`log`)
- **Exponentials**: `exp` (e^x), `tenpow` (10^x)

### Advanced Features
- **Expression Parsing**: Evaluate complex expressions like `2 + 3 * pi`
- **Complex Numbers**: Arithmetic with complex numbers (e.g., `2 + 3i`)
- **Equation Solver**: Numerical root-finding using bisection method
- **Statistics**: Mean and standard deviation calculations
- **Unit Conversions**: m↔cm, km↔m, deg↔rad
- **Memory Functions**: M+, M-, MR, MC
- **Angle Mode Toggle**: Switch between degrees and radians
- **Calculation History**: Track recent calculations

### Constants
- `pi` (π = 3.14159...)
- `e` (Euler's number = 2.71828...)
- `c` (Speed of light = 299,792,458 m/s)
- `g` (Gravity = 9.80665 m/s²)
- `h` (Planck's constant = 6.626×10⁻³⁴ J·s)

## 📁 Project Structure

```
Calculators/
├── web/                    # 🌐 Web (HTML/CSS/JS) - Best for Portfolio
│   ├── index.html
│   ├── styles.css
│   └── calculator.js
├── cpp/                    # C++ Implementation
│   ├── calculator.h
│   ├── calculator.cpp
│   └── main.cpp
├── java/                   # Java Implementation
│   ├── Calculator.java
│   └── CalculatorGUI.java
├── python/                 # Python Implementation
│   └── calculator.py
├── rust/                   # 🦀 Rust Implementation
│   ├── Cargo.toml
│   └── src/main.rs
├── swift/                  # 🦅 Swift Implementation
│   ├── Package.swift
│   └── Sources/main.swift
├── haskell/                # λ Haskell Implementation
│   └── Calculator.hs
├── elixir/                 # 🧪 Elixir Implementation
│   ├── mix.exs
│   └── lib/calculator.ex
├── LICENSE
└── README.md
```

## 🚀 Getting Started

### 🌐 Web Version (Recommended)
Simply open `web/index.html` in your browser, or serve it:
```bash
cd web
# Using Python's built-in server:
python3 -m http.server 8000
# Then open http://localhost:8000
```

**Features:**
- 🌙 Dark/Light theme toggle
- 📱 Fully responsive (mobile-friendly)
- ⌨️ Keyboard support
- 📜 Calculation history with persistence
- 💾 Memory functions (M+, M-, MR, MC, MS)

### C++ Version
```bash
cd cpp
g++ -std=c++17 -o calculator main.cpp calculator.cpp
./calculator
```

### Java Version
```bash
cd java
javac Calculator.java
java Calculator
```

For the GUI version (requires [JFreeChart](https://www.jfree.org/jfreechart/)):
```bash
javac -cp .:jfreechart.jar CalculatorGUI.java
java -cp .:jfreechart.jar CalculatorGUI
```

### Python Version
```bash
cd python
python3 calculator.py
```

### 🦀 Rust Version
```bash
cd rust
cargo run
# Or build release:
cargo build --release
./target/release/calculator
```

### 🦅 Swift Version
```bash
cd swift
swift build
swift run
# Or compile directly:
swiftc Sources/main.swift -o calculator
./calculator
```

### λ Haskell Version
```bash
cd haskell
# Using GHC:
ghc -o calculator Calculator.hs
./calculator
# Or run directly:
runhaskell Calculator.hs
```

### 🧪 Elixir Version
```bash
cd elixir
mix deps.get
mix run -e "Calculator.CLI.main([])"
# Or build escript:
mix escript.build
./calculator
```

## 🎯 Usage Examples

### Basic Operations
```
Select: 1 (Basic Operation)
Enter first number: 25
Enter operator: +
Enter second number: 17
Result: 42
```

### Trigonometry
```
Select: 3 (Trigonometry)
Enter function: sin
Enter angle: 30
Result: 0.5
```

### Expression Evaluation
```
Select: 8 (Expression Evaluation)
Enter expression: 2 + 3 * pi
Result: 11.42477...
```

### Complex Numbers
```
Select: 5 (Complex Numbers)
Enter first complex number: 3 + 4i
Enter operator: *
Enter second complex number: 1 - 2i
Result: 11 - 2i
```

## 🛠️ Technical Highlights

- **Object-Oriented Design**: Clean class structure with encapsulation
- **Expression Parser**: Shunting-yard algorithm for infix to postfix conversion
- **Error Handling**: Domain validation for mathematical functions
- **Memory Management**: Efficient use of data structures (hashmaps for O(1) lookup)
- **Cross-Platform**: Works on Windows, macOS, and Linux

## 📋 Menu Options

| # | Feature | Description |
|---|---------|-------------|
| 1 | Basic Operation | +, -, *, /, %, ^ |
| 2 | Unary Functions | sqrt, cbrt, ln, log, exp, factorial |
| 3 | Trigonometry | sin, cos, tan, cot, sec, csc |
| 4 | Inverse Trig | asin, acos, atan, acot, asec, acsc |
| 5 | Complex Numbers | Complex arithmetic |
| 6 | Unit Conversion | m↔cm, km↔m, deg↔rad |
| 7 | Statistics | Mean, standard deviation |
| 8 | Expression | Parse mathematical expressions |
| 9 | Equation Solver | Find roots using bisection |
| 10-13 | Memory | M+, M-, MR, MC |
| 14 | Toggle Mode | Switch Deg/Rad |
| 15 | Random | Generate random number [0,1] |
| 16 | History | View calculation history |
| 17 | Reset | Clear all data |
| 18 | Exit | Quit program |

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**SleepyETee**

---

*Built with ❤️ to demonstrate proficiency in multiple programming languages and scientific computing concepts.*
