-- Type annotation
factorial :: (Int a) => a -> a

-- Using recursion (with pattern matching)
factorial 0 = 1
factorial n = n * factorial (n - 1)

let x <- getInt
print(factorial(x))
let y = 8
x = y
print(factorial(x))
