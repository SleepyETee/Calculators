#include "calculator.h"
#include <iostream>
#include <cmath>
#include <limits>
#include <sstream>
#include <algorithm>
#include <numeric>
#include <random>
#include <regex>

using namespace std;

Calculator::Calculator() : memory(0.0), isRadianMode(false), rng(random_device{}()) {
    initializeFunctions();
    initializeConstants();
    initializeConversions();
    initializePrecedence();
}

void Calculator::initializeFunctions() {
    unaryFunctions["sqrt"] = [](double x) { return x < 0 ? (cout << "Error: Negative sqrt!" << endl, 0.0) : sqrt(x); };
    unaryFunctions["cbrt"] = [](double x) { return cbrt(x); }; // Cube root
    unaryFunctions["yroot"] = [](double x) { return x; }; // Placeholder, handled in main
    unaryFunctions["exp"] = [](double x) { return exp(x); }; // e^x
    unaryFunctions["tenpow"] = [](double x) { return pow(10, x); }; // 10^x
    unaryFunctions["ln"] = [](double x) { return x <= 0 ? (cout << "Error: Ln of non-positive!" << endl, 0.0) : log(x); }; // Natural log
    unaryFunctions["log"] = [](double x) { return x <= 0 ? (cout << "Error: Log of non-positive!" << endl, 0.0) : log10(x); }; // Log base 10
    unaryFunctions["factorial"] = [this](double x) { return factorial(x); }; // Factorial
    unaryFunctions["sin"] = [this](double x) { return sin(isRadianMode ? x : toRadians(x)); };
    unaryFunctions["cos"] = [this](double x) { return cos(isRadianMode ? x : toRadians(x)); };
    unaryFunctions["tan"] = [this](double x) { double angle = isRadianMode ? x : toRadians(x); return fabs(cos(angle)) < 1e-9 ? (cout << "Error: Undefined tan (angle near 90°)!" << endl, 0.0) : tan(angle); };
    unaryFunctions["cot"] = [this](double x) { double angle = isRadianMode ? x : toRadians(x); return fabs(sin(angle)) < 1e-9 ? (cout << "Error: Undefined cot (angle near 0°)!" << endl, 0.0) : 1 / tan(angle); };
    unaryFunctions["sec"] = [this](double x) { double angle = isRadianMode ? x : toRadians(x); return fabs(cos(angle)) < 1e-9 ? (cout << "Error: Undefined sec (angle near 90°)!" << endl, 0.0) : 1 / cos(angle); };
    unaryFunctions["csc"] = [this](double x) { double angle = isRadianMode ? x : toRadians(x); return fabs(sin(angle)) < 1e-9 ? (cout << "Error: Undefined csc (angle near 0°)!" << endl, 0.0) : 1 / sin(angle); };
    unaryFunctions["asin"] = [this](double x) { return (x < -1 || x > 1) ? (cout << "Error: asin domain [-1, 1]!" << endl, 0.0) : (isRadianMode ? asin(x) : toDegrees(asin(x))); };
    unaryFunctions["acos"] = [this](double x) { return (x < -1 || x > 1) ? (cout << "Error: acos domain [-1, 1]!" << endl, 0.0) : (isRadianMode ? acos(x) : toDegrees(acos(x))); };
    unaryFunctions["atan"] = [this](double x) { return isRadianMode ? atan(x) : toDegrees(atan(x)); };
    unaryFunctions["acot"] = [this](double x) { return isRadianMode ? (M_PI / 2 - atan(x)) : toDegrees(M_PI / 2 - atan(x)); };
    unaryFunctions["asec"] = [this](double x) { return (x > -1 && x < 1) ? (cout << "Error: asec domain (-∞, -1] ∪ [1, ∞)!" << endl, 0.0) : (isRadianMode ? acos(1 / x) : toDegrees(acos(1 / x))); };
    unaryFunctions["acsc"] = [this](double x) { return (x > -1 && x < 1) ? (cout << "Error: acsc domain (-∞, -1] ∪ [1, ∞)!" << endl, 0.0) : (isRadianMode ? asin(1 / x) : toDegrees(asin(1 / x))); };
    unaryFunctions["sinh"] = [](double x) { return sinh(x); };
    unaryFunctions["cosh"] = [](double x) { return cosh(x); };
    unaryFunctions["tanh"] = [](double x) { return tanh(x); };
    unaryFunctions["coth"] = [](double x) { return x == 0 ? (cout << "Error: Undefined coth!" << endl, 0.0) : 1 / tanh(x); };
    unaryFunctions["sech"] = [](double x) { return 1 / cosh(x); };
    unaryFunctions["csch"] = [](double x) { return x == 0 ? (cout << "Error: Undefined csch!" << endl, 0.0) : 1 / sinh(x); };
    unaryFunctions["asinh"] = [](double x) { return asinh(x); };
    unaryFunctions["acosh"] = [](double x) { return x < 1 ? (cout << "Error: acosh domain [1, ∞)!" << endl, 0.0) : acosh(x); };
    unaryFunctions["atanh"] = [](double x) { return (x <= -1 || x >= 1) ? (cout << "Error: atanh domain (-1, 1)!" << endl, 0.0) : atanh(x); };
    unaryFunctions["acoth"] = [](double x) { return (x > -1 && x < 1) ? (cout << "Error: acoth domain (-∞, -1) ∪ (1, ∞)!" << endl, 0.0) : atanh(1 / x); };
    unaryFunctions["asech"] = [](double x) { return (x <= 0 || x > 1) ? (cout << "Error: asech domain (0, 1]!" << endl, 0.0) : acosh(1 / x); };
    unaryFunctions["acsch"] = [](double x) { return x == 0 ? (cout << "Error: acsch undefined at 0!" << endl, 0.0) : asinh(1 / x); };
}

