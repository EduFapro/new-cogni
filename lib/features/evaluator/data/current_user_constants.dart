const scriptCreateTableCurrentUser = '''
CREATE TABLE current_user (
  evaluator_id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  surname TEXT NOT NULL,
  email TEXT NOT NULL,
  birth_date TEXT,
  specialty TEXT,
  cpf_or_nif TEXT,
  username TEXT,
  password TEXT,
  first_login INTEGER NOT NULL DEFAULT 1,
  is_admin INTEGER NOT NULL DEFAULT 0
)
''';
