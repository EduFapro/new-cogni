# Segundo Cogni

Desktop cognitive evaluation app built with **Flutter + Fluent UI + Sqflite FFI**.

This repository includes:

✔ Local encrypted SQLite database  
✔ Deterministic AES encryption for evaluator & participant data  
✔ Automatic fake seed generator for dev  
✔ Modular domain-driven feature structure  
✔ Desktop-optimized UI with FluentUI

---

## 🚀 Getting Started

### 1. Install Flutter
This project uses **Flutter 3.24+**.

Check your version:

flutter --version


### 2. Install dependencies

flutter pub get


### 3. Initialize the local database (required for desktop apps)

No extra setup — sqflite FFI initializes automatically at app launch.

---

## 🧪 Fake Seed Generator (for local testing)

You can generate **encrypted fake data** and apply it to your local Sqflite database.

### 🔥 One-step seed command
dart run tool/run_fake_seed.dart


This will:

1. Generate encrypted SQL
2. Apply it to your local database
3. Print generated evaluator credentials

### Generated files (ignored by Git)

lib/fake_prod_seed_encrypted.sql
lib/evaluator_credentials.txt


---

## 📁 Project Structure

lib/
core/
constants/
database/
logger/
theme/
router.dart
features/
evaluator/
participant/
evaluation/
task/
shared/
encryption/
seeders/
tool/
run_fake_seed.dart


---

## 🛠 Development Notes

- Encryption uses AES-256 CBC with deterministic IV for reproducible seeding.
- Real production SHOULD replace deterministic IV with random IV.
- Logging automatically switches between CLI and Flutter logger.

---

## 📄 License

MIT License.
