module Main where

import Text.Read (readMaybe)
import Data.Char (toLower)
import Control.Monad (when)
import Data.IORef
import System.IO (hFlush, stdout)

data CalcState = CalcState
    { memory     :: Double
    , history    :: [String]
    , radianMode :: Bool
    } deriving (Show)

initialState :: CalcState
initialState = CalcState 0.0 [] False

constants :: [(String, Double)]
constants = 
    [ ("pi", pi)
    , ("e", exp 1)
    , ("c", 299792458.0)
    , ("g", 9.80665)
    , ("h", 6.62607015e-34)
    ]

toRadians :: Double -> Double
toRadians deg = deg * pi / 180.0

toDegrees :: Double -> Double
toDegrees rad = rad * 180.0 / pi

getAngle :: Bool -> Double -> Double
getAngle True x  = x
getAngle False x = toRadians x

fromAngle :: Bool -> Double -> Double
fromAngle True r  = r
fromAngle False r = toDegrees r

calculate :: Double -> Double -> Char -> Either String Double
calculate a b op = checkResult $ case op of
    '+' -> Right (a + b)
    '-' -> Right (a - b)
    '*' -> Right (a * b)
    '/' -> if b == 0 then Left "Division by zero" else Right (a / b)
    '%' -> if b == 0 then Left "Modulo by zero" else Right (a `mod'` b)
    '^' -> Right (a ** b)
    _   -> Left $ "Unknown operator: " ++ [op]
  where
    mod' x y = x - y * fromIntegral (floor (x / y))
    checkResult (Left err) = Left err
    checkResult (Right r)
        | isNaN r = Left "Invalid operation (result is undefined)"
        | isInfinite r = Left "Overflow (result too large)"
        | otherwise = Right r

factorial :: Double -> Either String Double
factorial n
    | n < 0 || n /= fromIntegral (floor n) = Left "Factorial requires non-negative integer"
    | n > 170 = Left "Factorial overflow (n > 170)"
    | n <= 1 = Right 1.0
    | otherwise = Right $ product [1.0 .. n]

unaryFunction :: Bool -> String -> Double -> Either String Double
unaryFunction radMode func x = case map toLower func of
    "sin"       -> Right $ sin (getAngle radMode x)
    "cos"       -> Right $ cos (getAngle radMode x)
    "tan"       -> let angle = getAngle radMode x
                   in if abs (cos angle) < 1e-9
                      then Left "Undefined tan (angle near 90°)"
                      else Right $ tan angle
    "cot"       -> let angle = getAngle radMode x
                   in if abs (sin angle) < 1e-9
                      then Left "Undefined cot (angle near 0°)"
                      else Right $ 1 / tan angle
    "sec"       -> let angle = getAngle radMode x
                   in if abs (cos angle) < 1e-9
                      then Left "Undefined sec (angle near 90°)"
                      else Right $ 1 / cos angle
    "csc"       -> let angle = getAngle radMode x
                   in if abs (sin angle) < 1e-9
                      then Left "Undefined csc (angle near 0°)"
                      else Right $ 1 / sin angle
    "asin"      -> if x < -1 || x > 1 
                   then Left "asin domain is [-1, 1]"
                   else Right $ fromAngle radMode (asin x)
    "acos"      -> if x < -1 || x > 1
                   then Left "acos domain is [-1, 1]"
                   else Right $ fromAngle radMode (acos x)
    "atan"      -> Right $ fromAngle radMode (atan x)
    "sinh"      -> Right $ sinh x
    "cosh"      -> Right $ cosh x
    "tanh"      -> Right $ tanh x
    "asinh"     -> Right $ asinh x
    "acosh"     -> if x < 1
                   then Left "acosh domain is [1, ∞)"
                   else Right $ acosh x
    "atanh"     -> if x <= -1 || x >= 1
                   then Left "atanh domain is (-1, 1)"
                   else Right $ atanh x
    "sqrt"      -> if x < 0
                   then Left "Cannot take square root of negative number"
                   else Right $ sqrt x
    "cbrt"      -> Right $ signum x * (abs x ** (1/3))
    "ln"        -> if x <= 0
                   then Left "ln domain is (0, ∞)"
                   else Right $ log x
    "log"       -> if x <= 0
                   then Left "log domain is (0, ∞)"
                   else Right $ logBase 10 x
    "exp"       -> let result = exp x
                   in if isInfinite result
                      then Left "Overflow (exp result too large)"
                      else Right result
    "abs"       -> Right $ abs x
    "factorial" -> factorial x
    _           -> Left $ "Unknown function: " ++ func

