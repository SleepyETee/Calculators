#ifndef CALCULATOR_H
#define CALCULATOR_H

#include <string>
#include <vector>
#include <unordered_map>
#include <functional>
#include <stack>
#include <complex>
#include <random>

class Calculator {
public:
    struct Complex { double real, imag; }; // Simple complex number struct
    bool isRadianMode; // Toggle between radian and degree mode (public for GUI access)

private:
    double memory; // Memory storage
    std::vector<std::string> history; // Calculation history
    static const int MAX_HISTORY = 10; // Limit history size
    std::unordered_map<std::string, std::function<double(double)>> unaryFunctions; // O(1) lookup
    std::unordered_map<std::string, double> constants; // O(1) lookup
    std::unordered_map<std::string, std::function<double(double)>> conversions; // O(1) lookup
    std::unordered_map<char, int> operatorPrecedence; // O(1) precedence check
    std::mt19937 rng; // Random number generator
    void initializeFunctions(); // Set up unary functions
    void initializeConstants(); // Set up constants
    void initializeConversions(); // Set up unit conversions
    void initializePrecedence(); // Set up operator precedence
    double toRadians(double angle) const; // Inline conversion
    double toDegrees(double angle) const; // Inline conversion
    std::string complexToString(const Complex& c) const; // Format complex output
    std::vector<std::string> tokenize(const std::string& expr); // Tokenize expression
    std::vector<std::string> toPostfix(const std::vector<std::string>& tokens); // Shunting Yard algorithm
    double evaluatePostfix(const std::vector<std::string>& postfix); // Evaluate postfix expression
    double factorial(double n); // Compute factorial

public:
    Calculator(); // Constructor
    double getNumber(const std::string& prompt); // Get valid number
    char getOperator(const std::string& validOps = "+-*/%^"); // Get valid operator
    std::string getFunction(const std::string& prompt, const std::string& category); // Get unary function
    double calculate(double num1, double num2, char op); // Binary operations
    Complex calculateComplex(const Complex& c1, const Complex& c2, char op); // Complex operations
    double calculateUnary(double num, const std::string& func); // Unary operations
    double convertUnits(double value, const std::string& from, const std::string& to); // Unit conversion
    void storeMemory(double value); // Store in memory (m+)
    void subtractMemory(double value); // Subtract from memory (m-)
    void clearMemory(); // Clear memory (mc)
    double recallMemory(); // Recall memory value (mr)
    void toggleMode(); // Toggle between radian and degree mode
    double getRandom(); // Generate random number
    void reset(); // All clear (AC)
    void displayMenu(); // Show menu
    void clearInputBuffer(); // Clear input buffer
    void showHistory(); // Display calculation history
    void addToHistory(const std::string& entry); // Add entry to history
    double parseExpression(const std::string& expr); // Parse and evaluate expression
    double solveEquation(const std::string& func, double a, double b); // Numerical solver
    std::pair<double, double> calculateStats(const std::vector<double>& data); // Mean and std dev

    void run();
    void performStatistics();
    void performEquationSolving();
    void performExpressionMode();
    void performComplexCalculation();
    Complex parseComplex(const std::string& input); // Parse complex number (public for main access)
    std::string formatComplex(const Complex& c) const; // Format complex output (public wrapper)
};

#endif // CALCULATOR_H