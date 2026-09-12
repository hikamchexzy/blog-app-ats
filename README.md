# Blog App - ATS RPL 2026/2027

Aplikasi Blog dengan Backend REST API + Flutter Web, dibuat untuk **Assessment Tengah Semester** Kompetensi Keahlian Rekayasa Perangkat Lunak, **SMK Taruna Bhakti**.

## Teknologi

| Layer | Teknologi |
|-------|-----------|
| Backend | Node.js, Express, TypeScript, Drizzle ORM |
| Database | MySQL (`db_blog_app`) |
| Frontend | Flutter Web (Dart) |

## Struktur
- `backend/` - REST API server
- `blog_app/` - Aplikasi Flutter

## Cara Menjalankan

### Backend
```bash
cd backend
npm install
cp .env.example .env   # lalu isi password MySQL
npx drizzle-kit push
npm run dev