convertUnits :: Double -> String -> String -> Either String Double
convertUnits value from to = case (map toLower from, map toLower to) of
    ("m", "cm")   -> Right $ value * 100
    ("cm", "m")   -> Right $ value / 100
    ("km", "m")   -> Right $ value * 1000
    ("m", "km")   -> Right $ value / 1000
    ("deg", "rad") -> Right $ toRadians value
    ("rad", "deg") -> Right $ toDegrees value
    _             -> Left "Unsupported conversion"

statistics :: [Double] -> (Double, Double)
statistics [] = (0.0, 0.0)
statistics xs = (mean, stdDev)
  where
    n = fromIntegral $ length xs
    mean = sum xs / n
    variance = sum (map (\x -> (x - mean) ** 2) xs) / n
    stdDev = sqrt variance

addToHistory :: String -> CalcState -> CalcState
addToHistory entry state = 
    state { history = take 10 (entry : history state) }

showHistory :: CalcState -> IO ()
showHistory state = 
    if null (history state)
    then putStrLn "History is empty."
    else do
        putStrLn "\n=== History ==="
        mapM_ putStrLn (reverse $ history state)

toggleMode :: CalcState -> CalcState
toggleMode state = state { radianMode = not (radianMode state) }

resetCalc :: CalcState -> CalcState
resetCalc _ = initialState

showMenu :: IO ()
showMenu = do
    putStrLn "\n=== Scientific Calculator (Haskell) ==="
    putStrLn "1.  Basic Operation (+, -, *, /, %, ^)"
    putStrLn "2.  Unary Function (sqrt, cbrt, ln, log, exp, abs, factorial)"
    putStrLn "3.  Trigonometry (sin, cos, tan)"
    putStrLn "4.  Inverse Trig (asin, acos, atan)"
    putStrLn "5.  Hyperbolic (sinh, cosh, tanh)"
    putStrLn "6.  Unit Conversion"
    putStrLn "7.  Statistics (mean, std dev)"
    putStrLn "8.  Memory Add (M+)"
    putStrLn "9.  Memory Subtract (M-)"
    putStrLn "10. Memory Recall (MR)"
    putStrLn "11. Memory Clear (MC)"
    putStrLn "12. Toggle Mode (Deg/Rad)"
    putStrLn "13. Show History"
    putStrLn "14. Reset"
    putStrLn "15. Exit"

prompt :: String -> IO String
prompt msg = do
    putStr msg
    hFlush stdout
    getLine

promptDouble :: String -> IO Double
promptDouble msg = do
    input <- prompt msg
    return $ maybe 0.0 id (readMaybe input)

