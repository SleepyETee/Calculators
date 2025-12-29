#include "calculator.h"
#include <iostream>
#include <vector>

using namespace std;

int main() {
    Calculator calc;
    double num1, num2, result = 0.0;
    char op, choice;
    bool running = true;

    cout << "=== Optimized Scientific C++ Calculator ===\n";

    while (running) {
        calc.displayMenu();
        cout << "Enter your choice (1-25): ";
        cin >> choice;
        calc.clearInputBuffer();

        switch (choice) {
            case '1': // Basic Operation
                num1 = calc.getNumber("Enter first number (or constant like pi): ");
                op = calc.getOperator();
                num2 = calc.getNumber("Enter second number (or constant): ");
                result = calc.calculate(num1, num2, op);
                cout << num1 << " " << op << " " << num2 << " = " << result << endl;
                calc.addToHistory(to_string(num1) + " " + op + " " + to_string(num2) + " = " + to_string(result));
                break;

            case '2': // Square Root
                num1 = calc.getNumber("Enter a number: ");
                result = calc.calculateUnary(num1, "sqrt");
                cout << "sqrt(" << num1 << ") = " << result << endl;
                calc.addToHistory("sqrt(" + to_string(num1) + ") = " + to_string(result));
                break;

            case '3': // Cube Root
                num1 = calc.getNumber("Enter a number: ");
                result = calc.calculateUnary(num1, "cbrt");
                cout << "cbrt(" << num1 << ") = " << result << endl;
                calc.addToHistory("cbrt(" + to_string(num1) + ") = " + to_string(result));
                break;

            case '4': // Yth Root
                num1 = calc.getNumber("Enter the number (x): ");
                num2 = calc.getNumber("Enter the root (y): ");
                if (num2 == 0) {
                    cout << "Error: Cannot take 0th root!" << endl;
                    result = 0.0;
                } else {
                    result = pow(num1, 1.0 / num2);
                    cout << num2 << "th root of " << num1 << " = " << result << endl;
                    calc.addToHistory(to_string(num2) + "th root of " + to_string(num1) + " = " + to_string(result));
                }
                break;

            case '5': // Trigonometry
                num1 = calc.getNumber("Enter angle: ");
                result = calc.calculateUnary(num1, calc.getFunction("Enter function (sin, cos, tan, cot, sec, csc): ", "trig"));
                cout << "Result: " << result << endl;
                calc.addToHistory("Trig calc = " + to_string(result));
                break;

            case '6': { // Inverse Trigonometry
                num1 = calc.getNumber("Enter value: ");
                result = calc.calculateUnary(num1, calc.getFunction("Enter function (asin, acos, atan, acot, asec, acsc): ", "inverse trig"));
                cout << "Result: " << result << (calc.isRadianMode ? " radians" : " degrees") << endl;
                calc.addToHistory("Inverse trig calc = " + to_string(result));
                break;
            }

            case '7': // Hyperbolic
                num1 = calc.getNumber("Enter value: ");
                result = calc.calculateUnary(num1, calc.getFunction("Enter function (sinh, cosh, tanh, coth, sech, csch): ", "hyperbolic"));
                cout << "Result: " << result << endl;
                calc.addToHistory("Hyperbolic calc = " + to_string(result));
                break;

            case '8': // Inverse Hyperbolic
                num1 = calc.getNumber("Enter value: ");
                result = calc.calculateUnary(num1, calc.getFunction("Enter function (asinh, acosh, atanh, acoth, asech, acsch): ", "inverse hyperbolic"));
                cout << "Result: " << result << endl;
                calc.addToHistory("Inverse hyperbolic calc = " + to_string(result));
                break;

            case '9': // Logarithm
                num1 = calc.getNumber("Enter a number: ");
                result = calc.calculateUnary(num1, calc.getFunction("Enter function (log, ln): ", "logarithm"));
                cout << "Result: " << result << endl;
                calc.addToHistory("Log calc = " + to_string(result));
                break;

            case '10': // Exponential
                num1 = calc.getNumber("Enter exponent: ");
                result = calc.calculateUnary(num1, calc.getFunction("Enter function (exp, tenpow): ", "exponential"));
                cout << "Result: " << result << endl;
                calc.addToHistory("Exp calc = " + to_string(result));
                break;

            case '11': // Factorial
                num1 = calc.getNumber("Enter a non-negative integer: ");
                result = calc.calculateUnary(num1, "factorial");
                cout << num1 << "! = " << result << endl;
                calc.addToHistory(to_string(num1) + "! = " + to_string(result));
                break;

            case '12': { // Expression Mode
                cout << "Enter an expression (e.g., 2 + 3 * 4 or (pi * 2)): ";
                string expr;
                getline(cin, expr);
                result = calc.parseExpression(expr);
                cout << "Result: " << result << endl;
                break;
            }

            case '13': { // Complex Numbers
                cout << "Enter first complex number (e.g., 2 + 3i): ";
                string c1_str;
                getline(cin, c1_str);
                Calculator::Complex c1 = calc.parseComplex(c1_str);
                op = calc.getOperator("+-*/");
                cout << "Enter second complex number (e.g., 4 - 2i): ";
                string c2_str;
                getline(cin, c2_str);
                Calculator::Complex c2 = calc.parseComplex(c2_str);
                Calculator::Complex c_result = calc.calculateComplex(c1, c2, op);
                cout << calc.formatComplex(c1) << " " << op << " " << calc.formatComplex(c2) << " = " << calc.formatComplex(c_result) << endl;
                calc.addToHistory(calc.formatComplex(c1) + " " + op + " " + calc.formatComplex(c2) + " = " + calc.formatComplex(c_result));
                break;
            }

            case '14': { // Unit Conversion
                num1 = calc.getNumber("Enter value: ");
                cout << "Enter from unit (m, cm, deg, rad, km): ";
                string from;
                cin >> from;
                cout << "Enter to unit (m, cm, deg, rad, km): ";
                string to;
                cin >> to;
                result = calc.convertUnits(num1, from, to);
                cout << num1 << " " << from << " = " << result << " " << to << endl;
                calc.addToHistory(to_string(num1) + " " + from + " = " + to_string(result) + " " + to);
                calc.clearInputBuffer();
                break;
            }

            case '15': { // Statistics
                cout << "Enter numbers (space-separated, end with 'done'): ";
                vector<double> data;
                string input;
                while (cin >> input && input != "done") data.push_back(stod(input));
                auto [mean, stddev] = calc.calculateStats(data);
                cout << "Mean: " << mean << ", Std Dev: " << stddev << endl;
                calc.addToHistory("Stats: Mean = " + to_string(mean) + ", Std Dev = " + to_string(stddev));
                calc.clearInputBuffer();
                break;
            }

            case '16': { // Solve Equation
                cout << "Enter equation with 'x' (e.g., x ^ 2 - 4): ";
                string func;
                getline(cin, func);
                double a = calc.getNumber("Enter lower bound: ");
                double b = calc.getNumber("Enter upper bound: ");
                result = calc.solveEquation(func, a, b);
                cout << "Root: " << result << endl;
                calc.addToHistory("Solve " + func + " = 0, root = " + to_string(result));
                break;
            }

            case '17': // Memory Add (m+)
                calc.storeMemory(result);
                break;

            case '18': // Memory Subtract (m-)
                calc.subtractMemory(result);
                break;

            case '19': // Memory Clear (mc)
                calc.clearMemory();
                break;

            case '20': // Memory Recall (mr)
                result = calc.recallMemory();
                break;

            case '21': // Toggle Mode (Rad/Deg)
                calc.toggleMode();
                break;

            case '22': // Random Number (rand)
                result = calc.getRandom();
                cout << "Random number (0 to 1): " << result << endl;
                calc.addToHistory("Random number = " + to_string(result));
                break;

            case '23': // All Clear (AC)
                calc.reset();
                result = 0.0;
                break;

            case '24': // Show History
                calc.showHistory();
                break;

            case '25': // Exit
                running = false;
                cout << "Goodbye!" << endl;
                break;

            default:
                cout << "Invalid choice! Please select 1-25." << endl;
                break;
        }

        if (running) {
            cout << "\nPress Enter to continue...";
            cin.get();
        }
    }

    return 0;
}