import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'servis_form.dart';
import 'pembayaran_form.dart';

class ServisList extends StatefulWidget {
  @override
  _ServisListState createState() => _ServisListState();
}

class _ServisListState extends State<ServisList> {
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
      final data = await ApiService.getServis();
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
          final nama = item['nama_pelanggan']?.toString().toLowerCase() ?? '';
          final keluhan = item['keluhan']?.toString().toLowerCase() ?? '';
          return nama.contains(query.toLowerCase()) || keluhan.contains(query.toLowerCase());
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transaksi Servis',
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
                        MaterialPageRoute(builder: (context) => ServisForm())
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

              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari Transaksi...',
                    hintStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.search, color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              SizedBox(height: 20),

              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: accentOrange))
                    : _filteredData.isEmpty
                        ? Center(child: Text("Data tidak ditemukan", style: TextStyle(color: Colors.white54)))
                        : ListView.builder(
                            itemCount: _filteredData.length,
                            itemBuilder: (context, index) {
                              final item = _filteredData[index];
                              
                              String idFormatted = item['id_servis'].toString().padLeft(2, '0');
                              String rawKeluhan = item['keluhan'] ?? 'Tidak ada keterangan';
                              
                              String infoTambahan = rawKeluhan;
                              if (rawKeluhan.contains(' | ')) {
                                List<String> parts = rawKeluhan.split(' | ');
                                infoTambahan = "${parts[0]} - ${parts[1]}"; // Tampil Motor & Keluhan saja di list ini
                              } else if (rawKeluhan.contains(' - Sparepart: ')) {
                                infoTambahan = rawKeluhan.split(' - Sparepart: ')[0]; // Kompatibel data lama
                              }

                              return Container(
                                margin: EdgeInsets.only(bottom: 15),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          idFormatted,
                                          style: TextStyle(color: accentOrange, fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                        Icon(
                                          Icons.check, 
                                          color: item['status'] == 'Selesai' ? Colors.greenAccent : Colors.white24, 
                                          size: 28
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    
                                    Text(
                                      item['nama_pelanggan'] ?? 'Unknown',
                                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      infoTambahan,
                                      style: TextStyle(color: Colors.white70, fontSize: 14),
                                    ),
                                    
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                                      child: Divider(color: Colors.white24, thickness: 1),
                                    ),
                                    
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          formatRupiah(item['biaya_jasa']),
                                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => PembayaranForm(servisData: item))
                                                ).then((value) {
                                                  if(value == true) {
                                                    _fetchData(); 
                                                  }
                                                });
                                              },
                                              child: Icon(Icons.remove_red_eye, color: Colors.white, size: 22),
                                            ),
                                            SizedBox(width: 15),
                                            GestureDetector(
                                              onTap: () {
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mencetak struk servis $idFormatted...')));
                                              },
                                              child: Icon(Icons.print, color: Colors.white, size: 22),
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
              ),

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