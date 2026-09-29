import 'package:flutter/material.dart';
import 'api_service.dart';

class MotorList extends StatefulWidget {
  @override
  _MotorListState createState() => _MotorListState();
}

class _MotorListState extends State<MotorList> {
  List<dynamic> _motorList = [];
  bool _isLoading = true;
  final Color bgColor = Color(0xFF041033);
  final Color cardColor = Color(0xFF13224F);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getServis();
      setState(() {
        _motorList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error: $e");
    }
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
              Text(
                'Daftar Motor',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.orange))
                    : _motorList.isEmpty
                        ? Center(child: Text("Belum ada data motor/servis", style: TextStyle(color: Colors.white54)))
                        : ListView.builder(
                            itemCount: _motorList.length,
                            itemBuilder: (context, index) {
                              final item = _motorList[index];
                              
                              // PARSING DATA DENGAN FORMAT BARU (Motor | Keluhan | Sparepart)
                              String rawKeluhan = item['keluhan'] ?? '';
                              List<String> parts = rawKeluhan.split(' | ');
                              
                              String motorName = 'Motor Tidak Diketahui';
                              String keluhanDetail = 'Tidak ada keluhan spesifik';
                              String sparepartInfo = 'Tidak ada';

                              if (parts.length >= 3) {
                                motorName = parts[0];
                                keluhanDetail = parts[1];
                                sparepartInfo = parts[2];
                              } else if (rawKeluhan.contains(' - Sparepart: ')) {
                                // Kompatibilitas dengan data percobaan lama abang sebelumnya
                                List<String> oldParts = rawKeluhan.split(' - Sparepart: ');
                                motorName = oldParts.isNotEmpty ? oldParts[0] : 'Motor Tidak Diketahui';
                                sparepartInfo = oldParts.length > 1 ? oldParts[1] : 'Tidak ada';
                                keluhanDetail = "Pengecekan rutin dan servis ringan";
                              } else {
                                keluhanDetail = rawKeluhan;
                              }

                              return Container(
                                margin: EdgeInsets.only(bottom: 20),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(Icons.two_wheeler, size: 45, color: Colors.grey[400]),
                                        ),
                                        SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                motorName,
                                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                item['nama_pelanggan'] ?? 'Unknown',
                                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Text("Keluhan:", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 4),
                                    Text(keluhanDetail, style: TextStyle(color: Colors.white70, fontSize: 14)),
                                    SizedBox(height: 15),
                                    Text("Sparepart:", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 4),
                                    Text("- $sparepartInfo", style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
              
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.undo, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 28),
                    SizedBox(width: 40), 
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}