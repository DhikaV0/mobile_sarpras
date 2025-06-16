// pages/item_list_page.dart
import 'package:flutter/material.dart';
import 'package:mobile_sarpras/models/item_model.dart';
import 'package:mobile_sarpras/services/api_service.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  final ApiService _api = ApiService();
  List<Item> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    final items = await _api.getItems();
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) return const Center(child: Text("Tidak ada data barang."));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: item.foto.isNotEmpty
                ? Image.network(
                    'http://127.0.0.1:8000/storage/${item.foto}',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image_not_supported),
            title: Text(item.name),
            subtitle: Text('Stok: ${item.stok} | Kategori: ${item.categoryId}'),
          ),
        );
      },
    );
  }
}
