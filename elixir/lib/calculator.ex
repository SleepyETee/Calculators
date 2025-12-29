defmodule Calculator do
  @moduledoc """
  Scientific Calculator in Elixir
  """

  @constants %{
    "pi" => :math.pi(),
    "e" => :math.exp(1),
    "c" => 299_792_458.0,
    "g" => 9.80665,
    "h" => 6.62607015e-34
  }

  defstruct memory: 0.0, history: [], radian_mode: false

  def new, do: %Calculator{}

  def to_radians(deg), do: deg * :math.pi() / 180.0
  def to_degrees(rad), do: rad * 180.0 / :math.pi()

  def get_angle(%Calculator{radian_mode: true}, x), do: x
  def get_angle(%Calculator{radian_mode: false}, x), do: to_radians(x)

  def from_angle(%Calculator{radian_mode: true}, r), do: r
  def from_angle(%Calculator{radian_mode: false}, r), do: to_degrees(r)

  def calculate(a, b, op) do
    result = case op do
      "+" -> {:ok, a + b}
      "-" -> {:ok, a - b}
      "*" -> {:ok, a * b}
      "/" when b == 0 -> {:error, "Division by zero"}
      "/" -> {:ok, a / b}
      "%" when b == 0 -> {:error, "Modulo by zero"}
      "%" -> {:ok, :math.fmod(a, b)}
      "^" ->
        try do
          {:ok, :math.pow(a, b)}
        rescue
          ArithmeticError -> {:error, "Invalid operation (result is undefined)"}
        end
      _ -> {:error, "Unknown operator: #{op}"}
    end
    # Check for NaN or Infinity
    check_result(result)
  end

  defp check_result({:error, _} = err), do: err
  defp check_result({:ok, r}) do
    cond do
      not is_number(r) or r != r -> {:error, "Invalid operation (result is undefined)"}
      is_float(r) and (r == :inf or r == :"-inf") -> {:error, "Overflow (result too large)"}
      is_float(r) and abs(r) > 1.0e308 -> {:error, "Overflow (result too large)"}
      true -> {:ok, r}
    end
  end

  def factorial(n) when n < 0 or n != trunc(n) do
    {:error, "Factorial requires non-negative integer"}
  end
  def factorial(n) when n > 170 do
    {:error, "Factorial overflow (n > 170)"}
  end
  def factorial(n) when n <= 1, do: {:ok, 1.0}
  def factorial(n) do
    result = Enum.reduce(2..trunc(n), 1.0, fn i, acc -> acc * i end)
    {:ok, result}
  end

  def unary_function(calc, func, x) do
    case String.downcase(func) do
      "sin" -> {:ok, :math.sin(get_angle(calc, x))}
      "cos" -> {:ok, :math.cos(get_angle(calc, x))}
      "tan" ->
        angle = get_angle(calc, x)
        if abs(:math.cos(angle)) < 1.0e-9 do
          {:error, "Undefined tan (angle near 90°)"}
        else
          {:ok, :math.tan(angle)}
        end
      "cot" ->
        angle = get_angle(calc, x)
        if abs(:math.sin(angle)) < 1.0e-9 do
          {:error, "Undefined cot (angle near 0°)"}
        else
          {:ok, 1.0 / :math.tan(angle)}
        end
      "sec" ->
        angle = get_angle(calc, x)
        if abs(:math.cos(angle)) < 1.0e-9 do
          {:error, "Undefined sec (angle near 90°)"}
        else
          {:ok, 1.0 / :math.cos(angle)}
        end
      "csc" ->
        angle = get_angle(calc, x)
        if abs(:math.sin(angle)) < 1.0e-9 do
          {:error, "Undefined csc (angle near 0°)"}
        else
          {:ok, 1.0 / :math.sin(angle)}
        end
      "asin" when x < -1 or x > 1 -> {:error, "asin domain is [-1, 1]"}
      "asin" -> {:ok, from_angle(calc, :math.asin(x))}
      "acos" when x < -1 or x > 1 -> {:error, "acos domain is [-1, 1]"}
      "acos" -> {:ok, from_angle(calc, :math.acos(x))}
      "atan" -> {:ok, from_angle(calc, :math.atan(x))}
      "sinh" -> {:ok, :math.sinh(x)}
      "cosh" -> {:ok, :math.cosh(x)}
      "tanh" -> {:ok, :math.tanh(x)}
      "asinh" -> {:ok, :math.asinh(x)}
      "acosh" when x < 1 -> {:error, "acosh domain is [1, ∞)"}
      "acosh" -> {:ok, :math.acosh(x)}
      "atanh" when x <= -1 or x >= 1 -> {:error, "atanh domain is (-1, 1)"}
      "atanh" -> {:ok, :math.atanh(x)}
      "sqrt" when x < 0 -> {:error, "Cannot take square root of negative number"}
      "sqrt" -> {:ok, :math.sqrt(x)}
      "cbrt" -> {:ok, sign(x) * :math.pow(abs(x), 1/3)}
      "ln" when x <= 0 -> {:error, "ln domain is (0, ∞)"}
      "ln" -> {:ok, :math.log(x)}
      "log" when x <= 0 -> {:error, "log domain is (0, ∞)"}
      "log" -> {:ok, :math.log10(x)}
      "exp" ->
        if x > 709 do
          {:error, "Overflow (exp result too large)"}
        else
          {:ok, :math.exp(x)}
        end
      "abs" -> {:ok, abs(x)}
      "factorial" -> factorial(x)
      _ -> {:error, "Unknown function: #{func}"}
    end
  end

  defp sign(x) when x < 0, do: -1
  defp sign(_), do: 1

  def convert_units(value, from, to) do
    case {String.downcase(from), String.downcase(to)} do
      {"m", "cm"} -> {:ok, value * 100}
      {"cm", "m"} -> {:ok, value / 100}
      {"km", "m"} -> {:ok, value * 1000}
      {"m", "km"} -> {:ok, value / 1000}
      {"deg", "rad"} -> {:ok, to_radians(value)}
      {"rad", "deg"} -> {:ok, to_degrees(value)}
      _ -> {:error, "Unsupported conversion"}
    end
  end

  def statistics([]), do: {0.0, 0.0}
  def statistics(data) do
    n = length(data)
    mean = Enum.sum(data) / n
    variance = Enum.sum(Enum.map(data, fn x -> :math.pow(x - mean, 2) end)) / n
    {mean, :math.sqrt(variance)}
  end

  def add_to_history(calc, entry) do
    history = [entry | calc.history] |> Enum.take(10)
    %{calc | history: history}
  end

  def toggle_mode(calc) do
    %{calc | radian_mode: not calc.radian_mode}
  end

  def reset(_calc), do: new()

  def get_constants, do: @constants
