# Project Scope - Custom & Social Sudoku

## In-Scope (Fitur yang AKAN Dibuat)

### Phase 1: Standar Sudoku Core Engine (Fitur Umum Game Sudoku)
Fokus fase ini adalah membuat game Sudoku klasik 9x9 (sub-grid 3x3) versi offline yang solid, nyaman dimainkan, dan memiliki fitur standardisasi game Sudoku modern.
- **Classic 9x9 Engine:** Validasi baris, kolom, dan sub-grid 3x3 standar menggunakan angka 1-9.
- **Built-in Puzzle Generator:** Menyediakan bank teka-teki bawaan lokal dengan tingkat kesulitan yang terukur: Easy, Medium, Hard.
- **Essential Gameplay Mechanics (Fitur Umum):**
  - **Timer:** Penghitung waktu bermain untuk mengukur kecepatan menyelesaikan teka-teki.
  - **Pause/Resume:** Kemampuan untuk menjeda game (waktu berhenti dan board disembunyikan agar tidak curang).
  - **Undo / Redo:** Membatalkan atau mengulang langkah pengisian kotak tanpa batasan jumlah langkah.
  - **Notes / Pencil Mode:** Fitur mencoret angka-angka kecil sebagai kandidat di dalam satu kotak sebelum menentukan pilihan final.
  - **Error/Mistake Counter & Highlighter:** 
    - Mendeteksi dan memberi highlight merah jika ada angka kembar yang melanggar aturan di baris/kolom/sub-grid yang sama.
    - Batasan maksimal salah (misal: maksimal 3 kali salah sebelum Game Over, bisa diatur aktif/nonaktif).
  - **Hint System:** Bantuan untuk mengisi otomatis satu kotak yang dipilih pemain (dibatasi jumlahnya per game).
  - **Essential Gameplay Mechanics:**
    - **Auto-Save System:** Menyimpan progres papan (angka terisi, notes, waktu running) secara *real-time* setiap ada perubahan input. Ketika pemain kembali ke "Play Classic", sistem otomatis mendeteksi game yang belum selesai dan memunculkan opsi "Resume" atau "New Game".
    - **Dual Input Method (Standard & Fast Mode):**
      - *Standard (Method A):* Tap kotak kosong -> Tap angka 1-9 di numpad bawah.
      - *Fast Mode (Method B):* Tap/tahan salah satu angka di numpad bawah hingga masuk ke "Active Mode", lalu pemain bisa tap beberapa kotak kosong sekaligus untuk mengisi angka tersebut dengan cepat.
    - **Dynamic Notes / Pencil Mode:** 
      - Pemain bisa mencoret angka kecil sebagai kandidat di dalam kotak.
      - *Future-Proof Design:* Engine UI harus dirancang agar grid *notes* ini menggunakan visual placeholder yang bisa beradaptasi jika di Phase 2 angka diubah menjadi Huruf atau Angka Romawi.
      - *Highlighting:* Jika pemain menyentuh sebuah kotak yang berisi angka 5, maka seluruh kotak lain di board yang mengandung angka 5 (termasuk angka 5 kecil di dalam coretan/notes) akan otomatis menyala (highlighted).
    - **Ad-Ready Hint System (Sistem Kuota):**
      - Fitur Hint akan langsung mengisi 1 kotak yang dipilih pemain dengan jawaban yang benar.
      - Setiap pemain memiliki jatah **3 Kuota Hint Gratis** per game.
      - *Monetization Hook:* Jika kuota habis, tombol Hint akan berubah menjadi ikon "Tonton Iklan/+1 Hint" (Di Phase 1 ini dibuat fungsionalitas tombolnya terlebih dahulu menggunakan mock-up dialog *Simulate Watch Ad* untuk menambah kuota).
      - Penggunaan Hint tidak memberikan penalti waktu, namun skor akhir akan mencatat jumlah Hint yang digunakan.
- **Essential UI & Navigation Menu:**
  - **Main Menu Screen:** Tampilan awal minimalis yang menyediakan akses instan ke permainan baru ("Play Classic"), pengaturan dasar, dan *placeholder* untuk fitur Phase 2/3 (tombol mode kustom/challenge di-disable).
  - **Difficulty Selector:** Pop-up atau halaman transisi setelah menekan "Play Classic" untuk memilih tingkat kesulitan (Easy, Medium, Hard).
  - **In-Game Pause Menu:** Overlay menu saat game di-pause yang berisi opsi: *Resume Game*, *Restart Puzzle* (mengulang dari awal waktu 00:00 dengan board yang sama), dan *Quit to Main Menu* (keluar dan membatalkan game berjalan).
  - **Victory / Game Over Screen:** Dialog akhir yang muncul saat puzzle selesai dengan benar (menampilkan waktu tempuh) atau saat salah mengisi kotak melebihi batas maksimal (Game Over).

### Phase 2: Kustomisasi Grid & Simbol (Fitur Khusus Offline)
- **Modular Grid Expansion:** Mengembangkan engine agar mendukung variasi sub-grid kustom (2x2 = 16 kotak, 4x4 = 256 kotak, 5x5 = 625 kotak).
- **Symbol Changer Mod:** Mengubah visual isi kotak dari angka standar menjadi:
  - Angka Romawi (I, II, III, dst.)
  - Huruf Alfabet (A, B, C, dst.)
  - Warna Kontras (Palet warna solid)
- **Board Skin Manager:** Pengaturan tema visual untuk mengubah warna latar belakang, garis grid, dan teks secara kosmetik.

### Phase 3: Supabase Integration & Social Challenges
- **Anonymous/Easy Auth:** Menggunakan Supabase Anonymous Sign-In agar player bisa langsung berinteraksi dengan fitur online tanpa hambatan registrasi.
- **Puzzle Creator Studio:** Antarmuka khusus untuk mendesain teka-teki buatan sendiri lengkap dengan tombol "Validate Puzzle" (memastikan puzzle *solvable* sebelum disimpan).
- **Room Code Generator & Storage:** Menyimpan data puzzle ke Supabase dan menghasilkan kode pendek unik (e.g., `SDK-7X9A`).
- **Challenge Resolver:** Halaman untuk memasukkan Room Code dari teman guna mengunduh dan memainkan puzzle tersebut.
- **Cloud Progress & Preferences Sync:**
  - Membuat tabel `user_profiles`, `game_progress`, dan `settings` di Supabase.
  - Sinkronisasi otomatis (Sync Engine) data lokal (Hive) ke Cloud saat perangkat terhubung ke internet, sehingga pemain tidak kehilangan data saat berganti device.

---

## Out-of-Scope (TIDAK Dibuat di Versi Awal)
- Sistem multiplayer real-time (PVP langsung di waktu yang sama).
- Leaderboard global real-time.
- Sistem monetisasi, iklan, atau In-App Purchases (Semua fitur gratis untuk MVP).
- Fitur chat/pesan antar pemain di dalam aplikasi.