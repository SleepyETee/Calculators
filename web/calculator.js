/**
 * Scientific Calculator Engine
 * Supports: Basic operations, trigonometry, logarithms, factorials, memory, history
 */

class ScientificCalculator {
    constructor() {
        this.currentValue = '0';
        this.expression = '';
        this.memory = 0;
        this.history = [];
        this.isRadianMode = false;
        this.waitingForOperand = false;
        this.pendingOperation = null;
        this.previousValue = null;
        
        this.constants = {
            pi: Math.PI,
            e: Math.E,
            c: 299792458,
            g: 9.80665,
            h: 6.62607015e-34
        };

        this.maxHistoryItems = 50;
    }

    // Convert between degrees and radians
    toRadians(degrees) {
        return degrees * Math.PI / 180;
    }

    toDegrees(radians) {
        return radians * 180 / Math.PI;
    }

    // Get angle in correct mode for trig functions
    getAngleForTrig(value) {
        return this.isRadianMode ? value : this.toRadians(value);
    }

    // Convert result from radians for inverse trig
    getAngleFromTrig(radians) {
        return this.isRadianMode ? radians : this.toDegrees(radians);
    }

    // Factorial function
    factorial(n) {
        if (n < 0 || n !== Math.floor(n)) {
            throw new Error('Factorial requires non-negative integer');
        }
        if (n > 170) {
            throw new Error('Factorial overflow (n > 170)');
        }
        if (n === 0 || n === 1) return 1;
        let result = 1;
        for (let i = 2; i <= n; i++) {
            result *= i;
        }
        return result;
    }

    // Scientific functions with domain validation
    scientificFunctions = {
        sin: (x) => {
            const angle = this.getAngleForTrig(x);
            return Math.sin(angle);
        },
        cos: (x) => {
            const angle = this.getAngleForTrig(x);
            return Math.cos(angle);
        },
        tan: (x) => {
            const angle = this.getAngleForTrig(x);
            if (Math.abs(Math.cos(angle)) < 1e-9) {
                throw new Error('Undefined tan (angle near 90°)');
            }
            return Math.tan(angle);
        },
        asin: (x) => {
            if (x < -1 || x > 1) {
                throw new Error('asin domain is [-1, 1]');
            }
            return this.getAngleFromTrig(Math.asin(x));
        },
        acos: (x) => {
            if (x < -1 || x > 1) {
                throw new Error('acos domain is [-1, 1]');
            }
            return this.getAngleFromTrig(Math.acos(x));
        },
        atan: (x) => {
            return this.getAngleFromTrig(Math.atan(x));
        },
        sinh: (x) => Math.sinh(x),
        cosh: (x) => Math.cosh(x),
        tanh: (x) => Math.tanh(x),
        asinh: (x) => Math.asinh(x),
        acosh: (x) => {
            if (x < 1) {
                throw new Error('acosh domain is [1, ∞)');
            }
            return Math.acosh(x);
        },
        atanh: (x) => {
            if (x <= -1 || x >= 1) {
                throw new Error('atanh domain is (-1, 1)');
            }
            return Math.atanh(x);
        },
        sqrt: (x) => {
            if (x < 0) {
                throw new Error('Cannot take square root of negative number');
            }
            return Math.sqrt(x);
        },
        cbrt: (x) => Math.cbrt(x),
        log: (x) => {
            if (x <= 0) {
                throw new Error('log domain is (0, ∞)');
            }
            return Math.log10(x);
        },
        ln: (x) => {
            if (x <= 0) {
                throw new Error('ln domain is (0, ∞)');
            }
            return Math.log(x);
        },
        exp: (x) => Math.exp(x),
        abs: (x) => Math.abs(x),
        factorial: (x) => this.factorial(x)
    };

    // Apply a scientific function
    applyFunction(funcName, value) {
        const func = this.scientificFunctions[funcName];
        if (!func) {
            throw new Error(`Unknown function: ${funcName}`);
        }
        return func(value);
    }