void Calculator::initializeConstants() {
    constants["pi"] = M_PI;
    constants["e"] = M_E;
    constants["c"] = 299792458.0; // Speed of light (m/s)
    constants["g"] = 9.80665; // Gravity (m/s^2)
    constants["h"] = 6.62607015e-34; // Planck's constant (J·s)
}

void Calculator::initializeConversions() {
    conversions["m_to_cm"] = [](double x) { return x * 100; };
    conversions["cm_to_m"] = [](double x) { return x / 100; };
    conversions["deg_to_rad"] = [](double x) { return x * M_PI / 180; };
    conversions["rad_to_deg"] = [](double x) { return x * 180 / M_PI; };
    conversions["km_to_m"] = [](double x) { return x * 1000; };
    conversions["m_to_km"] = [](double x) { return x / 1000; };
}

void Calculator::initializePrecedence() {
    operatorPrecedence['+'] = 1;
    operatorPrecedence['-'] = 1;
    operatorPrecedence['*'] = 2;
    operatorPrecedence['/'] = 2;
    operatorPrecedence['%'] = 2;
    operatorPrecedence['^'] = 3;
}

inline double Calculator::toRadians(double angle) const { return angle * M_PI / 180; }
inline double Calculator::toDegrees(double angle) const { return angle * 180 / M_PI; }

double Calculator::getNumber(const string& prompt) {
    cout << prompt;
    string input;
    getline(cin, input);
    if (constants.count(input)) return constants[input];
    double num;
    stringstream ss(input);
    if (!(ss >> num)) {
        cout << "Error: Invalid input. Using 0." << endl;
        return 0.0;
    }
    return num;
}

char Calculator::getOperator(const string& validOps) {
    char op;
    cout << "Enter an operator (" << validOps << "): ";
    cin >> op;
    while (validOps.find(op) == string::npos) {
        cout << "Error: Invalid operator. Enter one of " << validOps << ": ";
        cin >> op;
    }
    clearInputBuffer();
    return op;
}

string Calculator::getFunction(const string& prompt, const string& category) {
    string func;
    cout << prompt;
    cin >> func;
    while (!unaryFunctions.count(func)) {
        cout << "Error: Invalid " << category << " function. Try again: ";
        cin >> func;
    }
    clearInputBuffer();
    return func;
}

double Calculator::calculate(double num1, double num2, char op) {
    switch (op) {
        case '+': return num1 + num2;
        case '-': return num1 - num2;
        case '*': return num1 * num2;
        case '/': return num2 == 0 ? (cout << "Error: Division by zero!" << endl, 0.0) : num1 / num2;
        case '%': return num2 == 0 ? (cout << "Error: Modulus by zero!" << endl, 0.0) : fmod(num1, num2);
        case '^': return pow(num1, num2);
        default: return 0.0; // Error handled in caller
    }
}

