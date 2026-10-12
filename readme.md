# UTS Coding Akuntansi — FEB Universitas Diponegoro

**Mata Kuliah:** Pemrograman / Coding  
**Dosen:** Totok Dewayanto  
**Semester:** Gasal 2026/2027  

## 👤 Identitas
- **Nama:** [Putri Bernetdita]
- **NIM:** [12030124130174]
- **Kelas:** [D]

## 📂 Struktur Repositori

### SOAL 1 — Desain Database & Double-Entry (25%)
- [ERD.png](SOAL-1/ERD.png) — Entity Relationship Diagram
- [ddl.sql](SOAL-1/ddl.sql) — DDL PostgreSQL
- [analisis.md](SOAL-1/analisis.md) — Analisis Audit Trail & 3NF
- [bukti-uji/](SOAL-1/Bukti%20Uji/) — Screenshot uji constraint

### SOAL 2 — Trigger Persediaan & Concurrency (40%)
- [trigger.sql](SOAL-2/trigger.sql) — Trigger otomasi stok
- [concurrency.md](SOAL-2/concurrency.md) — Penanganan race condition
- Screenshot uji trigger & concurrency

### SOAL 3 — Web Full-Stack & AI (35%)
- [Frontend](SOAL-3/Frontend/index.html) — Form entri jurnal
- [Backend](SOAL-3/Backend/audit_trail.sql) — Trigger lock POSTED
- [prompt_log.md](SOAL-3/prompt_log.md) — Log prompt AI
- [psak_verification.md](SOAL-3/psak_verification.md) — Verifikasi PSAK
- [audit_trail.md](SOAL-3/audit_trail.md) — Penjelasan immutability

## 🔗 Live Demo
Form entri jurnal dapat diakses di:  
[GitHub Pages URL setelah di-deploy]

## 🛠️ Tools yang Digunakan
- PostgreSQL / Supabase
- Gemini Canvas (UI form)
- NotebookLM (validasi PSAK)
- dbdiagram.io (ERD)
- Tailwind CSS
- GitHub Pages

## 📝 Cara Menjalankan

### Soal 1
Jalankan `SOAL-1/ddl.sql` di PostgreSQL atau Supabase SQL Editor.

### Soal 2
1. Buat tabel `inventory_items` dan `inventory_transactions`
2. Jalankan `SOAL-2/trigger.sql`

### Soal 3
1. Buka `SOAL-3/Frontend/index.html` di browser
2. Jalankan `SOAL-3/Backend/audit_trail.sql` di Supabase