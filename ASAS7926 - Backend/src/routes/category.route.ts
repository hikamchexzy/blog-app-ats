import { Router } from "express";
import {
  getCategories,
  createCategory,
  deleteCategory,
  restoreCategory,   // <-- tambah
} from "../controllers/category.controller";

const router = Router();

router.get("/", getCategories);
router.post("/", createCategory);
router.delete("/:id", deleteCategory);
router.put("/:id/restore", restoreCategory);   // <-- tambah

export default router;  