main :: IO ()
main = do
    stateRef <- newIORef initialState
    loop stateRef
  where
    loop stateRef = do
        showMenu
        choice <- prompt "\nSelect option: "
        state <- readIORef stateRef
        
        case choice of
            "1" -> do
                a <- promptDouble "Enter first number: "
                opStr <- prompt "Enter operator (+, -, *, /, %, ^): "
                let op = if null opStr then '+' else head opStr
                b <- promptDouble "Enter second number: "
                case calculate a b op of
                    Right result -> do
                        putStrLn $ "Result: " ++ show result
                        let entry = show a ++ " " ++ [op] ++ " " ++ show b ++ " = " ++ show result
                        modifyIORef stateRef (addToHistory entry)
                    Left err -> putStrLn $ "Error: " ++ err
                loop stateRef
                
            "2" -> do
                func <- prompt "Enter function (sqrt, cbrt, ln, log, exp, abs, factorial): "
                x <- promptDouble "Enter value: "
                case unaryFunction (radianMode state) func x of
                    Right result -> do
                        putStrLn $ "Result: " ++ show result
                        let entry = func ++ "(" ++ show x ++ ") = " ++ show result
                        modifyIORef stateRef (addToHistory entry)
                    Left err -> putStrLn $ "Error: " ++ err
                loop stateRef
                
            "3" -> do
                func <- prompt "Enter function (sin, cos, tan): "
                x <- promptDouble "Enter angle: "
                case unaryFunction (radianMode state) func x of
                    Right result -> do
                        putStrLn $ "Result: " ++ show result
                        let entry = func ++ "(" ++ show x ++ ") = " ++ show result
                        modifyIORef stateRef (addToHistory entry)
                    Left err -> putStrLn $ "Error: " ++ err
                loop stateRef
                
            "4" -> do
                func <- prompt "Enter function (asin, acos, atan): "
                x <- promptDouble "Enter value: "
                case unaryFunction (radianMode state) func x of
                    Right result -> do
                        let unit = if radianMode state then " rad" else "°"
                        putStrLn $ "Result: " ++ show result ++ unit
                        let entry = func ++ "(" ++ show x ++ ") = " ++ show result
                        modifyIORef stateRef (addToHistory entry)
                    Left err -> putStrLn $ "Error: " ++ err
                loop stateRef
                
            "5" -> do
                func <- prompt "Enter function (sinh, cosh, tanh): "
                x <- promptDouble "Enter value: "
                case unaryFunction (radianMode state) func x of
                    Right result -> do
                        putStrLn $ "Result: " ++ show result
                        let entry = func ++ "(" ++ show x ++ ") = " ++ show result
                        modifyIORef stateRef (addToHistory entry)
                    Left err -> putStrLn $ "Error: " ++ err
                loop stateRef
                
            "6" -> do
                value <- promptDouble "Enter value: "
                from <- prompt "From unit (m, cm, km, deg, rad): "
                to <- prompt "To unit: "
                case convertUnits value from to of
                    Right result -> do
                        putStrLn $ "Result: " ++ show result ++ " " ++ to
                        let entry = show value ++ " " ++ from ++ " = " ++ show result ++ " " ++ to
                        modifyIORef stateRef (addToHistory entry)
                    Left err -> putStrLn $ "Error: " ++ err
                loop stateRef
                
            "7" -> do
                input <- prompt "Enter numbers (space-separated): "
                let nums = mapMaybe readMaybe (words input) :: [Double]
                let (mean, stdDev) = statistics nums
                putStrLn $ "Mean: " ++ show mean ++ ", Std Dev: " ++ show stdDev
                let entry = "Stats: mean=" ++ show mean ++ ", std=" ++ show stdDev
                modifyIORef stateRef (addToHistory entry)
                loop stateRef
                
            "8" -> do
                value <- promptDouble "Value to add: "
                modifyIORef stateRef (\s -> s { memory = memory s + value })
                newState <- readIORef stateRef
                putStrLn $ "Memory: " ++ show (memory newState)
                loop stateRef
                
            "9" -> do
                value <- promptDouble "Value to subtract: "
                modifyIORef stateRef (\s -> s { memory = memory s - value })
                newState <- readIORef stateRef
                putStrLn $ "Memory: " ++ show (memory newState)
                loop stateRef
                
            "10" -> do
                putStrLn $ "Memory: " ++ show (memory state)
                loop stateRef
                
            "11" -> do
                modifyIORef stateRef (\s -> s { memory = 0.0 })
                putStrLn "Memory cleared."
                loop stateRef
                
            "12" -> do
                modifyIORef stateRef toggleMode
                newState <- readIORef stateRef
                putStrLn $ "Mode: " ++ if radianMode newState then "Radians" else "Degrees"
                loop stateRef
                
            "13" -> do
                showHistory state
                loop stateRef
                
            "14" -> do
                writeIORef stateRef initialState
                putStrLn "Calculator reset."
                loop stateRef
                
            "15" -> putStrLn "Goodbye!"
            
            _ -> do
                putStrLn "Invalid option."
                loop stateRef

mapMaybe :: (a -> Maybe b) -> [a] -> [b]
mapMaybe _ [] = []
mapMaybe f (x:xs) = case f x of
    Just y  -> y : mapMaybe f xs
    Nothing -> mapMaybe f xs
