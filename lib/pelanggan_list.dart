import 'package:flutter/material.dart';
import 'api_service.dart';

class PelangganList extends StatefulWidget {
  @override
  _PelangganListState createState() => _PelangganListState();
}

class _PelangganListState extends State<PelangganList> {
  List<dynamic> _pelangganList = [];
  bool _isLoading = true;

  final Color bgColor = Color(0xFF041033);
  final Color cardColor = Color(0xFF13224F);
  final Color accentOrange = Color(0xFFFF6D00);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getPelanggan();
      setState(() {
        _pelangganList = data;
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
              // --- Header ---
              Text(
                'Daftar Pelanggan',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),

              // --- List Content ---
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: accentOrange))
                    : _pelangganList.isEmpty
                        ? Center(child: Text("Belum ada data pelanggan", style: TextStyle(color: Colors.white54)))
                        : ListView.builder(
                            itemCount: _pelangganList.length,
                            itemBuilder: (context, index) {
                              final item = _pelangganList[index];

                              return Container(
                                margin: EdgeInsets.only(bottom: 15),
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person, color: Colors.white, size: 28),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Text(
                                        item['nama'] ?? 'Unknown',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
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