    // Basic arithmetic
    calculate(a, b, operator) {
        const num1 = parseFloat(a);
        const num2 = parseFloat(b);

        switch (operator) {
            case '+': return num1 + num2;
            case '-': return num1 - num2;
            case '*': return num1 * num2;
            case '/':
                if (num2 === 0) throw new Error('Division by zero');
                return num1 / num2;
            case '%':
            case 'mod':
                if (num2 === 0) throw new Error('Modulo by zero');
                return num1 % num2;
            case '^': {
                const result = Math.pow(num1, num2);
                if (isNaN(result)) {
                    throw new Error('Invalid power (negative base with fractional exponent)');
                }
                return result;
            }
            default:
                throw new Error(`Unknown operator: ${operator}`);
        }
    }

    // Format number for display
    formatNumber(num) {
        if (typeof num !== 'number' || isNaN(num)) {
            return 'Error';
        }
        if (!isFinite(num)) {
            return num > 0 ? '∞' : '-∞';
        }
        
        // Handle -0
        if (Object.is(num, -0)) {
            return '0';
        }
        
        // Handle very small numbers
        if (Math.abs(num) < 1e-10 && num !== 0) {
            return num.toExponential(6);
        }
        
        // Handle very large numbers
        if (Math.abs(num) >= 1e12) {
            return num.toExponential(6);
        }

        // Regular formatting
        const str = num.toPrecision(12);
        const parsed = parseFloat(str);
        
        // Remove trailing zeros after decimal
        if (Number.isInteger(parsed)) {
            return parsed.toString();
        }
        
        return parsed.toString();
    }

    // Add to history
    addToHistory(expression, result) {
        this.history.unshift({
            expression: expression,
            result: result,
            timestamp: new Date()
        });

        if (this.history.length > this.maxHistoryItems) {
            this.history.pop();
        }
    }

    // Clear history
    clearHistory() {
        this.history = [];
    }

    // Memory operations
    memoryClear() {
        this.memory = 0;
    }

    memoryRecall() {
        return this.memory;
    }

    memoryAdd(value) {
        this.memory += parseFloat(value) || 0;
    }

    memorySubtract(value) {
        this.memory -= parseFloat(value) || 0;
    }

    memoryStore(value) {
        this.memory = parseFloat(value) || 0;
    }

    hasMemory() {
        return this.memory !== 0;
    }

    // Toggle angle mode
    toggleAngleMode() {
        this.isRadianMode = !this.isRadianMode;
        return this.isRadianMode;
    }

    // Reset calculator
    reset() {
        this.currentValue = '0';
        this.expression = '';
        this.waitingForOperand = false;
        this.pendingOperation = null;
        this.previousValue = null;
    }
}


// UI Controller
class CalculatorUI {
    constructor() {
        this.calc = new ScientificCalculator();
        this.display = document.getElementById('display');
        this.expressionDisplay = document.getElementById('expression');
        this.historyList = document.getElementById('history-list');
        this.historyPanel = document.getElementById('history-panel');
        this.angleMode = document.getElementById('angle-mode');
        this.memoryIndicator = document.getElementById('memory-indicator');
        
        this.currentInput = '0';
        this.fullExpression = '';
        this.lastResult = null;
        this.awaitingSecondOperand = false;
        this.currentOperator = null;
        this.firstOperand = null;

        this.init();
    }

    init() {
        this.bindEvents();
        this.loadTheme();
        this.loadHistory();
        this.updateDisplay();
    }

    bindEvents() {
        // Button clicks
        document.querySelectorAll('.btn').forEach(btn => {
            btn.addEventListener('click', (e) => this.handleButtonClick(e));
        });

        // Theme toggle
        document.getElementById('theme-toggle').addEventListener('click', () => {
            this.toggleTheme();
        });

        // History toggle
        document.getElementById('history-toggle').addEventListener('click', () => {
            this.toggleHistory();
        });

        // Clear history
        document.getElementById('clear-history').addEventListener('click', () => {
            this.clearHistory();
        });

        // Copy button
        document.getElementById('copy-btn').addEventListener('click', () => {
            this.copyResult();
        });

        // Help modal
        const helpModal = document.getElementById('help-modal');
        document.getElementById('help-toggle').addEventListener('click', () => {
            helpModal.classList.add('active');
        });
        document.getElementById('help-close').addEventListener('click', () => {
            helpModal.classList.remove('active');
        });
        helpModal.addEventListener('click', (e) => {
            if (e.target === helpModal) {
                helpModal.classList.remove('active');
            }
        });

        // Keyboard support
        document.addEventListener('keydown', (e) => {
            // Close modal on Escape
            if (e.key === 'Escape' && helpModal.classList.contains('active')) {
                helpModal.classList.remove('active');
                return;
            }
            // Show help on ?
            if (e.key === '?' && !helpModal.classList.contains('active')) {
                helpModal.classList.add('active');
                return;
            }
            this.handleKeyboard(e);
        });
    }

