use std::collections::HashMap;
use std::f64::consts::{E, PI};
use std::io::{self, Write};

#[allow(dead_code)]
struct Calculator {
    memory: f64,
    history: Vec<String>,
    radian_mode: bool,
    constants: HashMap<String, f64>,
}

impl Calculator {
    fn new() -> Self {
        let mut constants = HashMap::new();
        constants.insert("pi".to_string(), PI);
        constants.insert("e".to_string(), E);
        constants.insert("c".to_string(), 299792458.0);
        constants.insert("g".to_string(), 9.80665);
        constants.insert("h".to_string(), 6.62607015e-34);

        Calculator {
            memory: 0.0,
            history: Vec::new(),
            radian_mode: false,
            constants,
        }
    }

    fn to_radians(&self, degrees: f64) -> f64 {
        degrees * PI / 180.0
    }

    fn to_degrees(&self, radians: f64) -> f64 {
        radians * 180.0 / PI
    }

    fn get_angle(&self, x: f64) -> f64 {
        if self.radian_mode { x } else { self.to_radians(x) }
    }

    fn from_angle(&self, radians: f64) -> f64 {
        if self.radian_mode { radians } else { self.to_degrees(radians) }
    }

    fn calculate(&self, a: f64, b: f64, op: char) -> Result<f64, String> {
        let result = match op {
            '+' => a + b,
            '-' => a - b,
            '*' => a * b,
            '/' => {
                if b == 0.0 { return Err("Division by zero".to_string()); }
                a / b
            }
            '%' => {
                if b == 0.0 { return Err("Modulo by zero".to_string()); }
                a % b
            }
            '^' => a.powf(b),
            _ => return Err(format!("Unknown operator: {}", op)),
        };
        // Check for NaN or Infinity
        if result.is_nan() {
            Err("Invalid operation (result is undefined)".to_string())
        } else if result.is_infinite() {
            Err("Overflow (result too large)".to_string())
        } else {
            Ok(result)
        }
    }

    fn factorial(&self, n: f64) -> Result<f64, String> {
        if n < 0.0 || n != n.floor() {
            return Err("Factorial requires non-negative integer".to_string());
        }
        if n > 170.0 {
            return Err("Factorial overflow (n > 170)".to_string());
        }
        let n = n as u64;
        if n == 0 || n == 1 { return Ok(1.0); }
        let mut result = 1.0;
        for i in 2..=n {
            result *= i as f64;
        }
        Ok(result)
    }

    fn unary_function(&self, x: f64, func: &str) -> Result<f64, String> {
        match func.to_lowercase().as_str() {
            "sin" => Ok(self.get_angle(x).sin()),
            "cos" => Ok(self.get_angle(x).cos()),
            "tan" => {
                let angle = self.get_angle(x);
                if angle.cos().abs() < 1e-9 {
                    Err("Undefined tan (angle near 90°)".to_string())
                } else {
                    Ok(angle.tan())
                }
            }
            "cot" => {
                let angle = self.get_angle(x);
                if angle.sin().abs() < 1e-9 {
                    Err("Undefined cot (angle near 0°)".to_string())
                } else {
                    Ok(1.0 / angle.tan())
                }
            }
            "sec" => {
                let angle = self.get_angle(x);
                if angle.cos().abs() < 1e-9 {
                    Err("Undefined sec (angle near 90°)".to_string())
                } else {
                    Ok(1.0 / angle.cos())
                }
            }
            "csc" => {
                let angle = self.get_angle(x);
                if angle.sin().abs() < 1e-9 {
                    Err("Undefined csc (angle near 0°)".to_string())
                } else {
                    Ok(1.0 / angle.sin())
                }
            }
            "asin" => {
                if x < -1.0 || x > 1.0 {
                    Err("asin domain is [-1, 1]".to_string())
                } else {
                    Ok(self.from_angle(x.asin()))
                }
            }
            "acos" => {
                if x < -1.0 || x > 1.0 {
                    Err("acos domain is [-1, 1]".to_string())
                } else {
                    Ok(self.from_angle(x.acos()))
                }
            }
            "atan" => Ok(self.from_angle(x.atan())),
            "sinh" => Ok(x.sinh()),
            "cosh" => Ok(x.cosh()),
            "tanh" => Ok(x.tanh()),
            "asinh" => Ok(x.asinh()),
            "acosh" => {
                if x < 1.0 {
                    Err("acosh domain is [1, ∞)".to_string())
                } else {
                    Ok(x.acosh())
                }
            }
            "atanh" => {
                if x <= -1.0 || x >= 1.0 {
                    Err("atanh domain is (-1, 1)".to_string())
                } else {
                    Ok(x.atanh())
                }
            }
            "sqrt" => {
                if x < 0.0 {
                    Err("Cannot take square root of negative number".to_string())
                } else {
                    Ok(x.sqrt())
                }
            }
            "cbrt" => Ok(x.cbrt()),
            "ln" => {
                if x <= 0.0 {
                    Err("ln domain is (0, ∞)".to_string())
                } else {
                    Ok(x.ln())
                }
            }
            "log" => {
                if x <= 0.0 {
                    Err("log domain is (0, ∞)".to_string())
                } else {
                    Ok(x.log10())
                }
            }
            "exp" => {
                let result = x.exp();
                if result.is_infinite() {
                    Err("Overflow (exp result too large)".to_string())
                } else {
                    Ok(result)
                }
            }
            "abs" => Ok(x.abs()),
            "factorial" => self.factorial(x),
            _ => Err(format!("Unknown function: {}", func)),
        }
    }

