-- ============================================================
-- SOAL 2.1 : Trigger Otomasi Stok & Anti-Negative Inventory
-- ============================================================

CREATE OR REPLACE FUNCTION trg_update_stock_and_journal()
RETURNS TRIGGER AS $$
DECLARE
    current_stock INT;
BEGIN
    -- ========================================================
    -- Ambil stok terkini dengan LOCK (mencegah race condition)
    -- ========================================================
    SELECT stock_qty
    INTO current_stock
    FROM inventory_items
    WHERE item_id = NEW.item_id
    FOR UPDATE;

    -- Validasi item harus ada
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Item dengan ID % tidak ditemukan', NEW.item_id;
    END IF;

    -- Validasi qty harus > 0 (kecuali ADJUSTMENT boleh negatif untuk koreksi)
    IF NEW.qty <= 0 AND NEW.trx_type != 'ADJUSTMENT' THEN
        RAISE EXCEPTION 'Qty untuk % harus > 0, diberikan: %', NEW.trx_type, NEW.qty;
    END IF;

    -- ========================================================
    -- Proses sesuai jenis transaksi
    -- ========================================================
    IF NEW.trx_type = 'PURCHASE' THEN
        UPDATE inventory_items
        SET stock_qty = stock_qty + NEW.qty
        WHERE item_id = NEW.item_id;

    ELSIF NEW.trx_type = 'SALE' THEN
        -- Cek stok cukup
        IF current_stock < NEW.qty THEN
            RAISE EXCEPTION 
                'Stok tidak cukup untuk item % (%). Stok tersedia: %, diminta: %',
                NEW.item_id,
                (SELECT item_name FROM inventory_items WHERE item_id = NEW.item_id),
                current_stock,
                NEW.qty;
        END IF;

        UPDATE inventory_items
        SET stock_qty = stock_qty - NEW.qty
        WHERE item_id = NEW.item_id;

    ELSIF NEW.trx_type = 'ADJUSTMENT' THEN
        -- ADJUSTMENT bisa + atau - sesuai qty
        UPDATE inventory_items
        SET stock_qty = stock_qty + NEW.qty
        WHERE item_id = NEW.item_id;

        -- Pastikan hasil akhir tidak negatif
        IF (SELECT stock_qty FROM inventory_items WHERE item_id = NEW.item_id) < 0 THEN
            RAISE EXCEPTION 
                'ADJUSTMENT menyebabkan stok negatif untuk item %', NEW.item_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- Daftarkan Trigger (BEFORE INSERT pada inventory_transactions)
-- ============================================================
DROP TRIGGER IF EXISTS trg_update_stock_and_journal ON inventory_transactions;

CREATE TRIGGER trg_update_stock_and_journal
BEFORE INSERT ON inventory_transactions
FOR EACH ROW
EXECUTE FUNCTION trg_update_stock_and_journal();