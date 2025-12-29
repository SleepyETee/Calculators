import java.util.*;
import java.util.regex.*;

public class Calculator {
    private static class Complex {
        double real, imag;
        Complex(double r, double i) { real = r; imag = i; }
        @Override
        public String toString() {
            return real + (imag >= 0 ? " + " : " - ") + Math.abs(imag) + "i";
        }
    }

    private double memory = 0.0;
    private final List<String> history = new LinkedList<>();
    public final Map<String, Double> constants;
    private boolean radianMode = false;
    private final Scanner scanner = new Scanner(System.in);

    public Calculator() {
        Map<String, Double> c = new java.util.HashMap<>();
        c.put("pi", Math.PI);
        c.put("e", Math.E);
        c.put("c", 299792458.0);
        c.put("g", 9.80665);
        c.put("h", 6.62607015e-34);
        constants = java.util.Collections.unmodifiableMap(c);
    }

    public void run() {
        boolean running = true;
        double result = 0.0;

        while (running) {
            showMenu();
            System.out.print("Select an option (1-18): ");
            String choice = scanner.nextLine();

            try {
                switch (choice) {
                    case "1": result = basicOp(); break;
                    case "2": result = unaryOp(); break;
                    case "3": case "4": result = trigOp(); break;
                    case "5": result = complexOp(); break;
                    case "6": result = convert(); break;
                    case "7": stats(); break;
                    case "8": result = evaluate(); break;
                    case "9": result = solve(); break;
                    case "10": storeMemory(result); break;
                    case "11": subtractMemory(result); break;
                    case "12": result = recallMemory(); break;
                    case "13": clearMemory(); break;
                    case "14": toggleMode(); break;
                    case "15": result = random(); break;
                    case "16": showHistory(); break;
                    case "17": reset(); result = 0.0; break;
                    case "18": running = false; continue;
                    default: System.out.println("Invalid choice.");
                }
            } catch (Exception e) {
                System.out.println("Error: " + e.getMessage());
            }

            System.out.println("Result: " + result);
            System.out.println("Press Enter to continue...");
            scanner.nextLine();
        }
    }

    private void showMenu() {
        System.out.println("=== Optimized Scientific Java Calculator ===");
        System.out.println("1. Basic Operation (+, -, *, /, %, ^)");
        System.out.println("2. Unary Function (sqrt, cbrt, ln, log, exp, tenpow, factorial)");
        System.out.println("3. Trigonometry (sin, cos, tan, cot, sec, csc)");
        System.out.println("4. Inverse Trigonometry (asin, acos, atan, acot, asec, acsc)");
        System.out.println("5. Complex Numbers (e.g., 2+3i)");
        System.out.println("6. Unit Conversion (m <-> cm, km <-> m, deg <-> rad)");
        System.out.println("7. Statistics (mean, std dev)");
        System.out.println("8. Expression Evaluation (e.g., 2 + 3 * pi)");
        System.out.println("9. Solve Equation (e.g., x^2 - 4 = 0)");
        System.out.println("10. Memory Add (m+)");
        System.out.println("11. Memory Subtract (m-)");
        System.out.println("12. Memory Recall (mr)");
        System.out.println("13. Memory Clear (mc)");
        System.out.println("14. Toggle Mode (Rad/Deg)");
        System.out.println("15. Random Number (0 to 1)");
        System.out.println("16. History");
        System.out.println("17. Reset");
        System.out.println("18. Exit");
    }

    private double getDouble(String prompt) {
        System.out.print(prompt);
        return Double.parseDouble(scanner.nextLine());
    }

    private String getString(String prompt) {
        System.out.print(prompt);
        return scanner.nextLine();
    }

    private double basicOp() {
        double a = getDouble("Enter first number: ");
        String op = getString("Enter operator: ");
        double b = getDouble("Enter second number: ");
        switch (op) {
            case "+": return a + b;
            case "-": return a - b;
            case "*": return a * b;
            case "/": return b == 0 ? err("Divide by zero") : a / b;
            case "%": return b == 0 ? err("Mod by zero") : a % b;
            case "^": return Math.pow(a, b);
            default: return err("Unknown operator");
        }
    }