    fn add_to_history(&mut self, entry: String) {
        if self.history.len() >= 10 {
            self.history.remove(0);
        }
        self.history.push(entry);
    }

    fn show_history(&self) {
        if self.history.is_empty() {
            println!("History is empty.");
        } else {
            println!("\n=== History ===");
            for entry in &self.history {
                println!("{}", entry);
            }
        }
    }

    fn convert_units(&self, value: f64, from: &str, to: &str) -> Result<f64, String> {
        match (from, to) {
            ("m", "cm") => Ok(value * 100.0),
            ("cm", "m") => Ok(value / 100.0),
            ("km", "m") => Ok(value * 1000.0),
            ("m", "km") => Ok(value / 1000.0),
            ("deg", "rad") => Ok(self.to_radians(value)),
            ("rad", "deg") => Ok(self.to_degrees(value)),
            _ => Err("Unsupported conversion".to_string()),
        }
    }

    fn statistics(&self, data: &[f64]) -> (f64, f64) {
        if data.is_empty() { return (0.0, 0.0); }
        let mean = data.iter().sum::<f64>() / data.len() as f64;
        let variance = data.iter().map(|x| (x - mean).powi(2)).sum::<f64>() / data.len() as f64;
        (mean, variance.sqrt())
    }

    fn toggle_mode(&mut self) {
        self.radian_mode = !self.radian_mode;
        println!("Mode: {}", if self.radian_mode { "Radians" } else { "Degrees" });
    }

    fn reset(&mut self) {
        self.memory = 0.0;
        self.history.clear();
        self.radian_mode = false;
        println!("Calculator reset.");
    }
}

fn read_line() -> String {
    let mut input = String::new();
    io::stdin().read_line(&mut input).unwrap_or(0);
    input.trim().to_string()
}

fn read_f64(prompt: &str) -> f64 {
    print!("{}", prompt);
    io::stdout().flush().unwrap();
    let input = read_line();
    if input.is_empty() {
        println!("Warning: Empty input, using 0");
        return 0.0;
    }
    match input.parse() {
        Ok(n) => n,
        Err(_) => {
            println!("Warning: Invalid number '{}', using 0", input);
            0.0
        }
    }
}

fn read_char(prompt: &str, default: char) -> char {
    print!("{}", prompt);
    io::stdout().flush().unwrap();
    let input = read_line();
    if input.is_empty() {
        println!("Warning: Empty input, using '{}'", default);
        return default;
    }
    input.chars().next().unwrap_or(default)
}

fn show_menu() {
    println!("\n=== Scientific Calculator (Rust) ===");
    println!("1.  Basic Operation (+, -, *, /, %, ^)");
    println!("2.  Unary Function (sqrt, cbrt, ln, log, exp, abs, factorial)");
    println!("3.  Trigonometry (sin, cos, tan)");
    println!("4.  Inverse Trig (asin, acos, atan)");
    println!("5.  Hyperbolic (sinh, cosh, tanh)");
    println!("6.  Unit Conversion");
    println!("7.  Statistics (mean, std dev)");
    println!("8.  Memory Add (M+)");
    println!("9.  Memory Subtract (M-)");
    println!("10. Memory Recall (MR)");
    println!("11. Memory Clear (MC)");
    println!("12. Toggle Mode (Deg/Rad)");
    println!("13. Show History");
    println!("14. Reset");
    println!("15. Exit");
}

