import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'post_form_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Post? _post;
  bool _loading = true;
  String? _error;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final post = await ApiService.getPostById(widget.postId);
      setState(() {
        _post = post;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Artikel?'),
        content: const Text(
            'Artikel akan dihapus (soft delete). Anda bisa me-restore-nya nanti.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ApiService.deletePost(widget.postId);
      if (!mounted) return;
      _snack('Artikel berhasil dihapus', AppColors.danger);
      _changed = true;
      _loadDetail();
    } catch (e) {
      _snack('Gagal: $e', AppColors.danger);
    }
  }

  Future<void> _restorePost() async {
    try {
      await ApiService.restorePost(widget.postId);
      if (!mounted) return;
      _snack('Artikel berhasil di-restore', AppColors.success);
      _changed = true;
      _loadDetail();
    } catch (e) {
      _snack('Gagal: $e', AppColors.danger);
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _changed);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: const Text('Detail Artikel'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            if (_post != null && !_post!.isDeleted)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostFormScreen(post: _post),
                    ),
                  );
                  if (updated == true) {
                    _changed = true;
                    _loadDetail();
                  }
                },
              ),
            if (_post != null && !_post!.isDeleted)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Hapus',
                onPressed: _deletePost,
              ),
            if (_post != null && _post!.isDeleted)
              IconButton(
                icon: const Icon(Icons.restore),
                tooltip: 'Restore',
                onPressed: _restorePost,
              ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.danger),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDetail,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_post == null) return const SizedBox();
    final post = _post!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.isDeleted)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.warning_amber_rounded,
                      color: AppColors.danger, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Artikel ini telah dihapus. Klik tombol restore di kanan atas untuk mengembalikan.',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Kategori badge
          if (post.categoryName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                post.categoryName!.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          const SizedBox(height: 14),

          // Judul
          Text(
            post.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.3,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Meta: tanggal
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                _formatTanggal(post.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Divider tebal
          Container(
            height: 3,
            width: 50,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Konten
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTanggal(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso);
      final bulan = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}