import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'sparepart_form.dart'; 

class SparepartList extends StatefulWidget {
  @override
  _SparepartListState createState() => _SparepartListState();
}

class _SparepartListState extends State<SparepartList> {
  List<dynamic> _allData = [];
  List<dynamic> _filteredData = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  final Color bgColor = Color(0xFF041033);
  final Color cardColor = Color(0xFF13224F);
  final Color accentOrange = Color(0xFFFF6D00);

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(() {
      _filterData(_searchController.text);
    });
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getSparepart();
      if (mounted) {
        setState(() {
          _allData = data;
          _filteredData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print(e);
    }
  }

  void _filterData(String query) {
    if (query.isEmpty) {
      setState(() => _filteredData = _allData);
    } else {
      setState(() {
        _filteredData = _allData.where((item) {
          final nama = item['nama_barang']?.toString().toLowerCase() ?? '';
          return nama.contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  String formatRupiah(dynamic amount) {
    if (amount == null) return "Rp0";
    final formatter = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    return formatter.format(double.parse(amount.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Data Sparepart',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => SparepartForm())
                      ).then((value) {
                        if(value == true) {
                          _fetchData();
                        }
                      });
                    },
                    child: Text('Tambah +', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // --- Search Bar ---
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari Sparepart...',
                    hintStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.search, color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // --- List Content ---
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: accentOrange))
                    : _filteredData.isEmpty
                        ? Center(child: Text("Data tidak ditemukan", style: TextStyle(color: Colors.white54)))
                        : ListView.builder(
                            itemCount: _filteredData.length,
                            itemBuilder: (context, index) {
                              final item = _filteredData[index];
                              
                              // Menyiapkan variabel untuk mengecek ketersediaan nama file foto
                              String namaFoto = item['foto']?.toString() ?? '';
                              String urlFoto = "http://192.168.18.24/bengkel_api/uploads/$namaFoto";

                              return Container(
                                margin: EdgeInsets.only(bottom: 15),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Image Box (Tampil foto asli jika ada, jika kosong/error tampil ikon)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width: 70,
                                        height: 70,
                                        color: Colors.white,
                                        child: namaFoto.isNotEmpty
                                            ? Image.network(
                                                urlFoto,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Icon(Icons.broken_image, color: Colors.grey, size: 40);
                                                },
                                              )
                                            : Icon(Icons.settings, color: Colors.grey, size: 40),
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    
                                    // Informasi Teks & Harga
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['nama_barang'] ?? 'Unknown',
                                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            formatRupiah(item['harga']),
                                            style: TextStyle(color: Colors.white70, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Indikator Stok
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(height: 30), 
                                        Text(
                                          item['stok'].toString(),
                                          style: TextStyle(
                                            color: Colors.greenAccent,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
              ),

              // --- Bottom Navigation (Back Button) ---
              Align(
                alignment: Alignment.bottomLeft,
                child: IconButton(
                  icon: Icon(Icons.undo, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}