fn main() {
    let mut calc = Calculator::new();
    
    loop {
        show_menu();
        print!("\nSelect option: ");
        io::stdout().flush().unwrap();
        let choice = read_line();

        match choice.as_str() {
            "1" => {
                let a = read_f64("Enter first number: ");
                let op = read_char("Enter operator (+, -, *, /, %, ^): ", '+');
                let b = read_f64("Enter second number: ");
                match calc.calculate(a, b, op) {
                    Ok(result) => {
                        println!("Result: {}", result);
                        calc.add_to_history(format!("{} {} {} = {}", a, op, b, result));
                    }
                    Err(e) => println!("Error: {}", e),
                }
            }
            "2" => {
                print!("Enter function (sqrt, cbrt, ln, log, exp, abs, factorial): ");
                io::stdout().flush().unwrap();
                let func = read_line();
                let x = read_f64("Enter value: ");
                match calc.unary_function(x, &func) {
                    Ok(result) => {
                        println!("Result: {}", result);
                        calc.add_to_history(format!("{}({}) = {}", func, x, result));
                    }
                    Err(e) => println!("Error: {}", e),
                }
            }
            "3" => {
                print!("Enter function (sin, cos, tan): ");
                io::stdout().flush().unwrap();
                let func = read_line();
                let x = read_f64("Enter angle: ");
                match calc.unary_function(x, &func) {
                    Ok(result) => {
                        println!("Result: {}", result);
                        calc.add_to_history(format!("{}({}) = {}", func, x, result));
                    }
                    Err(e) => println!("Error: {}", e),
                }
            }
            "4" => {
                print!("Enter function (asin, acos, atan): ");
                io::stdout().flush().unwrap();
                let func = read_line();
                let x = read_f64("Enter value: ");
                match calc.unary_function(x, &func) {
                    Ok(result) => {
                        println!("Result: {} {}", result, if calc.radian_mode { "rad" } else { "°" });
                        calc.add_to_history(format!("{}({}) = {}", func, x, result));
                    }
                    Err(e) => println!("Error: {}", e),
                }
            }
            "5" => {
                print!("Enter function (sinh, cosh, tanh): ");
                io::stdout().flush().unwrap();
                let func = read_line();
                let x = read_f64("Enter value: ");
                match calc.unary_function(x, &func) {
                    Ok(result) => {
                        println!("Result: {}", result);
                        calc.add_to_history(format!("{}({}) = {}", func, x, result));
                    }
                    Err(e) => println!("Error: {}", e),
                }
            }
            "6" => {
                let value = read_f64("Enter value: ");
                print!("From unit (m, cm, km, deg, rad): ");
                io::stdout().flush().unwrap();
                let from = read_line();
                print!("To unit: ");
                io::stdout().flush().unwrap();
                let to = read_line();
                match calc.convert_units(value, &from, &to) {
                    Ok(result) => {
                        println!("Result: {} {}", result, to);
                        calc.add_to_history(format!("{} {} = {} {}", value, from, result, to));
                    }
                    Err(e) => println!("Error: {}", e),
                }
            }
            "7" => {
                print!("Enter numbers (space-separated): ");
                io::stdout().flush().unwrap();
                let input = read_line();
                let data: Vec<f64> = input.split_whitespace()
                    .filter_map(|s| s.parse().ok())
                    .collect();
                let (mean, std_dev) = calc.statistics(&data);
                println!("Mean: {}, Std Dev: {}", mean, std_dev);
                calc.add_to_history(format!("Stats: mean={}, std={}", mean, std_dev));
            }
            "8" => {
                let value = read_f64("Value to add: ");
                calc.memory += value;
                println!("Memory: {}", calc.memory);
            }
            "9" => {
                let value = read_f64("Value to subtract: ");
                calc.memory -= value;
                println!("Memory: {}", calc.memory);
            }
            "10" => {
                println!("Memory: {}", calc.memory);
            }
            "11" => {
                calc.memory = 0.0;
                println!("Memory cleared.");
            }
            "12" => calc.toggle_mode(),
            "13" => calc.show_history(),
            "14" => calc.reset(),
            "15" => {
                println!("Goodbye!");
                break;
            }
            _ => println!("Invalid option."),
        }
    }
}
