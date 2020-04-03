-- Type annotation
factorial :: (Int a) => a -> a

-- Using recursion (with the "ifthenelse" expression)
factorial n = if n < 2
              then 1
              else n * factorial (n - 1)

let x <- getInt
print(factorial(x))
let y = 8
x = y
print(factorial(x))
