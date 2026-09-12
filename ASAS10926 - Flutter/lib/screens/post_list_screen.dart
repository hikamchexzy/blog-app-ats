import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';
import 'post_detail_screen.dart';
import 'post_form_screen.dart';
import '../models/category.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  List<Post> _posts = [];
  bool _loading = true;
  String? _error;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadCategories();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Ambil dari API
      List<Post> posts = await ApiService.getPosts(status: _filterStatus);

      // Filter lokal berdasarkan kategori (opsional)
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

  void _changeFilter(String? status) {
    setState(() => _filterStatus = status);
    _loadPosts();
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
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: const Text('Buka Detail'),
              onTap: () {
                Navigator.pop(context);
                _openDetail(post);
              },
            ),
            if (!post.isDeleted)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Hapus Artikel (Soft Delete)'),
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Konfirmasi Hapus'),
                      content: Text(
                        'Yakin mau menghapus "${post.title}"?\n\nBisa di-restore nanti.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    try {
                      await ApiService.deletePost(post.id);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Artikel berhasil dihapus'),
                        ),
                      );
                      _loadPosts();
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                    }
                  }
                },
              ),
            if (post.isDeleted)
              ListTile(
                leading: const Icon(Icons.restore, color: Colors.green),
                title: const Text('Restore Artikel'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await ApiService.restorePost(post.id);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Artikel berhasil di-restore'),
                      ),
                    );
                    _loadPosts();
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Artikel'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                // Baris 1: Filter status
                Row(
                  children: [
                    _filterChip('Semua', null),
                    const SizedBox(width: 8),
                    _filterChip('Aktif', 'active'),
                    const SizedBox(width: 8),
                    _filterChip('Terhapus', 'delete'),
                  ],
                ),
                const SizedBox(height: 6),
                // Baris 2: Dropdown kategori
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButton<int?>(
                    value: _filterCategoryId,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text('Semua Kategori'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateForm,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _filterChip(String label, String? value) {
    final selected = _filterStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => _changeFilter(value),
      selectedColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.blue : Colors.white,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: Colors.blue.shade300,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadPosts,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_posts.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada artikel.\nKlik tombol + untuk membuat.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
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

  List<Category> _categories = [];
  int? _filterCategoryId;

  Future<void> _loadCategories() async {
    try {
      final cats = await ApiService.getCategories(status: 'active');
      setState(() => _categories = cats);
    } catch (_) {}
  }
}