end

defmodule Calculator.CLI do
  def main(_args) do
    IO.puts("Starting Scientific Calculator (Elixir)...")
    loop(Calculator.new())
  end

  defp loop(calc) do
    show_menu()
    choice = prompt("Select option: ") |> String.trim()
    
    case choice do
      "1" -> handle_basic_op(calc) |> loop()
      "2" -> handle_unary(calc, "sqrt, cbrt, ln, log, exp, abs, factorial") |> loop()
      "3" -> handle_unary(calc, "sin, cos, tan") |> loop()
      "4" -> handle_unary(calc, "asin, acos, atan") |> loop()
      "5" -> handle_unary(calc, "sinh, cosh, tanh") |> loop()
      "6" -> handle_conversion(calc) |> loop()
      "7" -> handle_statistics(calc) |> loop()
      "8" -> handle_memory_add(calc) |> loop()
      "9" -> handle_memory_sub(calc) |> loop()
      "10" -> 
        IO.puts("Memory: #{calc.memory}")
        loop(calc)
      "11" ->
        IO.puts("Memory cleared.")
        loop(%{calc | memory: 0.0})
      "12" ->
        new_calc = Calculator.toggle_mode(calc)
        mode = if new_calc.radian_mode, do: "Radians", else: "Degrees"
        IO.puts("Mode: #{mode}")
        loop(new_calc)
      "13" ->
        show_history(calc)
        loop(calc)
      "14" ->
        IO.puts("Calculator reset.")
        loop(Calculator.new())
      "15" ->
        IO.puts("Goodbye!")
      _ ->
        IO.puts("Invalid option.")
        loop(calc)
    end
  end

  defp show_menu do
    IO.puts("\n=== Scientific Calculator (Elixir) ===")
    IO.puts("1.  Basic Operation (+, -, *, /, %, ^)")
    IO.puts("2.  Unary Function (sqrt, cbrt, ln, log, exp, abs, factorial)")
    IO.puts("3.  Trigonometry (sin, cos, tan)")
    IO.puts("4.  Inverse Trig (asin, acos, atan)")
    IO.puts("5.  Hyperbolic (sinh, cosh, tanh)")
    IO.puts("6.  Unit Conversion")
    IO.puts("7.  Statistics (mean, std dev)")
    IO.puts("8.  Memory Add (M+)")
    IO.puts("9.  Memory Subtract (M-)")
    IO.puts("10. Memory Recall (MR)")
    IO.puts("11. Memory Clear (MC)")
    IO.puts("12. Toggle Mode (Deg/Rad)")
    IO.puts("13. Show History")
    IO.puts("14. Reset")
    IO.puts("15. Exit")
  end

  defp prompt(msg) do
    IO.write(msg)
    IO.read(:stdio, :line) |> String.trim()
  end

  defp prompt_float(msg) do
    case Float.parse(prompt(msg)) do
      {num, _} -> num
      :error -> 0.0
    end
  end

  defp handle_basic_op(calc) do
    a = prompt_float("Enter first number: ")
    op = prompt("Enter operator (+, -, *, /, %, ^): ")
    b = prompt_float("Enter second number: ")
    
    case Calculator.calculate(a, b, op) do
      {:ok, result} ->
        IO.puts("Result: #{result}")
        entry = "#{a} #{op} #{b} = #{result}"
        Calculator.add_to_history(calc, entry)
      {:error, err} ->
        IO.puts("Error: #{err}")
        calc
    end
  end

  defp handle_unary(calc, funcs) do
    func = prompt("Enter function (#{funcs}): ")
    x = prompt_float("Enter value: ")
    
    case Calculator.unary_function(calc, func, x) do
      {:ok, result} ->
        unit = if String.starts_with?(func, "a") and func != "abs", 
               do: if(calc.radian_mode, do: " rad", else: "°"), 
               else: ""
        IO.puts("Result: #{result}#{unit}")
        entry = "#{func}(#{x}) = #{result}"
        Calculator.add_to_history(calc, entry)
      {:error, err} ->
        IO.puts("Error: #{err}")
        calc
    end
  end

  defp handle_conversion(calc) do
    value = prompt_float("Enter value: ")
    from = prompt("From unit (m, cm, km, deg, rad): ")
    to = prompt("To unit: ")
    
    case Calculator.convert_units(value, from, to) do
      {:ok, result} ->
        IO.puts("Result: #{result} #{to}")
        entry = "#{value} #{from} = #{result} #{to}"
        Calculator.add_to_history(calc, entry)
      {:error, err} ->
        IO.puts("Error: #{err}")
        calc
    end
  end

  defp handle_statistics(calc) do
    input = prompt("Enter numbers (space-separated): ")
    data = input
           |> String.split()
           |> Enum.map(&Float.parse/1)
           |> Enum.filter(fn x -> x != :error end)
           |> Enum.map(fn {n, _} -> n end)
    
    {mean, std_dev} = Calculator.statistics(data)
    IO.puts("Mean: #{mean}, Std Dev: #{std_dev}")
    entry = "Stats: mean=#{mean}, std=#{std_dev}"
    Calculator.add_to_history(calc, entry)
  end

  defp handle_memory_add(calc) do
    value = prompt_float("Value to add: ")
    new_calc = %{calc | memory: calc.memory + value}
    IO.puts("Memory: #{new_calc.memory}")
    new_calc
  end

  defp handle_memory_sub(calc) do
    value = prompt_float("Value to subtract: ")
    new_calc = %{calc | memory: calc.memory - value}
    IO.puts("Memory: #{new_calc.memory}")
    new_calc
  end

  defp show_history(calc) do
    if calc.history == [] do
      IO.puts("History is empty.")
    else
      IO.puts("\n=== History ===")
      calc.history |> Enum.reverse() |> Enum.each(&IO.puts/1)
    end
  end
end
