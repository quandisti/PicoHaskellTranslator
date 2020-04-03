-- Type annotation
factorial :: (Int a) => a -> a

-- Using recursion (with guards)
factorial n
   | n < 2     = 1
   | otherwise = n * factorial (n - 1)

let x <- getInt
print(factorial(x))
let y = 8
x = y
print(factorial(x))
