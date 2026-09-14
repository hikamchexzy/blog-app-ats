import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class PostFormScreen extends StatefulWidget {
  final Post? post;

  const PostFormScreen({super.key, this.post});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  int? _selectedCategoryId;
  List<Category> _categories = [];
  bool _loadingCategories = true;
  bool _submitting = false;

  bool get isEditMode => widget.post != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _titleController.text = widget.post!.title;
      _contentController.text = widget.post!.content;
      _selectedCategoryId = widget.post!.categoryId;
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ApiService.getCategories(status: 'active');
      setState(() {
        _categories = categories;
        _loadingCategories = false;
      });
    } catch (e) {
      setState(() => _loadingCategories = false);
      if (!mounted) return;
      _snack('Gagal memuat kategori: $e', AppColors.danger);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      if (isEditMode) {
        await ApiService.updatePost(
          id: widget.post!.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          categoryId: _selectedCategoryId,
        );
      } else {
        await ApiService.createPost(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          categoryId: _selectedCategoryId,
        );
      }

      if (!mounted) return;
      _snack(
        isEditMode
            ? 'Artikel berhasil diperbarui'
            : 'Artikel berhasil dibuat',
        AppColors.success,
      );
      Navigator.pop(context, true);
    } catch (e) {
      _snack('Gagal: $e', AppColors.danger);
      setState(() => _submitting = false);
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Artikel' : 'Tulis Artikel'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Judul',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Masukkan judul artikel...',
                prefixIcon: Icon(Icons.title, color: AppColors.primary),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Judul wajib diisi';
                if (v.trim().length < 3) return 'Judul minimal 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 20),

            const Text(
              'Kategori',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            _loadingCategories
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    ),
                  )
                : DropdownButtonFormField<int?>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.folder_outlined,
                          color: AppColors.primary),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Tanpa kategori'),
                      ),
                      ..._categories.map((c) {
                        return DropdownMenuItem<int?>(
                          value: c.id,
                          child: Text(c.name),
                        );
                      }),
                    ],
                    onChanged: (v) => setState(() => _selectedCategoryId = v),
                  ),
            const SizedBox(height: 20),

            const Text(
              'Konten',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: 'Tulis isi artikel di sini...',
                alignLabelWithHint: true,
              ),
              maxLines: 12,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Konten wajib diisi';
                if (v.trim().length < 10) return 'Konten minimal 10 karakter';
                return null;
              },
            ),
            const SizedBox(height: 28),

            ElevatedButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(isEditMode ? Icons.save : Icons.send),
              label: Text(
                _submitting
                    ? 'Menyimpan...'
                    : (isEditMode ? 'Simpan Perubahan' : 'Publish Artikel'),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}