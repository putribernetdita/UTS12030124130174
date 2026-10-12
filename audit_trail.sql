-- ============================================================
-- SOAL 3.2 : Audit Trail & Immutability
-- ============================================================

-- 1) Tambahkan kolom audit ke journal_headers
ALTER TABLE journal_headers
    ADD COLUMN IF NOT EXISTS created_by VARCHAR(50),
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN IF NOT EXISTS hash_checksum VARCHAR(64);

-- 2) Function: cegah UPDATE dan DELETE jika status POSTED
CREATE OR REPLACE FUNCTION prevent_posted_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Cegah update jika status LAMA = POSTED
    IF TG_OP = 'UPDATE' AND OLD.status_posting = 'POSTED' THEN
        RAISE EXCEPTION 
            'Jurnal dengan header_id % sudah POSTED. '
            'Tidak boleh diubah. Gunakan jurnal pembalik (reversing entry).',
            OLD.header_id;
    END IF;

    -- Cegah delete jika status = POSTED
    IF TG_OP = 'DELETE' AND OLD.status_posting = 'POSTED' THEN
        RAISE EXCEPTION 
            'Jurnal dengan header_id % sudah POSTED. '
            'Tidak boleh dihapus. Gunakan jurnal pembalik (reversing entry).',
            OLD.header_id;
    END IF;

    -- Update hash_checksum saat status berubah menjadi POSTED
    IF TG_OP = 'UPDATE' AND NEW.status_posting = 'POSTED' AND OLD.status_posting != 'POSTED' THEN
        NEW.hash_checksum := encode(
            digest(
                NEW.header_id::text || 
                NEW.trx_date::text || 
                NEW.reference_no || 
                COALESCE(NEW.description, '') ||
                COALESCE(NEW.created_by, '') ||
                NEW.created_at::text,
                'sha256'
            ),
            'hex'
        );
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3) Pasang trigger
DROP TRIGGER IF EXISTS trg_prevent_posted_update ON journal_headers;
CREATE TRIGGER trg_prevent_posted_update
BEFORE UPDATE OR DELETE ON journal_headers
FOR EACH ROW EXECUTE FUNCTION prevent_posted_change();