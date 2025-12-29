import math
import re
import random
from statistics import mean, pstdev

class Calculator:
    def __init__(self):
        self.memory = 0.0
        self.history = []
        self.constants = {
            'pi': math.pi,
            'e': math.e,
            'c': 299792458.0,
            'g': 9.80665,
            'h': 6.62607015e-34
        }
        self.unary_functions = {
            'sqrt': lambda x: math.sqrt(x) if x >= 0 else self._error("Negative sqrt"),
            'cbrt': lambda x: math.copysign(abs(x) ** (1.0 / 3), x),  # Handles negative numbers correctly
            'exp': math.exp,
            'tenpow': lambda x: 10 ** x,
            'ln': lambda x: math.log(x) if x > 0 else self._error("Ln domain error"),
            'log': lambda x: math.log10(x) if x > 0 else self._error("Log domain error"),
            'factorial': lambda x: self._factorial(x)
        }
        self.radian_mode = False

    def _error(self, message):
        print("Error:", message)
        return 0.0

    def _factorial(self, n):
        if n < 0 or n != int(n):
            return self._error("Factorial only for non-negative integers")
        if n > 170:
            return self._error("Factorial overflow (n > 170)")
        return math.factorial(int(n))

    def calculate(self, num1, num2, op):
        try:
            return {
                '+': num1 + num2,
                '-': num1 - num2,
                '*': num1 * num2,
                '/': num1 / num2 if num2 != 0 else self._error("Divide by zero"),
                '%': num1 % num2 if num2 != 0 else self._error("Modulo by zero"),
                '^': num1 ** num2
            }.get(op, self._error("Invalid operator"))
        except Exception as e:
            return self._error(str(e))

    def calculate_unary(self, x, func):
        # Only convert to radians for regular trig functions (NOT inverse trig - those take ratios)
        if func in ['sin', 'cos', 'tan', 'cot', 'sec', 'csc']:
            angle = math.radians(x) if not self.radian_mode else x
        else:
            angle = x  # For inverse trig, x is a ratio, not an angle
        
        # Domain validation for inverse trig
        if func in ['asin', 'acos'] and (x < -1 or x > 1):
            return self._error(f"{func} domain is [-1, 1]")
        if func in ['asec', 'acsc'] and -1 < x < 1:
            return self._error(f"{func} domain is |x| >= 1")
        
        trig_funcs = {
            'sin': lambda _: math.sin(angle),
            'cos': lambda _: math.cos(angle),
            'tan': lambda _: math.tan(angle) if abs(math.cos(angle)) > 1e-9 else self._error("Undefined tan (angle near 90°)"),
            'cot': lambda _: 1 / math.tan(angle) if abs(math.sin(angle)) > 1e-9 else self._error("Undefined cot (angle near 0°)"),
            'sec': lambda _: 1 / math.cos(angle) if abs(math.cos(angle)) > 1e-9 else self._error("Undefined sec (angle near 90°)"),
            'csc': lambda _: 1 / math.sin(angle) if abs(math.sin(angle)) > 1e-9 else self._error("Undefined csc (angle near 0°)"),
            'asin': lambda v: math.degrees(math.asin(v)) if not self.radian_mode else math.asin(v),
            'acos': lambda v: math.degrees(math.acos(v)) if not self.radian_mode else math.acos(v),
            'atan': lambda v: math.degrees(math.atan(v)) if not self.radian_mode else math.atan(v),
            'acot': lambda v: math.degrees(math.pi / 2 - math.atan(v)) if not self.radian_mode else math.pi / 2 - math.atan(v),
            'asec': lambda v: math.degrees(math.acos(1 / v)) if not self.radian_mode else math.acos(1 / v),
            'acsc': lambda v: math.degrees(math.asin(1 / v)) if not self.radian_mode else math.asin(1 / v)
        }
        return self.unary_functions.get(func, trig_funcs.get(func, lambda _: self._error("Unknown function")))(x)

    def solve_equation(self, expr, a, b):
        def f(x):
            try:
                return eval(expr.replace('x', str(x)), {"__builtins__": {}}, self.constants)
            except:
                return self._error("Invalid expression")

        fa, fb = f(a), f(b)
        if fa * fb >= 0:
            return self._error("Function must change sign")

        for _ in range(100):
            c = (a + b) / 2
            fc = f(c)
            if abs(fc) < 1e-6:
                return c
            if fa * fc < 0:
                b = c
                fb = fc
            else:
                a = c
                fa = fc
        return c

    def evaluate_expression(self, expr):
        for key, value in self.constants.items():
            expr = expr.replace(key, str(value))
        try:
            result = eval(expr, {"__builtins__": {}}, math.__dict__)
            self.add_to_history(f"{expr} = {result}")
            return result
        except Exception as e:
            return self._error(str(e))

    def parse_complex(self, input_str):
        input_str = input_str.replace(' ', '')
        match = re.match(r'([-\d.]+)?([+-])?(\d+)?i', input_str)
        real, imag = 0.0, 0.0
        if match:
            real = float(match.group(1)) if match.group(1) else 0.0
            imag = float(match.group(3)) if match.group(3) else 1.0
            if match.group(2) == '-':
                imag *= -1
        else:
            if 'i' in input_str:
                imag = float(input_str.replace('i', ''))
            else:
                real = float(input_str)
        return complex(real, imag)

    def calculate_complex(self, c1, c2, op):
        try:
            return {
                '+': c1 + c2,
                '-': c1 - c2,
                '*': c1 * c2,
                '/': c1 / c2 if c2 != 0 else self._error("Divide by zero")
            }.get(op, self._error("Invalid complex op"))
        except Exception as e:
            return self._error(str(e))

    def convert_units(self, value, from_unit, to_unit):
        conversions = {
            ('m', 'cm'): lambda x: x * 100,
            ('cm', 'm'): lambda x: x / 100,
            ('deg', 'rad'): lambda x: math.radians(x),
            ('rad', 'deg'): lambda x: math.degrees(x),
            ('km', 'm'): lambda x: x * 1000,
            ('m', 'km'): lambda x: x / 1000,
        }
        return conversions.get((from_unit, to_unit), lambda x: self._error("Invalid conversion"))(value)

    def statistics(self, data):
        if not data:
            return (0.0, 0.0)
        return (mean(data), pstdev(data))

    def store_memory(self, value):
        self.memory += value
        print(f"Memory += {value}, new memory: {self.memory}")

    def subtract_memory(self, value):
        self.memory -= value
        print(f"Memory -= {value}, new memory: {self.memory}")

    def recall_memory(self):
        print("Memory recall:", self.memory)
        return self.memory

    def clear_memory(self):
        self.memory = 0.0
        print("Memory cleared.")

    def add_to_history(self, entry):
        if len(self.history) >= 10:
            self.history.pop(0)
        self.history.append(entry)

    def show_history(self):
        if not self.history:
            print("History is empty.")
        else:
            print("\nHistory:")
            for h in self.history:
                print(h)

    def random_number(self):
        return random.uniform(0, 1)

    def toggle_mode(self):
        self.radian_mode = not self.radian_mode
        print("Mode switched to", "radians" if self.radian_mode else "degrees")

    def reset(self):
        self.memory = 0.0
        self.history.clear()
        self.radian_mode = False
        print("Calculator reset.")


