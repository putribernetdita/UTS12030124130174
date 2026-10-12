# Soal 3.2 — Audit Trail & Immutability

## A. Mekanisme Lock Transaksi POSTED

Transaksi dengan `status_posting = 'POSTED'` dikunci permanen melalui 
trigger PostgreSQL `prevent_posted_change()`:

1. **UPDATE diblokir** — percobaan update pada baris POSTED → RAISE EXCEPTION
2. **DELETE diblokir** — percobaan hapus → RAISE EXCEPTION
3. **Perubahan hanya via reversing entry** — buat header baru dengan 
   arah debit/kredit terbalik

## B. Reversing Entry (Storno)

Contoh jurnal asli (header_id = 1):
- Debit Kas 1.000.000
- Kredit Modal 1.000.000

Jika salah, buat jurnal pembalik (header_id = 2):
- Debit Modal 1.000.000
- Kredit Kas 1.000.000
- Deskripsi: "Reversal dari JV-001"

Header lama tetap ada → audit trail utuh.

## C. Field Audit

| Field | Fungsi |
|---|---|
| `created_by` | Siapa pembuat jurnal |
| `created_at` | Kapan dibuat (auto timestamp) |
| `hash_checksum` | Sidik jari digital (SHA-256) |

## D. Hash Checksum

`hash_checksum` = SHA-256 dari gabungan:
header_id + trx_date + reference_no + description + created_by + created_at

Manfaat:
- Jika isi diubah diam-diam di database → hash tidak cocok → terdeteksi
- Auditor bisa re-hash dan bandingkan

### Verifikasi
```sql
SELECT 
    header_id,
    hash_checksum,
    encode(digest(
        header_id::text || trx_date::text || reference_no || 
        COALESCE(description,'') || COALESCE(created_by,'') || 
        created_at::text, 'sha256'
    ), 'hex') AS hash_recomputed
FROM journal_headers
WHERE status_posting = 'POSTED';