# Soal 1.3 — Analisis Audit Trail & Normalisasi 3NF

## A. Mengapa Pemisahan Header–Line Lebih Andal dari Sudut Audit Trail

### 1. Pemisahan Informasi Transaksi vs Detail Akun
Model Header–Line memisahkan **informasi tingkat transaksi** (tanggal, nomor bukti,
deskripsi, status posting) dari **informasi tingkat baris** (akun, debit, kredit).
Akibatnya:

- **Header** menjadi identitas tunggal sebuah jurnal (1 bukti = 1 header).
- **Line** menjadi rincian akun yang terlibat (≥ 2 baris per jurnal untuk double-entry).

Dari sisi audit, auditor dapat:
- Melacak **siapa, kapan, dan bukti apa** dengan cepat lewat header.
- Menelusuri **akun mana saja yang terpengaruh** lewat line.
- Menghitung **total debit = total kredit per header** secara langsung.

### 2. Kontrol Double-Entry Dapat Ditegakkan di Level Database
Dengan header sebagai pengelompok, sistem bisa memvalidasi:
- Setiap `header_id` **wajib memiliki ≥ 2 baris** (minimal satu debit dan satu kredit).
- `SUM(debit) = SUM(credit)` per `header_id`.

Validasi ini mustahil dilakukan secara bersih pada model tabel tunggal (flat),
karena tidak ada pemisah identitas transaksi.

### 3. Status Posting Terkontrol di Satu Tempat
Kolom `status_posting` hanya ada di **header**, bukan tersebar di setiap baris.
Keuntungan:
- Mengubah status DRAFT → POSTED cukup 1 UPDATE.
- Mencegah kondisi anomali "setengah posting" (sebagian baris POSTED, sebagian DRAFT).
- Memudahkan trigger immutability: jika `status_posting = 'POSTED'`, seluruh baris
  dalam header tersebut ikut terkunci.

### 4. Jejak Audit (Audit Trail) Lebih Kuat
- Setiap perubahan cukup dilacak melalui **header_id** sebagai kunci transaksi.
- Reversing entry (jurnal pembalik) cukup membuat **header baru** yang mereferensikan
  header lama → histori utuh.
- Tabel `journal_lines` **tidak perlu diubah** saat pembalikan; cukup tambah baris baru
  dengan arah debit/kredit terbalik.

### 5. Risiko Model Tabel Tunggal (Flat Journal Table)
Jika semua data (header + line) digabung dalam satu tabel:
- Data header (tanggal, referensi, deskripsi) **berulang** di setiap baris.
- **Anomali update**: mengubah deskripsi harus mengubah banyak baris → rawan tidak konsisten.
- **Anomali insert**: tidak bisa menyimpan header tanpa baris detail.
- **Anomali delete**: menghapus satu baris bisa menghilangkan informasi header.
- Sulit memvalidasi double-entry karena tidak ada konsep "kelompok transaksi".

---

## B. Mengapa Model Ini Memenuhi Bentuk Normal Ketiga (3NF)

### Syarat 3NF
Sebuah relasi berada di 3NF jika:
1. Sudah memenuhi **1NF** (tidak ada nilai multivalued / repeating group).
2. Sudah memenuhi **2NF** (tidak ada partial dependency).
3. **Tidak ada transitive dependency** — atribut non-key tidak boleh bergantung
   pada atribut non-key lainnya.

### Analisis per Tabel

#### Tabel `chart_of_accounts`
- **1NF** ✅ — setiap kolom atomik.
- **2NF** ✅ — PK tunggal (`account_id`), tidak ada partial dependency.
- **3NF** ✅ — `account_name`, `normal_balance`, `report_classification` hanya
  bergantung pada `account_id`, bukan pada `account_code`.

#### Tabel `journal_headers`
- **1NF** ✅ — kolom atomik.
- **2NF** ✅ — PK tunggal (`header_id`).
- **3NF** ✅ — `trx_date`, `reference_no`, `description`, `status_posting` hanya
  bergantung pada `header_id`.

#### Tabel `journal_lines`
- **1NF** ✅ — kolom atomik.
- **2NF** ✅ — PK tunggal (`line_id`), tidak ada partial dependency.
- **3NF** ✅ — `debit` dan `credit` bergantung penuh pada `line_id`.
  Atribut header (tanggal, deskripsi) **tidak diduplikasi** di sini, melainkan
  direferensikan lewat `header_id` (FK). Atribut akun (nama, tipe) juga tidak
  diduplikasi, melainkan lewat `account_id` (FK).

### Kesimpulan 3NF
Dengan pemisahan Header–Line:
- Tidak ada **duplikasi data header** di setiap baris jurnal.
- Tidak ada **transitive dependency** antara `line_id` → `header_id` → `trx_date`.
- Data referensi akun terpusat di `chart_of_accounts`.
- **Update anomaly, insert anomaly, dan delete anomaly dapat dihindari.**

---

## C. Perbandingan Ringkas: Header–Line vs Flat Table

| Aspek | Header–Line (3NF) | Flat Table |
|---|---|---|
| Duplikasi data header | Tidak ada | Setiap baris berulang |
| Validasi double-entry | Bisa per header | Sulit |
| Anomali update | Minimal | Rawan |
| Anomali insert | Tidak ada | Header tak bisa tanpa baris |
| Anomali delete | Terkontrol FK | Rawan kehilangan info |
| Audit trail | Kuat (grouping jelas) | Lemah (tidak ada grouping) |
| Immutability | 1 UPDATE di header | Harus update banyak baris |
| Kepatuhan 3NF | ✅ | ❌ (sering 1NF/2NF saja) |

---

## D. Kesimpulan

Pemisahan tabel `journal_headers` dan `journal_lines` adalah **praktik standar
sistem akuntansi modern** karena:

1. Menegakkan **asas double-entry** secara struktural di level database.
2. Menyediakan **audit trail** yang jelas (header = identitas transaksi).
3. Memenuhi **3NF** sehingga bebas anomali update/insert/delete.
4. Memudahkan penerapan **trigger, reversing entry, dan immutability**.
5. Menjadi fondasi yang kokoh untuk modul General Ledger yang scalable.