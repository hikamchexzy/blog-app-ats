import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';
import '../theme/app_theme.dart';
import 'post_detail_screen.dart';
import 'post_form_screen.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  List<Post> _posts = [];
  List<Category> _categories = [];
  bool _loading = true;
  String? _error;
  String? _filterStatus;
  int? _filterCategoryId;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await ApiService.getCategories(status: 'active');
      if (mounted) setState(() => _categories = cats);
    } catch (_) {}
  }

  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      List<Post> posts = await ApiService.getPosts(status: _filterStatus);
      if (_filterCategoryId != null) {
        posts = posts.where((p) => p.categoryId == _filterCategoryId).toList();
      }
      setState(() {
        _posts = posts;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openDetail(Post post) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.id)),
    );
    if (changed == true) _loadPosts();
  }

  Future<void> _openCreateForm() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PostFormScreen()),
    );
    if (created == true) _loadPosts();
  }

  Future<void> _showOptions(Post post) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            children: [
              // Header kecil
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  post.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.open_in_new, color: AppColors.primary),
                title: const Text('Buka Detail'),
                onTap: () {
                  Navigator.pop(context);
                  _openDetail(post);
                },
              ),
              if (!post.isDeleted)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.danger),
                  title: const Text('Hapus Artikel',
                      style: TextStyle(color: AppColors.danger)),
                  onTap: () async {
                    Navigator.pop(context);
                    await _confirmDelete(post);
                  },
                ),
              if (post.isDeleted)
                ListTile(
                  leading: const Icon(Icons.restore, color: AppColors.success),
                  title: const Text('Restore Artikel',
                      style: TextStyle(color: AppColors.success)),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      await ApiService.restorePost(post.id);
                      if (!mounted) return;
                      _showSnack('Artikel berhasil di-restore', AppColors.success);
                      _loadPosts();
                    } catch (e) {
                      _showSnack('Gagal: $e', AppColors.danger);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Post post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Artikel?'),
        content: Text(
            'Artikel "${post.title}" akan dihapus (soft delete). Bisa di-restore nanti.'),
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

    if (confirm == true) {
      try {
        await ApiService.deletePost(post.id);
        if (!mounted) return;
        _showSnack('Artikel berhasil dihapus', AppColors.danger);
        _loadPosts();
      } catch (e) {
        _showSnack('Gagal: $e', AppColors.danger);
      }
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Blog App'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Chip filter status
                Row(
                  children: [
                    _statusChip('Semua', null),
                    const SizedBox(width: 8),
                    _statusChip('Aktif', 'active'),
                    const SizedBox(width: 8),
                    _statusChip('Terhapus', 'delete'),
                  ],
                ),
                const SizedBox(height: 10),
                // Dropdown kategori
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<int?>(
                    value: _filterCategoryId,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.primary),
                    hint: const Text('Semua Kategori',
                        style: TextStyle(fontSize: 14)),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Semua Kategori'),
                      ),
                      ..._categories.map((c) {
                        return DropdownMenuItem<int?>(
                          value: c.id,
                          child: Text(c.name),
                        );
                      }),
                    ],
                    onChanged: (v) {
                      setState(() => _filterCategoryId = v);
                      _loadPosts();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateForm,
        icon: const Icon(Icons.add),
        label: const Text('Tulis'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _statusChip(String label, String? value) {
    final selected = _filterStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() => _filterStatus = value);
        _loadPosts();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline,
                    color: AppColors.danger, size: 42),
              ),
              const SizedBox(height: 16),
              const Text(
                'Terjadi Kesalahan',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadPosts,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.article_outlined,
                  size: 56, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Artikel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Klik tombol Tulis untuk membuat',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadPosts,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 100),
        itemCount: _posts.length,
        itemBuilder: (context, i) {
          return PostCard(
            post: _posts[i],
            onTap: () => _openDetail(_posts[i]),
            onLongPress: () => _showOptions(_posts[i]),
          );
        },
      ),
    );
  }
}