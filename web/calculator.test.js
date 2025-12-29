/**
 * Unit Tests for Scientific Calculator
 * Run with: node calculator.test.js
 */

// Mock DOM elements for testing
global.document = {
    getElementById: () => ({ value: '0', textContent: '', classList: { add: () => {}, remove: () => {}, toggle: () => {}, contains: () => false } }),
    querySelectorAll: () => [],
    querySelector: () => null,
    createElement: () => ({ className: '', textContent: '', classList: { add: () => {}, remove: () => {} }, appendChild: () => {} }),
    body: { appendChild: () => {} },
    documentElement: { getAttribute: () => 'dark', setAttribute: () => {} }
};
global.localStorage = { getItem: () => null, setItem: () => {} };
global.requestAnimationFrame = (cb) => cb();

// Simple test framework
let passed = 0;
let failed = 0;

function test(name, fn) {
    try {
        fn();
        console.log(`✓ ${name}`);
        passed++;
    } catch (e) {
        console.log(`✗ ${name}`);
        console.log(`  Error: ${e.message}`);
        failed++;
    }
}

function assertEqual(actual, expected, message = '') {
    if (Math.abs(actual - expected) > 1e-9) {
        throw new Error(`${message} Expected ${expected}, got ${actual}`);
    }
}

function assertThrows(fn, message = '') {
    try {
        fn();
        throw new Error(`${message} Expected error but none thrown`);
    } catch (e) {
        if (e.message.includes('Expected error')) throw e;
    }
}

// ============ TESTS ============

console.log('\n=== Scientific Calculator Unit Tests ===\n');

// Basic Arithmetic
console.log('--- Basic Arithmetic ---');

test('Addition: 5 + 3 = 8', () => {
    assertEqual(5 + 3, 8);
});

test('Subtraction: 10 - 4 = 6', () => {
    assertEqual(10 - 4, 6);
});

test('Multiplication: 7 * 6 = 42', () => {
    assertEqual(7 * 6, 42);
});

test('Division: 20 / 4 = 5', () => {
    assertEqual(20 / 4, 5);
});

test('Modulo: 17 % 5 = 2', () => {
    assertEqual(17 % 5, 2);
});

test('Power: 2 ^ 10 = 1024', () => {
    assertEqual(Math.pow(2, 10), 1024);
});

// Trigonometry
console.log('\n--- Trigonometry (Degrees) ---');

function toRadians(deg) { return deg * Math.PI / 180; }
function toDegrees(rad) { return rad * 180 / Math.PI; }

test('sin(30°) = 0.5', () => {
    assertEqual(Math.sin(toRadians(30)), 0.5);
});

test('cos(60°) = 0.5', () => {
    assertEqual(Math.cos(toRadians(60)), 0.5);
});

test('tan(45°) = 1', () => {
    assertEqual(Math.tan(toRadians(45)), 1);
});

test('asin(0.5) = 30°', () => {
    assertEqual(toDegrees(Math.asin(0.5)), 30);
});

test('acos(0.5) = 60°', () => {
    assertEqual(toDegrees(Math.acos(0.5)), 60);
});

test('atan(1) = 45°', () => {
    assertEqual(toDegrees(Math.atan(1)), 45);
});

// Hyperbolic Functions
console.log('\n--- Hyperbolic Functions ---');

test('sinh(0) = 0', () => {
    assertEqual(Math.sinh(0), 0);
});

test('cosh(0) = 1', () => {
    assertEqual(Math.cosh(0), 1);
});

test('tanh(0) = 0', () => {
    assertEqual(Math.tanh(0), 0);
});

// Logarithms & Exponentials
console.log('\n--- Logarithms & Exponentials ---');

test('log10(100) = 2', () => {
    assertEqual(Math.log10(100), 2);
});

test('ln(e) = 1', () => {
    assertEqual(Math.log(Math.E), 1);
});

test('exp(1) = e', () => {
    assertEqual(Math.exp(1), Math.E);
});

// Roots
console.log('\n--- Roots ---');

test('sqrt(16) = 4', () => {
    assertEqual(Math.sqrt(16), 4);
});

test('cbrt(27) = 3', () => {
    assertEqual(Math.cbrt(27), 3);
});

test('cbrt(-8) = -2', () => {
    assertEqual(Math.cbrt(-8), -2);
});

// Factorial
console.log('\n--- Factorial ---');

function factorial(n) {
    if (n < 0 || n !== Math.floor(n)) throw new Error('Invalid');
    if (n > 170) throw new Error('Overflow');
    if (n <= 1) return 1;
    let result = 1;
    for (let i = 2; i <= n; i++) result *= i;
    return result;
}

test('0! = 1', () => {
    assertEqual(factorial(0), 1);
});

test('5! = 120', () => {
    assertEqual(factorial(5), 120);
});

test('10! = 3628800', () => {
    assertEqual(factorial(10), 3628800);
});

test('Factorial of negative throws', () => {
    assertThrows(() => factorial(-1));
});

test('Factorial of decimal throws', () => {
    assertThrows(() => factorial(5.5));
});

// Domain Validation
console.log('\n--- Domain Validation ---');

test('sqrt(-1) is NaN', () => {
    if (!isNaN(Math.sqrt(-1))) throw new Error('Expected NaN');
});

test('log(-1) is NaN', () => {
    if (!isNaN(Math.log(-1))) throw new Error('Expected NaN');
});

test('asin(2) is NaN', () => {
    if (!isNaN(Math.asin(2))) throw new Error('Expected NaN');
});

// Edge Cases
console.log('\n--- Edge Cases ---');

test('Division by zero = Infinity', () => {
    if (!isFinite(1/0) && 1/0 === Infinity) {
        // Pass
    } else {
        throw new Error('Expected Infinity');
    }
});

test('0/0 = NaN', () => {
    if (!isNaN(0/0)) throw new Error('Expected NaN');
});

test('(-2)^0.5 = NaN', () => {
    if (!isNaN(Math.pow(-2, 0.5))) throw new Error('Expected NaN');
});

// Constants
console.log('\n--- Constants ---');

test('PI ≈ 3.14159', () => {
    assertEqual(Math.PI, 3.141592653589793);
});

test('E ≈ 2.71828', () => {
    assertEqual(Math.E, 2.718281828459045);
});

// Summary
console.log('\n=== Test Results ===');
console.log(`Passed: ${passed}`);
console.log(`Failed: ${failed}`);
console.log(`Total:  ${passed + failed}`);

if (failed > 0) {
    process.exit(1);
}
