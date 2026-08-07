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

    def count_solutions(r, c, count):
        if r == 9:
            return count + 1
        if c == 9:
            return count_solutions(r+1, 0, count)
        if grid[r][c] != 0:
            return count_solutions(r, c+1, count)
        
        for val in range(1, 10):
            if is_valid(r, c, val):
                grid[r][c] = val
                count = count_solutions(r, c+1, count)
                grid[r][c] = 0
                if count > 1: return count
        return count

    return count_solutions(0, 0, 0)

s = "000000010400000000020000000000050407008000300001090000300400200050100000000806000"
grid = [[int(s[r*9+c]) for c in range(9)] for r in range(9)]
c = solve_sudoku(grid)
print(f"Solutions: {c}")

s2 = "000000010400000000020000000000050407008000300001090000300400200050100000000806000"
# let's write a small generator in python to find a few more 17-clue puzzles by permuting. No, permuting digits doesn't change the clue positions. We want different clue positions.
