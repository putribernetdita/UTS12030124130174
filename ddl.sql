-- ============================================================
-- SOAL 1.2 : DDL PostgreSQL untuk Supabase
-- ============================================================

DROP TABLE IF EXISTS journal_lines;
DROP TABLE IF EXISTS journal_headers;
DROP TABLE IF EXISTS chart_of_accounts;

-- TABEL 1
CREATE TABLE chart_of_accounts (
    account_id              SERIAL          PRIMARY KEY,
    account_code            VARCHAR(20)     NOT NULL UNIQUE,
    account_name            VARCHAR(100)    NOT NULL,
    normal_balance          VARCHAR(10)     NOT NULL
                            CHECK (normal_balance IN ('DEBIT','CREDIT')),
    report_classification   VARCHAR(50)     NOT NULL
);

-- TABEL 2
CREATE TABLE journal_headers (
    header_id           SERIAL          PRIMARY KEY,
    trx_date            DATE            NOT NULL,
    reference_no        VARCHAR(50)     NOT NULL UNIQUE,
    description         TEXT,
    status_posting      VARCHAR(10)     NOT NULL DEFAULT 'DRAFT'
                        CHECK (status_posting IN ('DRAFT','POSTED','VOID'))
);

-- TABEL 3
CREATE TABLE journal_lines (
    line_id     SERIAL          PRIMARY KEY,
    header_id   INT             NOT NULL,
    account_id  INT             NOT NULL,
    debit       NUMERIC(15,2)   NOT NULL DEFAULT 0 CHECK (debit >= 0),
    credit      NUMERIC(15,2)   NOT NULL DEFAULT 0 CHECK (credit >= 0),

    CONSTRAINT fk_journal_lines_header
        FOREIGN KEY (header_id)
        REFERENCES journal_headers(header_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_journal_lines_account
        FOREIGN KEY (account_id)
        REFERENCES chart_of_accounts(account_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_debit_credit_not_both_zero
        CHECK (NOT (debit = 0 AND credit = 0))
);