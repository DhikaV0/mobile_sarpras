import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_sarpras/services/api_service.dart';
import 'package:mobile_sarpras/models/item_model.dart';

class PeminjamanPage extends StatefulWidget {
  const PeminjamanPage({super.key});

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  DateTime _tanggalPinjam = DateTime.now();
  int? _selectedItemId;
  bool _loading = true;

  final ApiService _api = ApiService();
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final items = await _api.getItems();
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _selectedItemId == null) return;

    final selectedItem = _items.firstWhere(
      (item) => item.id == _selectedItemId,
      orElse: () => Item(id: 0, name: 'unknown', stok: 0, categoryId: '-', foto: ''),
    );

    final jumlah = int.parse(_jumlahController.text);
    final stok = selectedItem.stok;

    if (jumlah > stok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stok tidak mencukupi')),
      );
      return;
    }

    final success = await _api.ajukanPeminjaman(
      itemId: _selectedItemId!,
      jumlah: jumlah,
      tanggal: DateFormat('yyyy-MM-dd').format(_tanggalPinjam),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Peminjaman berhasil diajukan')),
      );
      _formKey.currentState!.reset();
      _jumlahController.clear();
      setState(() => _selectedItemId = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengajukan peminjaman')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return const Center(child: Text('Tidak ada barang tersedia.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Barang'),
            DropdownButtonFormField<int>(
              value: _selectedItemId,
              hint: const Text('Pilih item'),
              items: _items.map<DropdownMenuItem<int>>((item) {
                return DropdownMenuItem(
                  value: item.id,
                  child: Text('${item.name} (stok: ${item.stok})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedItemId = value);
              },
              validator: (value) =>
                  value == null ? 'Silakan pilih barang' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah Pinjam'),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Wajib diisi';
                final jumlah = int.tryParse(value);
                if (jumlah == null || jumlah <= 0) {
                  return 'Harus lebih dari 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Tanggal Pinjam: '),
                Text(DateFormat('dd MMM yyyy').format(_tanggalPinjam)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _tanggalPinjam,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _tanggalPinjam = picked);
                    }
                  },
                  child: const Text('Pilih Tanggal'),
                )
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Ajukan Peminjaman'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