string Calculator::complexToString(const Complex& c) const {
    if (c.imag == 0) return to_string(c.real);
    return to_string(c.real) + (c.imag >= 0 ? " + " : " - ") + to_string(abs(c.imag)) + "i";
}

Calculator::Complex Calculator::calculateComplex(const Complex& c1, const Complex& c2, char op) {
    switch (op) {
        case '+': return {c1.real + c2.real, c1.imag + c2.imag};
        case '-': return {c1.real - c2.real, c1.imag - c2.imag};
        case '*': return {c1.real * c2.real - c1.imag * c2.imag, c1.real * c2.imag + c1.imag * c2.real};
        case '/': {
            double denom = c2.real * c2.real + c2.imag * c2.imag;
            if (denom == 0) { cout << "Error: Division by zero!" << endl; return {0.0, 0.0}; }
            return {(c1.real * c2.real + c1.imag * c2.imag) / denom, (c1.imag * c2.real - c1.real * c2.imag) / denom};
        }
        default: return {0.0, 0.0}; // Error handled in caller
    }
}

double Calculator::calculateUnary(double num, const string& func) {
    auto it = unaryFunctions.find(func);
    return it != unaryFunctions.end() ? it->second(num) : (cout << "Error: Unknown function!" << endl, 0.0);
}

double Calculator::convertUnits(double value, const string& from, const string& to) {
    string key = from + "_to_" + to;
    auto it = conversions.find(key);
    return it != conversions.end() ? it->second(value) : (cout << "Error: Conversion not supported!" << endl, value);
}

void Calculator::storeMemory(double value) {
    memory += value; // m+
    cout << "Added " << value << " to memory. New value: " << memory << endl;
}

void Calculator::subtractMemory(double value) {
    memory -= value; // m-
    cout << "Subtracted " << value << " from memory. New value: " << memory << endl;
}

void Calculator::clearMemory() {
    memory = 0.0; // mc
    cout << "Memory cleared." << endl;
}

double Calculator::recallMemory() {
    cout << "Memory value: " << memory << endl; // mr
    return memory;
}

void Calculator::toggleMode() {
    isRadianMode = !isRadianMode;
    cout << "Mode switched to " << (isRadianMode ? "radians" : "degrees") << endl;
}

double Calculator::getRandom() {
    uniform_real_distribution<double> dist(0.0, 1.0);
    return dist(rng);
}

void Calculator::reset() {
    memory = 0.0;
    history.clear();
    isRadianMode = false;
    cout << "Calculator reset." << endl;
}

void Calculator::displayMenu() {
    cout << "\n=== Optimized Scientific Calculator Menu ===\n";
    cout << "1. Basic Operation (+, -, *, /, %, ^)\n";
    cout << "2. Square Root (sqrt)\n";
    cout << "3. Cube Root (cbrt)\n";
    cout << "4. Yth Root (yroot)\n";
    cout << "5. Trigonometry (sin, cos, tan, cot, sec, csc)\n";
    cout << "6. Inverse Trigonometry (asin, acos, atan, acot, asec, acsc)\n";
    cout << "7. Hyperbolic (sinh, cosh, tanh, coth, sech, csch)\n";
    cout << "8. Inverse Hyperbolic (asinh, acosh, atanh, acoth, asech, acsch)\n";
    cout << "9. Logarithm (log, ln)\n";
    cout << "10. Exponential (exp, tenpow)\n";
    cout << "11. Factorial (factorial)\n";
    cout << "12. Expression Mode (e.g., 2 + 3 * 4 or (pi * 2))\n";
    cout << "13. Complex Numbers (e.g., 2 + 3i + 4 - 2i)\n";
    cout << "14. Unit Conversion (m ↔ cm, deg ↔ rad, km ↔ m)\n";
    cout << "15. Statistics (mean, std dev)\n";
    cout << "16. Solve Equation (e.g., x^2 - 4 = 0)\n";
    cout << "17. Memory Add (m+)\n";
    cout << "18. Memory Subtract (m-)\n";
    cout << "19. Memory Clear (mc)\n";
    cout << "20. Memory Recall (mr)\n";
    cout << "21. Toggle Mode (Rad/Deg)\n";
    cout << "22. Random Number (rand)\n";
    cout << "23. All Clear (AC)\n";
    cout << "24. Show History\n";
    cout << "25. Exit\n";
}

