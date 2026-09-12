import {
  mysqlTable,
  mysqlEnum,
  int,
  varchar,
  text,
  timestamp,
} from "drizzle-orm/mysql-core";

// Konstanta status (dipakai sebagai enum di MySQL)
export const STATUS_VALUES = ["active", "delete"] as const;

// 1. Tabel Categories
export const categoriesTable = mysqlTable("categories", {
  id: int("id").autoincrement().primaryKey(),
  name: varchar("name", { length: 100 }).notNull(),
  status: mysqlEnum("status", STATUS_VALUES).notNull().default("active"),
  createdAt: timestamp("created_at").defaultNow(),
});

// 2. Tabel Posts
export const postsTable = mysqlTable("posts", {
  id: int("id").autoincrement().primaryKey(),
  categoryId: int("category_id").references(() => categoriesTable.id, {
    onDelete: "set null",
    onUpdate: "cascade",
  }),
  title: varchar("title", { length: 255 }).notNull(),
  content: text("content").notNull(),
  status: mysqlEnum("status", STATUS_VALUES).notNull().default("active"),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow().onUpdateNow(),
});