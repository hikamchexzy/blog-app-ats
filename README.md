# Blog App - ATS RPL 2026/2027

Aplikasi Blog dengan Backend REST API + Flutter Web.

## Teknologi
- **Backend:** Node.js + Express + TypeScript + Drizzle ORM + MySQL
- **Frontend:** Flutter Web

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