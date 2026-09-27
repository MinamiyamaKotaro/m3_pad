// DDL文字列はSQLとしての可読性を優先するため、80文字制限の対象外とする。
// ignore_for_file: lines_longer_than_80_chars

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// アプリのSQLiteデータベースを開き、初回起動時にスキーマ
/// （[db_schema.md](../../../../../docs/requried/db_schema.md)）を適用する
/// ユーティリティ。
class AppDatabase {
  /// [AppDatabase] を生成する。
  const AppDatabase();

  /// データベースファイル名。
  static const String _fileName = 'm3_pad.db';

  /// データベースを開く。ファイルが存在しない場合はスキーマを作成する。
  Future<Database> open() async {
    final String path = p.join(await getDatabasesPath(), _fileName);
    final Database database = await openDatabase(
      path,
      version: 1,
      onCreate: (final Database db, final int version) async {
        for (final String statement in _createStatements) {
          await db.execute(statement);
        }
        for (final String statement in _seedStatements) {
          await db.execute(statement);
        }
      },
      onConfigure: (final Database db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
    return database;
  }

  static const List<String> _createStatements = <String>[
    '''
    CREATE TABLE m_sheet_template (
        sheet_template_id TEXT PRIMARY KEY,
        name        TEXT NOT NULL,
        status      TEXT NOT NULL CHECK (status IN ('active', 'deleted')) DEFAULT 'active',
        created_at  TEXT NOT NULL,
        updated_at  TEXT NOT NULL
    );
    ''',
    '''
    CREATE TABLE m_header_type (
        type_id     INTEGER PRIMARY KEY AUTOINCREMENT,
        type_name   TEXT NOT NULL UNIQUE CHECK (type_name IN ('int', 'decimal', 'string', 'date', 'boolean')),
        created_at  TEXT NOT NULL,
        updated_at  TEXT NOT NULL
    );
    ''',
    '''
    CREATE TABLE m_header (
        column_id           TEXT PRIMARY KEY,
        sheet_template_id   TEXT NOT NULL REFERENCES m_sheet_template(sheet_template_id),
        type_id             INTEGER NOT NULL REFERENCES m_header_type(type_id),
        name                TEXT NOT NULL,
        display_order       INTEGER NOT NULL,
        is_priced           INTEGER NOT NULL CHECK (is_priced IN (0, 1)) DEFAULT 0,
        status              TEXT NOT NULL CHECK (status IN ('active', 'deleted')) DEFAULT 'active',
        created_at          TEXT NOT NULL,
        updated_at          TEXT NOT NULL
    );
    ''',
    'CREATE INDEX idx_m_header_sheet_template_id ON m_header(sheet_template_id);',
    '''
    CREATE TABLE m_header_price (
        price_id        TEXT PRIMARY KEY,
        column_id       TEXT NOT NULL REFERENCES m_header(column_id),
        price           INTEGER NOT NULL,
        effective_from  TEXT NOT NULL,
        effective_to    TEXT,
        created_at      TEXT NOT NULL,
        updated_at      TEXT NOT NULL
    );
    ''',
    'CREATE INDEX idx_m_header_price_column_id ON m_header_price(column_id);',
    '''
    CREATE TABLE t_sheet_instance (
        sheet_instance_id   TEXT PRIMARY KEY,
        sheet_template_id   TEXT NOT NULL REFERENCES m_sheet_template(sheet_template_id),
        business_date       TEXT NOT NULL,
        status              TEXT NOT NULL CHECK (status IN ('active', 'deleted')) DEFAULT 'active',
        created_at          TEXT NOT NULL,
        updated_at          TEXT NOT NULL
    );
    ''',
    'CREATE INDEX idx_t_sheet_instance_template_id ON t_sheet_instance(sheet_template_id);',
    'CREATE INDEX idx_t_sheet_instance_business_date ON t_sheet_instance(business_date);',
    '''
    CREATE TABLE m_customer (
        customer_id TEXT PRIMARY KEY,
        name        TEXT NOT NULL,
        gender      TEXT NOT NULL CHECK (gender IN ('male', 'female', 'none')) DEFAULT 'none',
        status      TEXT NOT NULL CHECK (status IN ('active', 'deleted')) DEFAULT 'active',
        created_at  TEXT NOT NULL,
        updated_at  TEXT NOT NULL
    );
    ''',
    '''
    CREATE TABLE m_staff (
        staff_id    TEXT PRIMARY KEY,
        name        TEXT NOT NULL,
        staff_code  TEXT,
        status      TEXT NOT NULL CHECK (status IN ('active', 'deleted')) DEFAULT 'active',
        created_at  TEXT NOT NULL,
        updated_at  TEXT NOT NULL
    );
    ''',
    '''
    CREATE TABLE t_row (
        row_id              TEXT PRIMARY KEY,
        sheet_instance_id   TEXT NOT NULL REFERENCES t_sheet_instance(sheet_instance_id),
        customer_id         TEXT REFERENCES m_customer(customer_id),
        staff_id            TEXT REFERENCES m_staff(staff_id),
        row_order           INTEGER NOT NULL,
        total_amount        INTEGER NOT NULL DEFAULT 0,
        payment_method      TEXT CHECK (payment_method IN ('paypay', 'card')),
        status              TEXT NOT NULL CHECK (status IN ('active', 'deleted')) DEFAULT 'active',
        created_at          TEXT NOT NULL,
        updated_at          TEXT NOT NULL
    );
    ''',
    'CREATE INDEX idx_t_row_sheet_instance_id ON t_row(sheet_instance_id);',
    'CREATE INDEX idx_t_row_customer_id ON t_row(customer_id);',
    'CREATE INDEX idx_t_row_staff_id ON t_row(staff_id);',
    '''
    CREATE TABLE t_cell (
        cell_id             TEXT PRIMARY KEY,
        row_id              TEXT NOT NULL REFERENCES t_row(row_id),
        column_id           TEXT NOT NULL REFERENCES m_header(column_id),
        content             TEXT,
        quantity            INTEGER,
        unit_price_applied  INTEGER,
        amount              INTEGER,
        created_at          TEXT NOT NULL,
        updated_at          TEXT NOT NULL,
        UNIQUE (row_id, column_id)
    );
    ''',
    'CREATE INDEX idx_t_cell_row_id ON t_cell(row_id);',
    'CREATE INDEX idx_t_cell_column_id ON t_cell(column_id);',
    '''
    CREATE TABLE t_staff_shift (
        shift_id            TEXT PRIMARY KEY,
        sheet_instance_id   TEXT NOT NULL REFERENCES t_sheet_instance(sheet_instance_id),
        staff_id            TEXT REFERENCES m_staff(staff_id),
        start_time          TEXT,
        end_time            TEXT,
        drink_back          TEXT,
        status              TEXT NOT NULL CHECK (status IN ('active', 'deleted')) DEFAULT 'active',
        created_at          TEXT NOT NULL,
        updated_at          TEXT NOT NULL
    );
    ''',
    'CREATE INDEX idx_t_staff_shift_sheet_instance_id ON t_staff_shift(sheet_instance_id);',
    'CREATE INDEX idx_t_staff_shift_staff_id ON t_staff_shift(staff_id);',
    '''
    CREATE TRIGGER trg_t_cell_ai AFTER INSERT ON t_cell
    BEGIN
        UPDATE t_row SET total_amount = (
            SELECT COALESCE(SUM(amount), 0) FROM t_cell WHERE row_id = NEW.row_id
        ), updated_at = STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now')
        WHERE row_id = NEW.row_id;
    END;
    ''',
    '''
    CREATE TRIGGER trg_t_cell_au AFTER UPDATE ON t_cell
    BEGIN
        UPDATE t_row SET total_amount = (
            SELECT COALESCE(SUM(amount), 0) FROM t_cell WHERE row_id = NEW.row_id
        ), updated_at = STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now')
        WHERE row_id = NEW.row_id;
    END;
    ''',
    '''
    CREATE TRIGGER trg_t_cell_ad AFTER DELETE ON t_cell
    BEGIN
        UPDATE t_row SET total_amount = (
            SELECT COALESCE(SUM(amount), 0) FROM t_cell WHERE row_id = OLD.row_id
        ), updated_at = STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now')
        WHERE row_id = OLD.row_id;
    END;
    ''',
    '''
    CREATE VIEW v_staff_daily_sales AS
    SELECT
        st.staff_id,
        st.name        AS staff_name,
        si.business_date,
        COUNT(r.row_id)         AS customer_count,
        SUM(r.total_amount)     AS total_sales
    FROM t_row r
    JOIN t_sheet_instance si ON si.sheet_instance_id = r.sheet_instance_id
    JOIN m_staff st           ON st.staff_id = r.staff_id
    WHERE r.status = 'active'
    GROUP BY st.staff_id, si.business_date;
    ''',
    '''
    CREATE VIEW v_daily_payment_summary AS
    SELECT
        si.sheet_instance_id,
        si.business_date,
        SUM(r.total_amount) AS total_amount,
        SUM(CASE WHEN r.payment_method = 'paypay' THEN r.total_amount ELSE 0 END) AS paypay_amount,
        SUM(CASE WHEN r.payment_method = 'card'   THEN r.total_amount ELSE 0 END) AS card_amount,
        SUM(CASE WHEN r.payment_method IS NULL    THEN r.total_amount ELSE 0 END) AS cash_amount
    FROM t_row r
    JOIN t_sheet_instance si ON si.sheet_instance_id = r.sheet_instance_id
    WHERE r.status = 'active'
    GROUP BY si.sheet_instance_id, si.business_date;
    ''',
  ];

  static const List<String> _seedStatements = <String>[
    '''
    INSERT INTO m_header_type (type_name, created_at, updated_at) VALUES
        ('int', STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now'), STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now')),
        ('decimal', STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now'), STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now')),
        ('string', STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now'), STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now')),
        ('date', STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now'), STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now')),
        ('boolean', STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now'), STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'now'));
    ''',
  ];
}
