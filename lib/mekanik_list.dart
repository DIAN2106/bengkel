import 'package:flutter/material.dart';
import 'api_service.dart';
import 'mekanik_form.dart';

class MekanikList extends StatefulWidget {
  @override
  _MekanikListState createState() => _MekanikListState();
}

class _MekanikListState extends State<MekanikList> {
  List<dynamic> _mekanikList = [];
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
      final data = await ApiService.getMekanik();
      setState(() {
        _mekanikList = data;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Mekanik',
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
                        MaterialPageRoute(builder: (context) => MekanikForm())
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
              SizedBox(height: 30),

              // --- List Content ---
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: accentOrange))
                    : _mekanikList.isEmpty
                        ? Center(child: Text("Belum ada data mekanik", style: TextStyle(color: Colors.white54)))
                        : ListView.builder(
                            itemCount: _mekanikList.length,
                            itemBuilder: (context, index) {
                              final item = _mekanikList[index];

                              return Container(
                                margin: EdgeInsets.only(bottom: 15),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Ikon Mekanik di kiri
                                    Icon(Icons.engineering, color: Colors.white, size: 40),
                                    SizedBox(width: 20),
                                    
                                    // Kolom teks informasi
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['nama'] ?? 'Unknown',
                                            style: TextStyle(
                                              color: Colors.white, 
                                              fontSize: 16, 
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            "${item['umur']} Tahun",
                                            style: TextStyle(color: Colors.white70, fontSize: 14),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            "Pengalaman ${item['pengalaman']}",
                                            style: TextStyle(color: Colors.white70, fontSize: 14),
                                          ),
                                        ],
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