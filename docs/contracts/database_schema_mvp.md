# Database Schema - MVP Demo

## Overview

Schema ini ditujukan untuk MVP Demo sesuai PRD.

Target:

- Cepat dikembangkan
- Mudah dipahami
- Tidak overengineering
- Cocok untuk Flutter + NestJS + PostgreSQL
- Mendukung seluruh screen MVP

---

# Tables

## users

Digunakan untuk login dan identitas pengguna.

| Field      | Type         | Notes        |
| ---------- | ------------ | ------------ |
| id         | uuid         | PK           |
| name       | varchar(100) |              |
| username   | varchar(50)  | unique       |
| email      | varchar(150) | nullable     |
| password   | varchar(255) | hashed       |
| role       | enum         | ADMIN, STAFF |
| is_active  | boolean      |              |
| created_at | timestamp    |              |
| updated_at | timestamp    |              |

---

## categories

Kategori obat.

| Field       | Type         |
| ----------- | ------------ |
| id          | uuid         |
| name        | varchar(100) |
| description | text         |
| is_active   | boolean      |
| created_at  | timestamp    |
| updated_at  | timestamp    |

---

## suppliers

Supplier obat.

| Field      | Type         |
| ---------- | ------------ |
| id         | uuid         |
| name       | varchar(150) |
| phone      | varchar(30)  |
| email      | varchar(150) |
| address    | text         |
| notes      | text         |
| is_active  | boolean      |
| created_at | timestamp    |
| updated_at | timestamp    |

---

## medicines

Master obat.

| Field          | Type          |
| -------------- | ------------- |
| id             | uuid          |
| code           | varchar(50)   |
| name           | varchar(150)  |
| category_id    | uuid FK       |
| supplier_id    | uuid FK       |
| unit           | varchar(50)   |
| purchase_price | decimal(12,2) |
| selling_price  | decimal(12,2) |
| current_stock  | integer       |
| minimum_stock  | integer       |
| expired_date   | date          |
| description    | text          |
| is_active      | boolean       |
| created_at     | timestamp     |
| updated_at     | timestamp     |

---

## stock_movements

Riwayat seluruh mutasi stok.

Tipe:

```txt
IN
OUT
```

Reason:

```txt
PURCHASE
SALE
DAMAGED
EXPIRED
LOST
ADJUSTMENT
OTHER
```

| Field            | Type             |
| ---------------- | ---------------- |
| id               | uuid             |
| medicine_id      | uuid FK          |
| user_id          | uuid FK          |
| supplier_id      | uuid FK nullable |
| type             | enum             |
| reason           | enum             |
| quantity         | integer          |
| stock_before     | integer          |
| stock_after      | integer          |
| transaction_date | date             |
| notes            | text             |
| created_at       | timestamp        |
| updated_at       | timestamp        |

---

## medicine_batches

Satu lot fisik obat dengan nomor batch dan tanggal kedaluwarsa tersendiri. Dibuat hanya melalui stok masuk.

| Field        | Type         | Notes                              |
| ------------ | ------------ | ---------------------------------- |
| id           | uuid         | PK                                 |
| medicine_id  | uuid FK      | → medicines.id (ON DELETE CASCADE) |
| batch_number | varchar(100) |                                    |
| expired_date | date         |                                    |
| quantity     | integer      | ≥ 0                                |
| created_at   | timestamp    | tiebreak FEFO                      |
| updated_at   | timestamp    |                                    |

**Unique constraint**: `(medicine_id, batch_number, expired_date)` — mendukung upsert saat stok masuk duplikat.

**Index**: `(medicine_id, expired_date)` — mendukung urutan FEFO.

**Relasi**: setiap record `medicine_batches` terhubung ke tepat satu record `medicines` melalui `medicine_id`. Jika record `medicines` dihapus, seluruh batch terkait ikut dihapus (cascade).

---

# ERD Summary

users
└── stock_movements

categories
└── medicines

suppliers
├── medicines
└── stock_movements

medicines
├── stock_movements
└── medicine_batches

---

# Dashboard Query Source

## Total Obat

medicines

## Total Supplier

suppliers

## Total Kategori

categories

## Stok Rendah

```sql
current_stock <= minimum_stock
```

## Hampir Expired

```sql
EXISTS (
  SELECT 1 FROM medicine_batches mb
  WHERE mb.medicine_id = medicines.id
    AND mb.expired_date >= CURRENT_DATE
    AND mb.expired_date <= CURRENT_DATE + 30
)
```

## Sudah Expired

```sql
EXISTS (
  SELECT 1 FROM medicine_batches mb
  WHERE mb.medicine_id = medicines.id
    AND mb.expired_date < CURRENT_DATE
)
```

---

# Included Features

✅ Login

✅ Dashboard

✅ CRUD Obat

✅ CRUD Kategori

✅ CRUD Supplier

✅ Stok Masuk

✅ Stok Keluar

✅ Riwayat Mutasi

✅ Alert Stok Rendah

✅ Alert Expired

✅ Search & Filter

✅ Batch Obat (upgrade: tabel `medicine_batches`, FEFO)

✅ Reports (upgrade: `GET /reports/stock`, `GET /reports/stock-out`)

---

# Excluded Features

❌ Purchase Order

❌ Sale Items

❌ Stock Opname

❌ Audit Log

❌ Notifications

❌ Settings

Schema MVP terdiri dari:

- users
- categories
- suppliers
- medicines
- stock_movements
- medicine_batches (ditambahkan pada upgrade MVP Layak Skripsi)