    private double unaryOp() {
        String func = getString("Function: ");
        double x = getDouble("Enter value: ");
        switch (func) {
            case "sqrt": return x >= 0 ? Math.sqrt(x) : err("Negative sqrt");
            case "cbrt": return Math.cbrt(x);
            case "ln": return x > 0 ? Math.log(x) : err("Ln domain error");
            case "log": return x > 0 ? Math.log10(x) : err("Log domain error");
            case "exp": return Math.exp(x);
            case "tenpow": return Math.pow(10, x);
            case "factorial": return factorial(x);
            default: return err("Unknown function");
        }
    }

    private double factorial(double n) {
        if (n < 0 || n != Math.floor(n)) return err("Factorial requires non-negative int");
        if (n > 170) return err("Factorial overflow (n > 170)");
        double result = 1;
        for (int i = 2; i <= (int) n; i++) result *= i;
        return result;
    }

    private double trigOp() {
        String func = getString("Function: ");
        double x = getDouble("Enter value: ");
        double rad = radianMode ? x : Math.toRadians(x);
        
        // Domain validation
        if ((func.equals("asin") || func.equals("acos")) && (x < -1 || x > 1)) {
            return err(func + " domain is [-1, 1]");
        }
        if ((func.equals("asec") || func.equals("acsc")) && x > -1 && x < 1) {
            return err(func + " domain is |x| >= 1");
        }
        
        // Check for undefined trig values
        double cosVal = Math.cos(rad);
        double sinVal = Math.sin(rad);
        
        switch (func) {
            case "sin": return Math.sin(rad);
            case "cos": return Math.cos(rad);
            case "tan": return Math.abs(cosVal) < 1e-9 ? err("Undefined tan (angle near 90°)") : Math.tan(rad);
            case "cot": return Math.abs(sinVal) < 1e-9 ? err("Undefined cot (angle near 0°)") : 1 / Math.tan(rad);
            case "sec": return Math.abs(cosVal) < 1e-9 ? err("Undefined sec (angle near 90°)") : 1 / cosVal;
            case "csc": return Math.abs(sinVal) < 1e-9 ? err("Undefined csc (angle near 0°)") : 1 / sinVal;
            case "asin": return toMode(Math.asin(x));
            case "acos": return toMode(Math.acos(x));
            case "atan": return toMode(Math.atan(x));
            case "acot": return toMode(Math.PI / 2 - Math.atan(x));
            case "asec": return toMode(Math.acos(1 / x));
            case "acsc": return toMode(Math.asin(1 / x));
            default: return err("Unknown trig func");
        }
    }

    private double toMode(double radians) {
        return radianMode ? radians : Math.toDegrees(radians);
    }

    private double convert() {
        double val = getDouble("Value: ");
        String from = getString("From unit: ");
        String to = getString("To unit: ");
        String key = from + ":" + to;
        switch (key) {
            case "m:cm": return val * 100;
            case "cm:m": return val / 100;
            case "deg:rad": return Math.toRadians(val);
            case "rad:deg": return Math.toDegrees(val);
            case "km:m": return val * 1000;
            case "m:km": return val / 1000;
            default: return err("Unsupported conversion");
        }
    }

    private void stats() {
        System.out.print("Enter numbers space-separated: ");
        String[] tokens = scanner.nextLine().split(" ");
        List<Double> nums = new ArrayList<>();
        for (String t : tokens) nums.add(Double.parseDouble(t));
        double avg = nums.stream().mapToDouble(Double::doubleValue).average().orElse(0.0);
        double variance = nums.stream().mapToDouble(n -> Math.pow(n - avg, 2)).sum() / nums.size();
        System.out.println("Mean: " + avg + ", StdDev: " + Math.sqrt(variance));
    }

