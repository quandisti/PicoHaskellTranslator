fibbonacci:: Int -> Int

fibbonacci 0 = 1
fibbonacci 1 = 1
fibbonacci n = fibbonacci(n-1) + fibbonacci(n-2)

let x <- getInt
print(fibbonacci(x))