# CLI Runner
if __name__ == "__main__":
    calc = Calculator()
    result = 0.0

    def handle_basic_op():
        a = float(input("Enter first number: "))
        op = input("Enter operator (+ - * / % ^): ")
        b = float(input("Enter second number: "))
        return calc.calculate(a, b, op), f"{a} {op} {b}"

    def handle_unary():
        func = input("Enter unary function: ")
        x = float(input("Enter value: "))
        return calc.calculate_unary(x, func), f"{func}({x})"

    def handle_trig():
        func = input("Enter trig function: ")
        x = float(input("Enter angle/value: "))
        return calc.calculate_unary(x, func), f"{func}({x})"

    def handle_complex():
        c1 = calc.parse_complex(input("Enter first complex number: "))
        op = input("Enter operator (+ - * /): ")
        c2 = calc.parse_complex(input("Enter second complex number: "))
        return calc.calculate_complex(c1, c2, op), f"{c1} {op} {c2}"

    def handle_conversion():
        v = float(input("Enter value: "))
        from_unit = input("From unit: ")
        to_unit = input("To unit: ")
        return calc.convert_units(v, from_unit, to_unit), f"{v} {from_unit} -> {to_unit}"

    def handle_stats():
        print("Enter numbers separated by space:")
        data = list(map(float, input().split()))
        mean_, std_ = calc.statistics(data)
        desc = f"Stats = Mean: {mean_}, Std Dev: {std_}"
        print(desc)
        calc.add_to_history(desc)
        return None, None

    def handle_expression():
        expr = input("Enter expression: ")
        result = calc.evaluate_expression(expr)
        return result, expr

    def handle_equation():
        expr = input("Enter equation in terms of x (e.g., x**2 - 4): ")
        a = float(input("Lower bound: "))
        b = float(input("Upper bound: "))
        result = calc.solve_equation(expr, a, b)
        return result, f"root of {expr} in [{a}, {b}]"

    menu_actions = {
        '1': handle_basic_op,
        '2': handle_unary,
        '3': handle_trig,
        '4': handle_trig,
        '5': handle_complex,
        '6': handle_conversion,
        '7': handle_stats,
        '8': handle_expression,
        '9': handle_equation
    }

    def show_menu():
        print("""
=== Optimized Scientific Python Calculator ===
1. Basic Operation (+, -, *, /, %, ^)
2. Unary Function (sqrt, cbrt, ln, log, exp, tenpow, factorial)
3. Trigonometry (sin, cos, tan, cot, sec, csc)
4. Inverse Trigonometry (asin, acos, atan, acot, asec, acsc)
5. Complex Numbers (e.g., 2+3i)
6. Unit Conversion (m <-> cm, km <-> m, deg <-> rad)
7. Statistics (mean, std dev)
8. Expression Evaluation (e.g., 2 + 3 * pi)
9. Solve Equation (e.g., x^2 - 4 = 0)
10. Memory Add (m+)
11. Memory Subtract (m-)
12. Memory Recall (mr)
13. Memory Clear (mc)
14. Toggle Mode (Rad/Deg)
15. Random Number (0 to 1)
16. History
17. Reset
18. Exit
""")

    while True:
        show_menu()
        choice = input("Select an option (1-18): ")

        if choice in menu_actions:
            result, desc = menu_actions[choice]()
            if desc is not None:
                print("Result:", result)
                calc.add_to_history(f"{desc} = {result}")

        elif choice == '10':
            calc.store_memory(result)

        elif choice == '11':
            calc.subtract_memory(result)

        elif choice == '12':
            calc.recall_memory()

        elif choice == '13':
            calc.clear_memory()

        elif choice == '14':
            calc.toggle_mode()

        elif choice == '15':
            result = calc.random_number()
            print("Random number:", result)
            calc.add_to_history(f"Random number: {result}")

        elif choice == '16':
            calc.show_history()

        elif choice == '17':
            calc.reset()

        elif choice == '18':
            print("Goodbye!")
            break

        else:
            print("Invalid choice. Try again.")

        input("\nPress Enter to continue...")
