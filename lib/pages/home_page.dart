import 'package:flutter/material.dart';
import 'package:mobile_sarpras/services/api_service.dart';
import 'package:mobile_sarpras/models/item_model.dart';
import 'peminjaman_page.dart';
import 'pengembalian_page.dart';
import 'profile_page.dart';
import '../widgets/bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final ApiService _api = ApiService();
  List<Item> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  void _fetchItems() async {
    final items = await _api.getItems();
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Widget _buildItemList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return const Center(child: Text('Tidak ada barang tersedia.'));
    }

    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(item.name),
            subtitle: Text('Stok: ${item.stok}'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildItemList(),          // Home → Menampilkan daftar barang
      const PeminjamanPage(),
      const PengembalianPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Barang')),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