    copyResult() {
        const text = this.currentInput;
        navigator.clipboard.writeText(text).then(() => {
            this.showToast('Copied to clipboard!');
            const btn = document.getElementById('copy-btn');
            btn.classList.add('copied');
            setTimeout(() => btn.classList.remove('copied'), 1000);
        }).catch(() => {
            this.showToast('Failed to copy');
        });
    }

    showToast(message) {
        // Remove existing toast
        const existing = document.querySelector('.toast');
        if (existing) existing.remove();

        const toast = document.createElement('div');
        toast.className = 'toast';
        toast.textContent = message;
        document.body.appendChild(toast);

        // Trigger animation
        requestAnimationFrame(() => {
            toast.classList.add('show');
        });

        // Remove after delay
        setTimeout(() => {
            toast.classList.remove('show');
            setTimeout(() => toast.remove(), 300);
        }, 2000);
    }

    handleButtonClick(e) {
        const btn = e.target.closest('.btn');
        if (!btn) return;

        const action = btn.dataset.action;

        try {
            switch (action) {
                case 'num':
                    this.inputNumber(btn.dataset.num);
                    break;
                case 'decimal':
                    this.inputDecimal();
                    break;
                case 'op':
                    this.inputOperator(btn.dataset.op);
                    break;
                case 'func':
                    this.applyFunction(btn.dataset.func);
                    break;
                case 'const':
                    this.inputConstant(btn.dataset.const);
                    break;
                case 'equals':
                    this.calculate();
                    break;
                case 'clear':
                    this.clear();
                    break;
                case 'clear-entry':
                    this.clearEntry();
                    break;
                case 'backspace':
                    this.backspace();
                    break;
                case 'negate':
                    this.negate();
                    break;
                case 'toggle-mode':
                    this.toggleAngleMode();
                    break;
                case 'paren':
                    this.inputParen(btn.dataset.paren);
                    break;
                case 'power':
                    this.inputOperator('^');
                    break;
                case 'mc':
                    this.memoryClear();
                    break;
                case 'mr':
                    this.memoryRecall();
                    break;
                case 'm+':
                    this.memoryAdd();
                    break;
                case 'm-':
                    this.memorySubtract();
                    break;
                case 'ms':
                    this.memoryStore();
                    break;
                case 'percent':
                    this.calculatePercent();
                    break;
            }
        } catch (error) {
            this.showError(error.message);
        }

        this.updateDisplay();
    }

    calculatePercent() {
        const value = parseFloat(this.currentInput);
        if (this.firstOperand !== null && this.currentOperator) {
            // Calculate percentage of first operand (e.g., 200 + 10% = 220)
            const percent = (this.firstOperand * value) / 100;
            this.currentInput = this.calc.formatNumber(percent);
        } else {
            // Just convert to percentage
            this.currentInput = this.calc.formatNumber(value / 100);
        }
    }

    handleKeyboard(e) {
        const key = e.key;
        
        // Prevent default for calculator keys
        if (/^[0-9.+\-*/%^()=]$/.test(key) || ['Enter', 'Backspace', 'Escape', 'Delete'].includes(key)) {
            e.preventDefault();
        }

        try {
            if (/^[0-9]$/.test(key)) {
                this.inputNumber(key);
            } else if (key === '.') {
                this.inputDecimal();
            } else if (['+', '-', '*', '/', '%', '^'].includes(key)) {
                this.inputOperator(key);
            } else if (key === 'Enter' || key === '=') {
                this.calculate();
            } else if (key === 'Backspace') {
                this.backspace();
            } else if (key === 'Escape') {
                this.clear();
            } else if (key === 'Delete') {
                this.clearEntry();
            } else if (key === '(' || key === ')') {
                this.inputParen(key);
            }
        } catch (error) {
            this.showError(error.message);
        }

        this.updateDisplay();
    }

