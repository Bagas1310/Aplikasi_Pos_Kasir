# Google Stitch Prompts - POS Kasir UMKM (KasirKita)

## Design System
- Theme: Light mode, background `#F8FAFC`, cards `#FFFFFF`, primary `#10B981`, text `#0F172A`.

## 1. Login Screen
Mobile login screen for offline UMKM POS app "KasirKita". Light theme (`#F8FAFC` bg, `#10B981` primary, `#0F172A` text). Top: minimalist receipt/store logo, title "KasirKita", subtitle "Kelola transaksi UMKM lebih cepat & rapi". Center white card: rounded inputs "Username / ID Kasir" and "PIN / Password" (with eye icon), full-width green button "Masuk ke Kasir", bottom link "Daftar Toko Baru".

## 2. POS Catalog Screen
Mobile POS cashier catalog screen. Light theme (`#F8FAFC` bg, `#10B981` accent). Header: store name "Kedai Kopi Nusantara", cashier "Kasir: Budi", search bar "Cari menu...". Horizontal category chips: "Semua" (active green), "Minuman", "Makanan", "Snack". Main: 2-column grid of white product cards with image placeholder, title, bold price ("Rp 15.000"), stock badge ("Stok: 24"), and quantity stepper (`- 1 +`). Bottom: floating dark slate bar (`#0F172A`) showing "3 Item • Total: Rp 45.000" + green button "Bayar", above 4-tab bottom nav (Kasir, Produk, Riwayat, Laporan).

## 3. Checkout & Payment Screen
Mobile POS checkout screen, light theme (`#F8FAFC`, `#10B981`, `#0F172A`). Header: back arrow + "Detail Pembayaran". Upper white card: cart items with name, price, quantity stepper, subtotal. Middle: bold "Total Tagihan: Rp 45.000", cash input "Uang Diterima (Rp)", quick-cash chips ("Uang Pas", "Rp 50.000", "Rp 100.000"), highlighted green box "Kembalian: Rp 5.000". Bottom: full-width green button "Selesaikan Transaksi".

## 4. Product Management Screen
Mobile product inventory screen, light theme (`#F8FAFC`, `#10B981`). Header: "Kelola Produk", search bar, filter tabs ("Semua Produk", "Stok Menipis"). Vertical list of white product rows: square thumbnail, product name, category tag, price ("Rp 18.000"), stock badge (green normal, red "Stok: 3" low), edit and delete icons. Bottom-right green FAB "+ Tambah Produk".

## 5. Sales Report Screen
Mobile sales report screen, light theme (`#F8FAFC`, `#10B981`, `#0F172A`). Header: "Laporan Penjualan", date filter pill ("Hari Ini"). Two side-by-side metric cards: "Total Omzet" ("Rp 1.250.000" green) and "Total Transaksi" ("38"). Section "Riwayat Transaksi" with vertical cards showing ID ("#TRX-0038"), time ("14:25"), item count ("4 Item"), status pill ("Lunas"), and total amount.

---

## SQLite Schema (sqflite)

```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  store_name TEXT NOT NULL,
  cashier_name TEXT NOT NULL
);

CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  price INTEGER NOT NULL,
  stock INTEGER NOT NULL
);

CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  total_amount INTEGER NOT NULL,
  pay_amount INTEGER NOT NULL,
  change_amount INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE transaction_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  transaction_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  qty INTEGER NOT NULL,
  subtotal INTEGER NOT NULL,
  FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products (id)
);
```