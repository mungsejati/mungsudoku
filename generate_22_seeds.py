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

seeds = [
    '000000010400000000020000000000050407008000300001090000300400200050100000000806000',
    '000000010000002003000400000000000500401600000007100000050000200000080040300000000',
    '000000012000000003000300000000004500000000006000700000000000008000000000000000000'
]

print("  static const List<String> _seeds22 = [")
for seed_str in seeds:
    grid = [[int(seed_str[r*9+c]) for c in range(9)] for r in range(9)]
    # Make a copy to solve
    solved = [[int(seed_str[r*9+c]) for c in range(9)] for r in range(9)]
    solve_sudoku(solved)
    
    # We want to add exactly 5 clues. Let's just pick 5 empty spots.
    added = 0
    import random
    random.seed(hash(seed_str))
    positions = list(range(81))
    random.shuffle(positions)
    
    for p in positions:
        r, c = p // 9, p % 9
        if grid[r][c] == 0:
            grid[r][c] = solved[r][c]
            added += 1
            if added == 5:
                break
                
    new_str = "".join(str(grid[r][c]) for r in range(9) for c in range(9))
    print(f"    '{new_str}',")
print("  ];")