    inputNumber(num) {
        if (this.awaitingSecondOperand) {
            this.currentInput = num;
            this.awaitingSecondOperand = false;
            // Clear expression if starting fresh after equals
            if (this.fullExpression.includes('=')) {
                this.fullExpression = '';
                this.firstOperand = null;
            }
        } else {
            this.currentInput = this.currentInput === '0' ? num : this.currentInput + num;
        }
    }

    inputDecimal() {
        if (this.awaitingSecondOperand) {
            this.currentInput = '0.';
            this.awaitingSecondOperand = false;
            return;
        }
        if (!this.currentInput.includes('.')) {
            this.currentInput += '.';
        }
    }

    inputOperator(op) {
        const inputValue = parseFloat(this.currentInput);

        if (this.firstOperand === null) {
            this.firstOperand = inputValue;
        } else if (this.currentOperator && !this.awaitingSecondOperand) {
            const result = this.calc.calculate(this.firstOperand, inputValue, this.currentOperator);
            this.currentInput = this.calc.formatNumber(result);
            this.firstOperand = result;
        }

        this.awaitingSecondOperand = true;
        this.currentOperator = op;
        
        const opSymbol = this.getOperatorSymbol(op);
        this.fullExpression = `${this.calc.formatNumber(this.firstOperand)} ${opSymbol}`;
    }

    getOperatorSymbol(op) {
        const symbols = {
            '+': '+',
            '-': '−',
            '*': '×',
            '/': '÷',
            '%': '%',
            'mod': 'mod',
            '^': '^'
        };
        return symbols[op] || op;
    }

    inputConstant(name) {
        const value = this.calc.constants[name];
        if (value !== undefined) {
            this.currentInput = this.calc.formatNumber(value);
            if (this.awaitingSecondOperand) {
                this.awaitingSecondOperand = false;
            }
        }
    }

    inputParen(paren) {
        // For simple implementation, just add to expression
        this.fullExpression += ` ${paren}`;
    }

    applyFunction(funcName) {
        const value = parseFloat(this.currentInput);
        const result = this.calc.applyFunction(funcName, value);
        
        const funcDisplay = this.getFunctionDisplay(funcName);
        const expr = `${funcDisplay}(${this.currentInput})`;
        
        this.currentInput = this.calc.formatNumber(result);
        this.fullExpression = expr;
        this.lastResult = result;
        
        // After function, next number input should replace (not append)
        this.awaitingSecondOperand = true;
        
        // Add to history
        this.calc.addToHistory(expr, this.calc.formatNumber(result));
        this.updateHistory();
    }

    getFunctionDisplay(funcName) {
        const displays = {
            sin: 'sin',
            cos: 'cos',
            tan: 'tan',
            asin: 'sin⁻¹',
            acos: 'cos⁻¹',
            atan: 'tan⁻¹',
            sinh: 'sinh',
            cosh: 'cosh',
            tanh: 'tanh',
            asinh: 'sinh⁻¹',
            acosh: 'cosh⁻¹',
            atanh: 'tanh⁻¹',
            sqrt: '√',
            cbrt: '∛',
            log: 'log',
            ln: 'ln',
            exp: 'e^',
            abs: '|x|',
            factorial: '!'
        };
        return displays[funcName] || funcName;
    }

    calculate() {
        if (this.currentOperator === null || this.awaitingSecondOperand) {
            return;
        }

        const secondOperand = parseFloat(this.currentInput);
        const result = this.calc.calculate(this.firstOperand, secondOperand, this.currentOperator);
        
        const expr = `${this.calc.formatNumber(this.firstOperand)} ${this.getOperatorSymbol(this.currentOperator)} ${this.calc.formatNumber(secondOperand)}`;
        const formattedResult = this.calc.formatNumber(result);
        
        // Add to history
        this.calc.addToHistory(expr, formattedResult);
        this.updateHistory();
        
        this.currentInput = formattedResult;
        this.fullExpression = `${expr} =`;
        this.firstOperand = result;
        this.currentOperator = null;
        // After calculation, next number should replace result
        this.awaitingSecondOperand = true;
        this.lastResult = result;
    }

    clear() {
        this.currentInput = '0';
        this.fullExpression = '';
        this.firstOperand = null;
        this.currentOperator = null;
        this.awaitingSecondOperand = false;
        this.calc.reset();
    }

    clearEntry() {
        this.currentInput = '0';
    }

