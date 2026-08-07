def solve_sudoku(grid):
    def is_valid(r, c, val):
        for i in range(9):
            if grid[r][i] == val or grid[i][c] == val: return False
            if grid[3*(r//3) + i//3][3*(c//3) + i%3] == val: return False
        return True

    def backtrack(r, c):
        if r == 9: return True
        if c == 9: return backtrack(r+1, 0)
        if grid[r][c] != 0: return backtrack(r, c+1)

        for val in range(1, 10):
            if is_valid(r, c, val):
                grid[r][c] = val
                if backtrack(r, c+1): return True
                grid[r][c] = 0
        return False
    
    backtrack(0, 0)
    return grid

seed_str = '000000010400000000020000000000050407008000300001090000300400200050100000000806000'

grid = [[int(seed_str[r*9+c]) for c in range(9)] for r in range(9)]
solved = [[int(seed_str[r*9+c]) for c in range(9)] for r in range(9)]
solve_sudoku(solved)

# Pick 5 empty spots that are symmetric if possible, or just any 5 empty spots
import random
random.seed(42)
positions = list(range(81))
random.shuffle(positions)

added = 0
for p in positions:
    r, c = p // 9, p % 9
    if grid[r][c] == 0:
        grid[r][c] = solved[r][c]
        added += 1
        if added == 5:
            break
            
new_str = "".join(str(grid[r][c]) for r in range(9) for c in range(9))
print("22 CLUE SEED:")
print(new_str)