void Calculator::clearInputBuffer() {
    cin.clear();
    cin.ignore(numeric_limits<streamsize>::max(), '\n');
}

void Calculator::showHistory() {
    if (history.empty()) cout << "History is empty." << endl;
    else {
        cout << "\nCalculation History (Last " << MAX_HISTORY << "):\n";
        for (const auto& entry : history) cout << entry << endl;
    }
}

void Calculator::addToHistory(const string& entry) {
    if (history.size() >= MAX_HISTORY) history.erase(history.begin());
    history.push_back(entry);
}

vector<string> Calculator::toPostfix(const vector<string>& tokens) {
    vector<string> output;
    stack<string> operators;

    for (const auto& token : tokens) {
        if (constants.count(token) || (token[0] >= '0' && token[0] <= '9') || token[0] == '-') {
            output.push_back(token);
        } else if (token == "(") {
            operators.push(token);
        } else if (token == ")") {
            while (!operators.empty() && operators.top() != "(") {
                output.push_back(operators.top());
                operators.pop();
            }
            operators.pop(); // Remove '('
        } else if (token.size() == 1 && operatorPrecedence.count(token[0])) {
            while (!operators.empty() && operators.top() != "(" && operatorPrecedence[operators.top()[0]] >= operatorPrecedence[token[0]]) {
                output.push_back(operators.top());
                operators.pop();
            }
            operators.push(token);
        }
    }

    while (!operators.empty()) {
        output.push_back(operators.top());
        operators.pop();
    }
    return output;
}

double Calculator::evaluatePostfix(const vector<string>& postfix) {
    stack<double> values;

    for (const auto& token : postfix) {
        if (constants.count(token)) {
            values.push(constants[token]);
        } else if (token.size() == 1 && operatorPrecedence.count(token[0])) {
            double b = values.top(); values.pop();
            double a = values.top(); values.pop();
            values.push(calculate(a, b, token[0]));
        } else {
            values.push(stod(token));
        }
    }
    return values.top();
}

double Calculator::parseExpression(const string& expr) {
    auto tokens = tokenize(expr);
    auto postfix = toPostfix(tokens);
    double result = evaluatePostfix(postfix);
    addToHistory(expr + " = " + to_string(result));
    return result;
}

double Calculator::solveEquation(const string& func, double a, double b) {
    auto eval = [&](double x) {
        string expr = func;
        size_t pos = expr.find('x');
        while (pos != string::npos) {
            expr.replace(pos, 1, to_string(x));
            pos = expr.find('x', pos + 1);
        }
        return parseExpression(expr);
    };

    double fa = eval(a), fb = eval(b);
    if (fa * fb >= 0) {
        cout << "Error: Function must change sign over interval!" << endl;
        return 0.0;
    }

    double c, fc, tolerance = 1e-6;
    for (int i = 0; i < 100; i++) {
        c = (a + b) / 2;
        fc = eval(c);
        if (abs(fc) < tolerance) break;
        if (fa * fc < 0) b = c;
        else a = c, fa = fc;
    }
    return c;
}

pair<double, double> Calculator::calculateStats(const vector<double>& data) {
    if (data.empty()) return {0.0, 0.0};
    double mean = accumulate(data.begin(), data.end(), 0.0) / data.size();
    double variance = 0.0;
    for (double x : data) variance += (x - mean) * (x - mean);
    variance /= data.size();
    return {mean, sqrt(variance)};
}

double Calculator::factorial(double n) {
    if (n < 0 || n != floor(n)) {
        cout << "Error: Factorial defined only for non-negative integers!" << endl;
        return 0.0;
    }
    if (n > 170) {
        cout << "Error: Factorial overflow (n > 170)!" << endl;
        return 0.0;
    }
    if (n == 0 || n == 1) return 1;
    double result = 1;
    for (int i = 2; i <= n; i++) result *= i;
    return result;
}

