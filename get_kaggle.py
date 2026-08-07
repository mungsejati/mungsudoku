import urllib.request
import ssl
import json

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

# Querying a well known 17 clue puzzle
url = "https://raw.githubusercontent.com/rosettacode/rosettacode-Data/master/Task/Sudoku/sudoku.txt"
try:
    with urllib.request.urlopen(url, context=ctx) as response:
        content = response.read().decode('utf-8')
        print(content[:500])
except Exception as e:
    print(f"Error: {e}")