    private double evaluate() {
        System.out.print("Enter expression (constants like pi supported): ");
        String expr = scanner.nextLine();
        for (Map.Entry<String, Double> c : constants.entrySet()) {
            expr = expr.replace(c.getKey(), Double.toString(c.getValue()));
        }
        final String expression = expr;
        try {
            return new Object() {
                int pos = -1, ch;
                void nextChar() { ch = (++pos < expression.length()) ? expression.charAt(pos) : -1; }
                boolean eat(int charToEat) {
                    while (ch == ' ') nextChar();
                    if (ch == charToEat) { nextChar(); return true; }
                    return false;
                }
                double parse() {
                    nextChar(); double x = parseExpression(); if (pos < expression.length()) throw new RuntimeException("Unexpected: " + (char)ch); return x;
                }
                double parseExpression() {
                    double x = parseTerm();
                    while (true) {
                        if      (eat('+')) x += parseTerm();
                        else if (eat('-')) x -= parseTerm();
                        else return x;
                    }
                }
                double parseTerm() {
                    double x = parseFactor();
                    while (true) {
                        if      (eat('*')) x *= parseFactor();
                        else if (eat('/')) x /= parseFactor();
                        else return x;
                    }
                }
                double parseFactor() {
                    if (eat('+')) return parseFactor();
                    if (eat('-')) return -parseFactor();

                    double x;
                    int startPos = this.pos;
                    if (eat('(')) {
                        x = parseExpression();
                        eat(')');
                    } else if ((ch >= '0' && ch <= '9') || ch == '.') {
                        while ((ch >= '0' && ch <= '9') || ch == '.') nextChar();
                        x = Double.parseDouble(expression.substring(startPos, this.pos));
                    } else {
                        throw new RuntimeException("Unexpected: " + (char)ch);
                    }

                    if (eat('^')) x = Math.pow(x, parseFactor());
                    return x;
                }
            }.parse();
        } catch (Exception e) {
            return err("Invalid expression");
        }
    }

    private double solve() {
        System.out.print("Enter function of x (e.g., x*x - 4): ");
        String expr = scanner.nextLine();
        double a = getDouble("Lower bound: ");
        double b = getDouble("Upper bound: ");
        for (int i = 0; i < 100; i++) {
            double c = (a + b) / 2;
            double fa = evalFunc(expr, a), fc = evalFunc(expr, c);
            if (Math.abs(fc) < 1e-6) return c;
            if (fa * fc < 0) b = c;
            else a = c;
        }
        return (a + b) / 2;
    }

    private double evalFunc(String expr, double x) {
        return evaluate(expr.replace("x", Double.toString(x)));
    }

    private double complexOp() {
        System.out.print("Enter first complex number (e.g., 2 + 3i): ");
        Complex c1 = parseComplex(scanner.nextLine());
        String op = getString("Operator (+ - * /): ");
        System.out.print("Enter second complex number (e.g., 1 - 2i): ");
        Complex c2 = parseComplex(scanner.nextLine());

        Complex result;
        switch (op) {
            case "+":
                result = new Complex(c1.real + c2.real, c1.imag + c2.imag);
                break;
            case "-":
                result = new Complex(c1.real - c2.real, c1.imag - c2.imag);
                break;
            case "*":
                result = new Complex(
                        c1.real * c2.real - c1.imag * c2.imag,
                        c1.real * c2.imag + c1.imag * c2.real
                );
                break;
            case "/":
                double denom = c2.real * c2.real + c2.imag * c2.imag;
                if (denom == 0) return err("Complex divide by zero");
                result = new Complex(
                        (c1.real * c2.real + c1.imag * c2.imag) / denom,
                        (c1.imag * c2.real - c1.real * c2.imag) / denom
                );
                break;
            default:
                return err("Invalid complex operator");
        }
        String resStr = c1 + " " + op + " " + c2 + " = " + result;
        history.add(resStr);
        System.out.println(resStr);
        return 0.0;
    }

    private Complex parseComplex(String input) {
        input = input.replace(" ", "");
        Pattern pattern = Pattern.compile("([-+]?\\d*\\.?\\d+)?([+-]\\d*\\.?\\d*)i");
        Matcher matcher = pattern.matcher(input);
        if (matcher.matches()) {
            double real = matcher.group(1) != null && !matcher.group(1).isEmpty() ? Double.parseDouble(matcher.group(1)) : 0.0;
            double imag = matcher.group(2) != null ? Double.parseDouble(matcher.group(2)) : 0.0;
            return new Complex(real, imag);
        } else if (input.contains("i")) {
            double imag = Double.parseDouble(input.replace("i", ""));
            return new Complex(0, imag);
        } else {
            return new Complex(Double.parseDouble(input), 0);
        }
    }