/**
 * Collects numbers from user and computes mean and standard deviation.
 */
 void Calculator::performStatistics()
 {
     cout << "Enter numbers (space-separated, end with 'done'): ";
 
     vector<double> data;
     string input;
     bool done = false;
 
     while (!done)
     {
         cin >> input;
         if (input == "done")
         {
             done = true;
         }
         else
         {
             try
             {
                 double val = stod(input);
                 data.push_back(val);
             }
             catch (const invalid_argument&)
             {
                 cout << "Invalid input. Skipping." << endl;
             }
         }
     }
 
     clearInputBuffer();
 
     auto stats = calculateStats(data);
     cout << "Mean: " << stats.first << ", Std Dev: " << stats.second << endl;
 
     addToHistory("Stats: Mean = " + to_string(stats.first) + ", Std Dev = " + to_string(stats.second));
 }
 
 /**
  * Prompts user for a mathematical expression involving 'x', then solves f(x) = 0 using the bisection method.
  */
 void Calculator::performEquationSolving()
 {
     string func;
     cout << "Enter equation with 'x' (e.g., x^2 - 4): ";
     getline(cin, func);
 
     double a = getNumber("Enter lower bound: ");
     double b = getNumber("Enter upper bound: ");
 
     double root = solveEquation(func, a, b);
     cout << "Root: " << root << endl;
 
     addToHistory("Solve " + func + " = 0, root = " + to_string(root));
 }
 
 /**
  * Evaluates user-entered infix expression like "2 + 3 * pi".
  */
 void Calculator::performExpressionMode()
 {
     cout << "Enter an expression (e.g., 2 + 3 * pi): ";
     string expr;
     getline(cin, expr);
 
     double result = parseExpression(expr);
     cout << "Result: " << result << endl;
 }
 
 /**
  * Handles input and arithmetic for complex numbers in the form "a + bi".
  */
 void Calculator::performComplexCalculation()
 {
     cout << "Enter first complex number (e.g., 2 + 3i): ";
     string input1;
     getline(cin, input1);
 
     Complex c1 = parseComplex(input1);
 
     char op = getOperator("+-*/");
 
     cout << "Enter second complex number (e.g., 4 - 2i): ";
     string input2;
     getline(cin, input2);
 
     Complex c2 = parseComplex(input2);
 
     Complex result = calculateComplex(c1, c2, op);
 
     cout << complexToString(c1) << " " << op << " " << complexToString(c2) << " = " << complexToString(result) << endl;
     addToHistory(complexToString(c1) + " " + op + " " + complexToString(c2) + " = " + complexToString(result));
 }
 
 /**
  * Enhanced tokenizer: splits expression by operators, brackets, and handles constants like "pi".
  */
 vector<string> Calculator::tokenize(const string& expr)
 {
     vector<string> tokens;
     regex pattern(R"((\d+\.\d+|\d+|pi|e|[a-zA-Z_]+|\S))");
     auto words_begin = sregex_iterator(expr.begin(), expr.end(), pattern);
     auto words_end = sregex_iterator();
 
     for (sregex_iterator it = words_begin; it != words_end; ++it)
     {
         tokens.push_back(it->str());
     }
 
     return tokens;
 }
 
 /**
  * Parses a string like "3 + 4i" into a Complex struct.
  */
 Calculator::Complex Calculator::parseComplex(const string& input)
 {
     Complex c = { 0.0, 0.0 };
     string expr = input;
 
     expr.erase(remove(expr.begin(), expr.end(), ' '), expr.end());
     size_t posI = expr.find("i");
 
     if (posI == string::npos)
     {
         c.real = stod(expr);
     }
     else
     {
         size_t plus = expr.find('+');
         size_t minus = expr.find('-', 1);
 
         if (plus != string::npos)
         {
             c.real = stod(expr.substr(0, plus));
             c.imag = stod(expr.substr(plus + 1, posI - plus - 1));
         }
         else if (minus != string::npos)
         {
             c.real = stod(expr.substr(0, minus));
             c.imag = -stod(expr.substr(minus + 1, posI - minus - 1));
         }
         else
         {
             c.imag = (posI == 0) ? 1.0 : stod(expr.substr(0, posI));
         }
     }
 
    return c;
}

string Calculator::formatComplex(const Complex& c) const {
    return complexToString(c);
}