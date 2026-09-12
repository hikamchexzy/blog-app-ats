import { Request, Response } from "express";
import { db } from "../config/db";
import { postsTable, categoriesTable } from "../config/schema";
import { eq, desc, and } from "drizzle-orm";

// GET semua artikel
// Query opsional: ?status=active | ?status=delete | (kosong = semua)
export const getPosts = async (req: Request, res: Response) => {
  try {
    const statusQuery = req.query.status as string | undefined;

    const baseQuery = db
      .select({
        id: postsTable.id,
        title: postsTable.title,
        content: postsTable.content,
        categoryId: postsTable.categoryId,
        categoryName: categoriesTable.name,
        status: postsTable.status,
        createdAt: postsTable.createdAt,
        updatedAt: postsTable.updatedAt,
      })
      .from(postsTable)
      .leftJoin(categoriesTable, eq(postsTable.categoryId, categoriesTable.id));

    // Filter berdasarkan query param (kalau ada)
    let posts;
    if (statusQuery === "active" || statusQuery === "delete") {
      posts = await baseQuery
        .where(eq(postsTable.status, statusQuery))
        .orderBy(desc(postsTable.createdAt));
    } else {
      posts = await baseQuery.orderBy(desc(postsTable.createdAt));
    }

    res.status(200).json(posts);
  } catch (error) {
    console.error("❌ Error getPosts:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// GET detail artikel by ID (termasuk yang sudah dihapus)
export const getPostById = async (req: Request, res: Response) => {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({ error: "ID harus berupa angka positif" });
    }

    const [post] = await db
      .select({
        id: postsTable.id,
        title: postsTable.title,
        content: postsTable.content,
        categoryId: postsTable.categoryId,
        categoryName: categoriesTable.name,
        status: postsTable.status,
        createdAt: postsTable.createdAt,
        updatedAt: postsTable.updatedAt,
      })
      .from(postsTable)
      .leftJoin(categoriesTable, eq(postsTable.categoryId, categoriesTable.id))
      .where(eq(postsTable.id, id));

    if (!post) {
      return res.status(404).json({ error: "Artikel tidak ditemukan" });
    }

    res.status(200).json(post);
  } catch (error) {
    console.error("❌ Error getPostById:", error);
    res.status(500).json({
      error: "Internal server error",
      detail: error instanceof Error ? error.message : error,
    });
  }
};

// POST buat artikel baru
export const createPost = async (req: Request, res: Response) => {
  try {
    const { title, content, categoryId } = req.body;

    if (!title || !content) {
      return res.status(400).json({ error: "Judul dan konten wajib diisi" });
    }

    const [newPost] = await db
      .insert(postsTable)
      .values({ title, content, categoryId: categoryId || null })
      .$returningId();

    const result = await db
      .select()
      .from(postsTable)
      .where(eq(postsTable.id, newPost.id));

    res.status(201).json(result[0]);
  } catch (error) {
    console.error("❌ Error createPost:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// PUT update artikel
export const updatePost = async (req: Request, res: Response) => {
  try {
    const id = Number(req.params.id);
    const { title, content, categoryId } = req.body;

    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({ error: "ID harus berupa angka positif" });
    }

    await db
      .update(postsTable)
      .set({
        title,
        content,
        categoryId: categoryId || null,
        updatedAt: new Date(),
      })
      .where(eq(postsTable.id, id));

    const [updatedPost] = await db
      .select()
      .from(postsTable)
      .where(eq(postsTable.id, id));

    if (!updatedPost) {
      return res.status(404).json({ error: "Artikel tidak ditemukan" });
    }

    res.status(200).json(updatedPost);
  } catch (error) {
    console.error("❌ Error updatePost:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// DELETE artikel (SOFT DELETE - hanya ubah status)
export const deletePost = async (req: Request, res: Response) => {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({ error: "ID harus berupa angka positif" });
    }

    // Cek dulu apakah ada
    const [existing] = await db
      .select()
      .from(postsTable)
      .where(eq(postsTable.id, id));

    if (!existing) {
      return res.status(404).json({ error: "Artikel tidak ditemukan" });
    }

    // Ubah status jadi 'delete', BUKAN hapus baris
    await db
      .update(postsTable)
      .set({ status: "delete", updatedAt: new Date() })
      .where(eq(postsTable.id, id));

    res.status(200).json({ message: "Artikel berhasil dihapus (soft delete)" });
  } catch (error) {
    console.error("❌ Error deletePost:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// BONUS: Restore artikel yang sudah dihapus
export const restorePost = async (req: Request, res: Response) => {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({ error: "ID harus berupa angka positif" });
    }

    await db
      .update(postsTable)
      .set({ status: "active", updatedAt: new Date() })
      .where(eq(postsTable.id, id));

    const [restored] = await db
      .select()
      .from(postsTable)
      .where(eq(postsTable.id, id));

    if (!restored) {
      return res.status(404).json({ error: "Artikel tidak ditemukan" });
    }

    res.status(200).json({ message: "Artikel berhasil di-restore", data: restored });
  } catch (error) {
    console.error("❌ Error restorePost:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};