    public double recallMemory() {
        System.out.println("Memory: " + memory);
        return memory;
    }

    private void storeMemory(double value) {
        memory += value;
        System.out.println("Memory += " + value);
    }

    private void subtractMemory(double value) {
        memory -= value;
        System.out.println("Memory -= " + value);
    }

    private void clearMemory() {
        memory = 0.0;
        System.out.println("Memory cleared.");
    }

    private void reset() {
        memory = 0.0;
        history.clear();
        radianMode = false;
        System.out.println("Calculator reset.");
    }

    private void showHistory() {
        if (history.isEmpty()) System.out.println("No history.");
        else history.forEach(System.out::println);
    }

    private double random() {
        return Math.random();
    }

    private double err(String msg) {
        System.out.println("Error: " + msg);
        return 0.0;
    }

    /**
     * Public method to evaluate a mathematical expression string.
     * Used by CalculatorGUI for expression evaluation.
     */
    public double evaluate(String expr) {
        for (Map.Entry<String, Double> c : constants.entrySet()) {
            expr = expr.replace(c.getKey(), Double.toString(c.getValue()));
        }
        try {
            final String expression = expr;
            return new Object() {
                int pos = -1, ch;
                void nextChar() { ch = (++pos < expression.length()) ? expression.charAt(pos) : -1; }
                boolean eat(int charToEat) {
                    while (ch == ' ') nextChar();
                    if (ch == charToEat) { nextChar(); return true; }
                    return false;
                }
                double parse() {
                    nextChar(); double x = parseExpression(); if (pos < expression.length()) throw new RuntimeException("Unexpected: " + (char)ch); return x;
                }
                double parseExpression() {
                    double x = parseTerm();
                    while (true) {
                        if      (eat('+')) x += parseTerm();
                        else if (eat('-')) x -= parseTerm();
                        else return x;
                    }
                }
                double parseTerm() {
                    double x = parseFactor();
                    while (true) {
                        if      (eat('*')) x *= parseFactor();
                        else if (eat('/')) x /= parseFactor();
                        else return x;
                    }
                }
                double parseFactor() {
                    if (eat('+')) return parseFactor();
                    if (eat('-')) return -parseFactor();

                    double x;
                    int startPos = this.pos;
                    if (eat('(')) {
                        x = parseExpression();
                        eat(')');
                    } else if ((ch >= '0' && ch <= '9') || ch == '.') {
                        while ((ch >= '0' && ch <= '9') || ch == '.') nextChar();
                        x = Double.parseDouble(expression.substring(startPos, this.pos));
                    } else if (Character.isLetter(ch)) {
                        while (Character.isLetter(ch)) nextChar();
                        String func = expression.substring(startPos, this.pos);
                        x = parseFactor();
                        switch (func) {
                            case "sqrt": x = Math.sqrt(x); break;
                            case "sin": x = Math.sin(radianMode ? x : Math.toRadians(x)); break;
                            case "cos": x = Math.cos(radianMode ? x : Math.toRadians(x)); break;
                            case "tan": x = Math.tan(radianMode ? x : Math.toRadians(x)); break;
                            case "log": x = Math.log10(x); break;
                            case "ln": x = Math.log(x); break;
                            case "exp": x = Math.exp(x); break;
                            default: throw new RuntimeException("Unknown function: " + func);
                        }
                    } else {
                        throw new RuntimeException("Unexpected: " + (char)ch);
                    }

                    if (eat('^')) x = Math.pow(x, parseFactor());
                    return x;
                }
            }.parse();
        } catch (Exception e) {
            throw new RuntimeException("Invalid expression: " + e.getMessage());
        }
    }

    public void toggleMode() {
        radianMode = !radianMode;
        System.out.println("Mode: " + (radianMode ? "Radians" : "Degrees"));
    }

    public static void main(String[] args) {
        new Calculator().run();
    }
}