    backspace() {
        // Don't allow backspace on error messages or scientific notation
        if (this.currentInput.includes('Error') || this.currentInput.includes('e')) {
            this.currentInput = '0';
            return;
        }
        if (this.currentInput.length > 1) {
            this.currentInput = this.currentInput.slice(0, -1);
            // Handle case where we're left with just a minus sign
            if (this.currentInput === '-') {
                this.currentInput = '0';
            }
        } else {
            this.currentInput = '0';
        }
    }

    negate() {
        const value = parseFloat(this.currentInput);
        this.currentInput = this.calc.formatNumber(-value);
    }

    toggleAngleMode() {
        const isRadian = this.calc.toggleAngleMode();
        // Update mode indicator badge
        this.angleMode.textContent = isRadian ? 'RAD' : 'DEG';
        
        // Update the button to show CURRENT mode (not what to switch to)
        const btn = document.getElementById('mode-btn');
        if (btn) {
            btn.textContent = isRadian ? 'RAD' : 'DEG';
        }
    }

    // Memory operations
    memoryClear() {
        this.calc.memoryClear();
        this.updateMemoryIndicator();
    }

    memoryRecall() {
        const value = this.calc.memoryRecall();
        this.currentInput = this.calc.formatNumber(value);
    }

    memoryAdd() {
        this.calc.memoryAdd(parseFloat(this.currentInput));
        this.updateMemoryIndicator();
    }

    memorySubtract() {
        this.calc.memorySubtract(parseFloat(this.currentInput));
        this.updateMemoryIndicator();
    }

    memoryStore() {
        this.calc.memoryStore(parseFloat(this.currentInput));
        this.updateMemoryIndicator();
    }

    updateMemoryIndicator() {
        if (this.calc.hasMemory()) {
            this.memoryIndicator.classList.remove('hidden');
        } else {
            this.memoryIndicator.classList.add('hidden');
        }
    }

    // Display updates
    updateDisplay() {
        this.display.value = this.currentInput;
        this.expressionDisplay.textContent = this.fullExpression;
    }

    showError(message) {
        this.currentInput = message || 'Error';
        this.display.classList.add('error');
        setTimeout(() => {
            this.display.classList.remove('error');
        }, 500);
    }

    // History management
    updateHistory() {
        if (this.calc.history.length === 0) {
            this.historyList.innerHTML = '<p class="history-empty">No calculations yet</p>';
            return;
        }

        this.historyList.innerHTML = this.calc.history.map((item, index) => `
            <div class="history-item" data-index="${index}">
                <div class="history-expression">${this.escapeHtml(item.expression)}</div>
                <div class="history-result">${this.escapeHtml(item.result)}</div>
            </div>
        `).join('');

        // Add click handlers to history items
        this.historyList.querySelectorAll('.history-item').forEach(item => {
            item.addEventListener('click', () => {
                const index = parseInt(item.dataset.index);
                const historyItem = this.calc.history[index];
                if (historyItem) {
                    this.currentInput = historyItem.result;
                    this.updateDisplay();
                }
            });
        });

        this.saveHistory();
    }

    clearHistory() {
        this.calc.clearHistory();
        this.updateHistory();
    }

    toggleHistory() {
        this.historyPanel.classList.toggle('hidden');
    }

    escapeHtml(str) {
        const div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    // Theme management
    toggleTheme() {
        const currentTheme = document.documentElement.getAttribute('data-theme');
        const newTheme = currentTheme === 'light' ? 'dark' : 'light';
        document.documentElement.setAttribute('data-theme', newTheme);
        localStorage.setItem('calculator-theme', newTheme);
    }

    loadTheme() {
        const savedTheme = localStorage.getItem('calculator-theme') || 'dark';
        document.documentElement.setAttribute('data-theme', savedTheme);
    }

    // Persistence
    saveHistory() {
        try {
            localStorage.setItem('calculator-history', JSON.stringify(this.calc.history));
        } catch (e) {
            console.warn('Could not save history:', e);
        }
    }

    loadHistory() {
        try {
            const saved = localStorage.getItem('calculator-history');
            if (saved) {
                this.calc.history = JSON.parse(saved);
                this.updateHistory();
            }
        } catch (e) {
            console.warn('Could not load history:', e);
        }
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    new CalculatorUI();
});
