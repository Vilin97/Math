import numpy as np

def is_valid(puzzle):
    if len(puzzle) != 9:
        print("Not 9 rows")
        return False
    for r in range(9):
        if len(puzzle[r]) != 9:
            print("Not 9 columns")
            return False
        for c in range(9):
            if puzzle[r][c] not in range(0,9+1):
                print(f"Wrong number at {(r,c)}")
                return False
    return True

def make_sets(puzzle):
    rows = [set() for _ in range(9)]
    cols = [set() for _ in range(9)]
    squares = [[set() for _ in range(3)] for _ in range(3)]
    for r in range(9):
        for c in range(9):
            num = puzzle[r][c]
            if num != 0:
                rows[r].add(num)
                cols[c].add(num)
                squares[r//3][c//3].add(num)
    return rows, cols, squares

# use priority queue to choose the next cell, with (key, val) = (len(allowed_numbers(cell))), cell)

class Sudoku:
    def __init__(self, puzzle) -> None:
        self.puzzle = np.array(puzzle)
        self.rows, self.cols, self.squares = make_sets(puzzle)
        # self.empty_cells = set([(r,c) for r in range(9) for c in range(9) if self.puzzle[r,c]==0])
    
    def is_solved(self):
        for r in range(9):
            if len(self.rows[r]) < 9:
                return False
        for c in range(9):
            if len(self.cols[c]) < 9:
                return False
        for i in range(3):
            for j in range(3):
                if len(self.squares[i][j]) < 9:
                    return False
        return True

    def place_number(self, num, row, col):
        self.puzzle[row, col] = num
        self.rows[row].add(num)
        self.cols[col].add(num)
        self.squares[row//3][col//3].add(num)
        # self.empty_cells.remove((row, col))
    
    def remove_number(self, num, row, col):
        self.puzzle[row, col] = 0
        self.rows[row].remove(num)
        self.cols[col].remove(num)
        self.squares[row//3][col//3].remove(num)
        # self.empty_cells.add((row, col))

    def allowed_numbers(self, row, col):
        """return numbers that can go in (row, col) cell"""
        if self.puzzle[row, col] != 0:
            return []
        result = []
        for num in range(1,9+1):
            if num not in self.rows[row] and num not in self.cols[col] and num not in self.squares[row//3][col//3]:
                result.append(num)
        return result

    def num_allowed_numbers(self, row, col):
        """return the number of values that can go in (row, col) cell"""
        if self.puzzle[row, col] != 0:
            return 0
        result = 0
        for num in range(1,9+1):
            if num not in self.rows[row] and num not in self.cols[col] and num not in self.squares[row//3][col//3]:
                result += 1
            # if result > 2:
            #     break
        return result

    def choose_cell(self):
        """choose the cell with smallest number of values that can go there, and a boolean that is True if the puzzle might still be solvable"""
        best_row, best_col, shortest = 0,0,9
        for row in range(9):
            for col in range(9):
                if self.puzzle[row, col] != 0:
                    continue
                num_allowed = self.num_allowed_numbers(row, col)
                if num_allowed == 0:
                    return (row, col), False
                if num_allowed < shortest:
                    best_row, best_col, shortest = row, col, num_allowed
        return (best_row, best_col), (shortest != 9)

    def solve_recursive(self, solutions, rec_depth):
        """return all possible solutions appended to the solutions array"""
        indent = (20-rec_depth)*" "
        if rec_depth<=0 or len(solutions)==1:
            # print(f"{indent}ran out of recursive depth")
            return
        
        (best_row, best_col), has_valid_move = self.choose_cell()
        if has_valid_move:
            allowed_nums = self.allowed_numbers(best_row, best_col)
            for num in allowed_nums:
                #make a guess out of the allowed numbers (might be only one number)
                if len(allowed_nums) == 1:
                    # print(f"{indent}placing {num} at {(best_row,best_col)}")
                    new_depth = rec_depth
                elif len(allowed_nums) == 2:
                    # print(f"{indent}guessing {num} at {(best_row,best_col)}")
                    new_depth = rec_depth-1
                else:
                    new_depth = 0
                self.place_number(num, best_row, best_col)
                self.solve_recursive(solutions, new_depth)
                self.remove_number(num, best_row, best_col)
        else:
            if self.is_solved():
                print(f"{indent}SOLVED with depth {rec_depth} left")
                solutions.append(np.copy(self.puzzle))

def sudoku_solver(puzzle):
    print(f"Solving sudoku\n{puzzle}")
    assert is_valid(puzzle)
    sudoku = Sudoku(puzzle)
    solutions = []
    sudoku.solve_recursive(solutions, 30)
    print(f"solutions:\n{solutions}")
    assert len(solutions) == 1
    solution = solutions[0].tolist()
    return solution

puzzle_ = [
[5, 0, 0, 0, 0, 0, 3, 0, 0], 
[0, 6, 0, 8, 0, 2, 0, 4, 0], 
[0, 0, 1, 0, 0, 0, 0, 0, 5], 
[0, 1, 0, 3, 2, 0, 0, 7, 0], 
[0, 0, 2, 0, 0, 4, 0, 0, 0], 
[3, 0, 4, 0, 7, 0, 6, 0, 9], 
[8, 0, 7, 0, 1, 0, 5, 0, 4], 
[0, 0, 0, 5, 0, 0, 7, 0, 0], 
[0, 5, 0, 0, 0, 7, 0, 3, 0]]

import time
t1 = time.time()
sudoku_solver(puzzle_)
t2 = time.time()
print(f"Took {t2-t1} seconds")