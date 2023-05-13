isprime(x) = x > 1 && all(x % i != 0 for i in 2:floor(sqrt(x)))

for b in 1:10^3
    all( !isprime(10b + a) for a in 0:9) && println(b)
end
201 # % 3 == 0
202 # even
203 # % 7 == 0
204 # even
205 # % 5 == 0
206 # even
207 # % 3 == 0
208 # even
209 # % 11 == 0