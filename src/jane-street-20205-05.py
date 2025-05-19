#%%
def digits_in_range(n, low=2, high=6):
    return all(low <= int(d) <= high for d in str(n))

def no_consecutive_gt2(n):
    s = str(n)
    for i in range(len(s) - 1):
        if int(s[i]) > 2 and int(s[i+1]) > 2:
            return False
    return True

results = []
max_digits = 11
min_square = int('2' * 1)
max_square = int('6' * max_digits)

# Find the range of numbers whose squares could have up to 11 digits
start = int(min_square ** 0.5)
end = int(max_square ** 0.5) + 1

for i in range(start, end):
    sq = i * i
    if sq > max_square:
        break
    sq = str(sq)
    if digits_in_range(sq) and len(sq) <= max_digits and no_consecutive_gt2(sq):
        results.append(sq)
    # if digits_in_range(sq[:-1]) and len(str(sq)) <= max_digits and digits_in_range(sq[-1:], high=6):
    #     results.append(sq)

# Sort by number of digits in the square, ascending
# results.sort(key=lambda x: len(str(x)))
results.sort(key=lambda x: x.count('2'))

for sq in results:
    print(sq)

#%%
from itertools import combinations, product
from math import isqrt

# ── puzzle-specific constants (edit if I mis-guessed) ────────────────
N            = 11                       # cells in top row
REG_SPLITS   = {3, 8}                   # thick vertical borders after these indices
YELLOW       = {5}                      # yellow cells (0-based index)
BASE_DIGITS  = (1, 2)                   # only 1 / 2 may be written initially

# ── helper tables ───────────────────────────────────────────────────
def squares_with_small_digits(m=11, lo=1, hi=6):
    """All perfect squares (≥2 digits, ≤m digits) whose digits are in [lo, hi]."""
    out, bound = set(), 10**m - 1
    for k in range(4, isqrt(bound) + 1):     # 4 = smallest 2-digit square
        s = str(k * k)
        if all(lo <= int(d) <= hi for d in s):
            out.add(int(s))
    return out

GOOD_SQUARES = squares_with_small_digits()

# ── constraints ─────────────────────────────────────────────────────
def regions_ok(row):
    """adjacent cells separated by a thick border must differ."""
    return all(row[i-1] != row[i] if i in REG_SPLITS else True
               for i in range(1, N))

def legal_tiles(tiles):
    """no yellow, no adjacency."""
    if any(t in YELLOW for t in tiles):                # cannot tile yellow
        return False
    return all(b - a > 1 for a, b in zip(tiles, tiles[1:]))

# ── displacement / increment logic for the top row only ────────────
NEI = ((-1,), (1,), (-1, 1))           # neighbours left / right (below ignored)

def apply_tiles(base, tiles):
    """Return the visible digits after placing tiles in the top row."""
    row = list(base)
    for t in tiles:
        displaced = row[t]
        row[t] = None                  # black square
        for nb in (t-1, t+1):
            if 0 <= nb < N and nb not in tiles and nb not in YELLOW:
                row[nb] = min(9, row[nb] + displaced)
    return row

def segments(row, tiles):
    """concatenate visible digits into numbers (≥2 digits)."""
    nums, cur = [], []
    for i in range(N):
        if i in tiles or row[i] is None:
            if len(cur) > 1:
                nums.append(int(''.join(map(str, cur))))
            cur = []
        else:
            cur.append(row[i])
    if len(cur) > 1:
        nums.append(int(''.join(map(str, cur))))
    return nums

# ── brute-force search ──────────────────────────────────────────────
solutions = []
for base in product(BASE_DIGITS, repeat=N):
    if not regions_ok(base):
        continue
    for r in range(N + 1):
        for tiles in combinations(range(N), r):
            if not legal_tiles(tiles):
                continue
            row = apply_tiles(base, tiles)
            if any(idx in YELLOW and row[idx] != base[idx] for idx in YELLOW):
                continue
            nums = segments(row, tiles)
            if nums and all(n in GOOD_SQUARES for n in nums):
                solutions.append((base, tiles, nums))

# ── outcome ─────────────────────────────────────────────────────────
print(f"{len(solutions)} valid layouts found.")
for b, t, nums in solutions:
    s = ''.join(str(d) if i not in t else '■' for i, d in enumerate(b))
    print(f"{s}  tiles={t}  numbers={nums}")
