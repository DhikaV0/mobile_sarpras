import 'package:flutter/material.dart';
import 'package:mobile_sarpras/services/api_service.dart';

class PengembalianPage extends StatefulWidget {
  const PengembalianPage({super.key});

  @override
  State<PengembalianPage> createState() => _PengembalianPageState();
}

class _PengembalianPageState extends State<PengembalianPage> {
  final ApiService _api = ApiService();
  List<dynamic> _peminjamanList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await _api.getPeminjamanSaya();
    setState(() {
      _peminjamanList = data;
      _loading = false;
    });
  }

  void _ajukanPengembalian(int id) async {
    final success = await _api.ajukanPengembalian(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengembalian berhasil diajukan')),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengajukan pengembalian')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_peminjamanList.isEmpty) {
      return const Center(child: Text('Belum ada peminjaman.'));
    }

    return ListView.builder(
      itemCount: _peminjamanList.length,
      itemBuilder: (context, index) {
        final item = _peminjamanList[index];
        final barang = item['items'];
        final status = item['status'];
        final pengembalian = item['pengembalian'];
        final sudahDiajukan = pengembalian != null &&
            pengembalian['status_pengembalian'] == 'diajukan';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(barang['name'] ?? '-'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jumlah: ${item['jumlah_pinjam']}'),
                Text('Status: $status'),
                if (sudahDiajukan)
                  const Text('Sedang menunggu persetujuan'),
              ],
            ),
            trailing: (status == 'dipinjam' && !sudahDiajukan)
                ? ElevatedButton(
                    onPressed: () => _ajukanPengembalian(item['id']),
                    child: const Text('Ajukan Kembali'),
                  )
                : null,
          ),
        );
      },
    );
  }
}
