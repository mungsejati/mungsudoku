import urllib.request

url = "http://staffhome.ecm.uwa.edu.au/~00013890/sudokumin.php"
try:
    with urllib.request.urlopen(url) as response:
        html = response.read().decode()
        print(html[:500])
except Exception as e:
    print(e)
