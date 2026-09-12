import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';
import 'post_detail_screen.dart';
import 'post_form_screen.dart';

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
  }

  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final posts = await ApiService.getPosts(status: _filterStatus);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Artikel'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _filterChip('Semua', null),
                const SizedBox(width: 8),
                _filterChip('Aktif', 'active'),
                const SizedBox(width: 8),
                _filterChip('Terhapus', 'delete'),
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
          );
        },
      ),
    );
  }
}