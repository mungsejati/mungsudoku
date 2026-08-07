import urllib.request
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

url = "https://raw.githubusercontent.com/grantm/sudoku/master/puzzles/17_clue.txt"
try:
    with urllib.request.urlopen(url, context=ctx) as response:
        content = response.read().decode('utf-8')
        lines = content.strip().split('\n')
        print(f"Downloaded {len(lines)} puzzles")
        for i in range(10):
            print(lines[i])
except Exception as e:
    print(f"Error: {e}")
