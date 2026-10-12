# Soal 2.2 — Penanganan Concurrency (Race Condition)

## Masalah
Dua kasir memproses SALE untuk item sama, stok = 1, terjadi bersamaan → berpotensi
overselling / phantom stock karena proses "baca stok → cek → update" bukan operasi
atomik pada isolasi default (READ COMMITTED).

## Teknik Solusi

### 1. SELECT ... FOR UPDATE (Pessimistic Locking)
Mengunci baris yang dibaca sehingga transaksi lain harus menunggu.

```sql
BEGIN;

-- Lock baris item
SELECT stock_qty
FROM inventory_items
WHERE item_id = 'A001'
FOR UPDATE;

-- Cek stok
-- Jika < qty → ROLLBACK + error
-- Jika cukup → lanjut update

UPDATE inventory_items
SET stock_qty = stock_qty - 1
WHERE item_id = 'A001';

INSERT INTO inventory_transactions (item_id, trx_type, qty)
VALUES ('A001', 'SALE', 1);

COMMIT;