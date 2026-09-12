import { Request, Response } from "express";
import { db } from "../config/db";
import { categoriesTable } from "../config/schema";
import { eq, desc } from "drizzle-orm";

// GET semua kategori (dengan filter opsional ?status=active|delete)
export const getCategories = async (req: Request, res: Response) => {
  try {
    const statusQuery = req.query.status as string | undefined;

    let categories;
    if (statusQuery === "active" || statusQuery === "delete") {
      categories = await db
        .select()
        .from(categoriesTable)
        .where(eq(categoriesTable.status, statusQuery))
        .orderBy(desc(categoriesTable.createdAt));
    } else {
      categories = await db
        .select()
        .from(categoriesTable)
        .orderBy(desc(categoriesTable.createdAt));
    }

    res.status(200).json(categories);
  } catch (error) {
    console.error("❌ Error getCategories:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// POST buat kategori baru
export const createCategory = async (req: Request, res: Response) => {
  try {
    const { name } = req.body;
    if (!name) {
      return res.status(400).json({ error: "Nama kategori wajib diisi" });
    }

    const [newCategory] = await db
      .insert(categoriesTable)
      .values({ name })
      .$returningId();

    const result = await db
      .select()
      .from(categoriesTable)
      .where(eq(categoriesTable.id, newCategory.id));

    res.status(201).json(result[0]);
  } catch (error) {
    console.error("❌ Error createCategory:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// DELETE kategori (SOFT DELETE)
export const deleteCategory = async (req: Request, res: Response) => {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({ error: "ID harus berupa angka positif" });
    }

    const [existing] = await db
      .select()
      .from(categoriesTable)
      .where(eq(categoriesTable.id, id));

    if (!existing) {
      return res.status(404).json({ error: "Kategori tidak ditemukan" });
    }

    await db
      .update(categoriesTable)
      .set({ status: "delete" })
      .where(eq(categoriesTable.id, id));

    res.status(200).json({ message: "Kategori berhasil dihapus (soft delete)" });
  } catch (error) {
    console.error("❌ Error deleteCategory:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// BONUS: Restore kategori
export const restoreCategory = async (req: Request, res: Response) => {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id) || id <= 0) {
      return res.status(400).json({ error: "ID harus berupa angka positif" });
    }

    await db
      .update(categoriesTable)
      .set({ status: "active" })
      .where(eq(categoriesTable.id, id));

    const [restored] = await db
      .select()
      .from(categoriesTable)
      .where(eq(categoriesTable.id, id));

    if (!restored) {
      return res.status(404).json({ error: "Kategori tidak ditemukan" });
    }

    res.status(200).json({ message: "Kategori berhasil di-restore", data: restored });
  } catch (error) {
    console.error("❌ Error restoreCategory:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};