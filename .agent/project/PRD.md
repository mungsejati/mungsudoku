# Product Requirement Document (PRD) - Custom & Social Sudoku

## 1. Project Overview
Project ini bertujuan untuk membangun game Sudoku modern dan fleksibel berbasis Flutter. Berbeda dengan Sudoku konvensional, game ini berfokus pada fitur "Creator & Challenge" (User-Generated Content) di mana pemain dapat merancang teka-teki mereka sendiri dan membagikannya ke orang lain melalui sistem kode kamar (Room Code). Selain itu, game ini mendukung kustomisasi grid visual (ukuran sub-grid bervariasi) serta modul pengganti simbol (angka, huruf, angka romawi, warna).

## 2. Target Audiens & Core Value
- **Target Audiens:** Pencinta teka-teki kasual hingga tingkat lanjut, anak-anak (melalui mode simbol warna/grid kecil), serta komunitas kompetitif.
- **Core Value:** Kustomisasi tanpa batas (mekanik dan visual) serta aspek sosial yang mudah digunakan tanpa hambatan pendaftaran yang rumit.

## 3. Tech Stack & Architecture Baseline
- **Frontend Framework:** Flutter (Stable)
- **State Management:** Riverpod (sesuai spesifikasi `antigravity-ai-kit-for-flutter`)
- **Architecture Pattern:** Feature-First Clean Architecture (Presentation, Domain, Data)
- **Backend & Database:** Supabase (Auth, PostgreSQL untuk penyimpanan data puzzle/room, dan Edge Functions jika diperlukan)
- **Local Storage:** Hydrated State / Hive untuk menyimpan progres offline dan skin terpilih.
- **Local Storage (Auto-Save):** Menggunakan `Hydrated State` (Riverpod) atau `Hive` untuk menyimpan state permainan secara real-time. Jika aplikasi tertutup, game akan otomatis me-load board terakhir saat dibuka kembali.
- **Data Persistence Strategy:** Local-First with Cloud-Sync. Data progress dan preferences disimpan secara lokal di Phase 1 menggunakan Hive/Hydrated State, dan dirancang agar mudah disinkronisasikan ke Supabase pada Phase 3.

## 4. User Flow Utama
1. **Mode Bermain (Play Mode):** Player memilih ukuran sub-grid -> Memilih tipe simbol -> Memilih tingkat kesulitan -> Bermain.
2. **Mode Pembuat (Creator Mode):** Player memilih ukuran sub-grid -> Mengisi angka/simbol awal pada board kosong -> Sistem memvalidasi kelayakan puzzle -> Player menyimpan -> Sistem memunculkan **Room Code** untuk dibagikan.
3. **Mode Tantangan (Challenge Mode):** Player memasukkan Room Code yang didapat dari temannya -> Game mengunduh data teka-teki dari Supabase -> Player mulai menyelesaikan tantangan tersebut.

## 5. Menu & Navigation Structure
Aplikasi menggunakan sistem navigasi berbasis halaman (Page-based routing) dengan struktur menu berikut:
- **Main Menu (Home Screen):**
  - Tombol "Play Classic" -> Mengarah ke Game Screen (Phase 1)
  - Tombol "Custom & Creator Mode" -> Mengarah ke Menu Kustomisasi & Pembuat Puzzle (Phase 2 & 3)
  - Tombol "Enter Challenge Code" -> Membuka dialog/halaman untuk memasukkan Room Code (Phase 3)
  - Tombol "Settings" -> Mengatur suara, skin/tema, dan reset data lokal.
- **Game Screen:** Layout utama tempat bermain Sudoku, dilengkapi dengan tombol Pause yang akan memunculkan overlay menu (Resume, Restart, Main Menu).