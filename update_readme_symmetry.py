import re

with open('README.md', 'r') as f:
    content = f.read()

symmetry_doc = """
### Dynamic Generator & Seed Bank Optimisation
- **Rotational Symmetry**: Seluruh puzzle yang digenerate secara dinamis (mengurangi dari solusi penuh) kini mengimplementasikan **180-degree Rotational Symmetry**. Jika sel di baris `r` dan kolom `c` dilubangi, sel lawannya di `(size-1-r, size-1-c)` juga otomatis dilubangi, meniru gaya klasik puzzle Sudoku buatan manusia.
- **Extreme Seed Bank**: Karena komputasi mencari puzzle berukuran tepat 17-clue secara dinamis sangat berat dan memakan waktu, mode Extreme mengambil _seed_ puzzle 17-clue pra-komputasi. _Seed_ ini kemudian ditransformasi secara isometrik (rotasi 90/180/270 derajat) dan nilai angkanya di-acak (permutation) untuk menghasilkan variasi tanpa batas dalam hitungan milidetik.
- **Expert Strict Looping**: Level Expert (22 clue) menerapkan *strict looping*, di mana generator akan terus merestart algoritma masking apabila buntu di angka 23-24 clue, hingga sukses mengunci persis di angka 22 clue.
"""

# Insert before "lib/src/features/game/data/services/sudoku_generator.dart"
content = content.replace("### 📄 `lib/src/features/game/data/services/sudoku_generator.dart`", symmetry_doc + "\n### 📄 `lib/src/features/game/data/services/sudoku_generator.dart`")

with open('README.md', 'w') as f:
    f.write(content)
