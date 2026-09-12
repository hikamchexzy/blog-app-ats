import express from "express";
import dotenv from "dotenv";
import categoryRoutes from "./routes/category.route";
import postRoutes from "./routes/post.route";
import cors from "cors";

// 1. Konfigurasi environment
dotenv.config();

// 2. Buat instance express
const app = express();
const PORT = process.env.PORT || 4000;

// 3. Pasang middleware (SETELAH app dibuat)
app.use(cors({origin: "*"})); // Mengizinkan semua origin 
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 4. Routes
app.use("/api/categories", categoryRoutes);
app.use("/api/posts", postRoutes);

// 5. Root endpoint
app.get("/", (req, res) => {
  res.send("Blog API is running!");
});

// 6. Jalankan server
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});