import 'package:flutter/material.dart';
import 'api_service.dart';

class MekanikForm extends StatefulWidget {
  @override
  _MekanikFormState createState() => _MekanikFormState();
}

class _MekanikFormState extends State<MekanikForm> {
  final Color bgColor = Color(0xFF041033);
  final Color cardColor = Color(0xFF13224F);
  final Color accentOrange = Color(0xFFFF6D00);

  final _namaController = TextEditingController();
  final _umurController = TextEditingController();
  final _pengalamanController = TextEditingController();
  bool _isLoading = false;

  Future<void> _simpanData() async {
    if (_namaController.text.isEmpty || _umurController.text.isEmpty || _pengalamanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Harap isi semua kolom!')));
      return;
    }

    setState(() => _isLoading = true);

    Map<String, dynamic> data = {
      "nama": _namaController.text,
      "umur": _umurController.text,
      "pengalaman": _pengalamanController.text,
    };

    bool success = await ApiService.tambahMekanik(data);
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context, true); // Kembali jika berhasil
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan data mekanik')));
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
                'Tambah Mekanik',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),

              // --- Form Inputs ---
              _buildCustomTextField(_namaController, "Nama Mekanik...", TextInputType.text),
              SizedBox(height: 15),
              _buildCustomTextField(_umurController, "Umur...", TextInputType.number),
              SizedBox(height: 15),
              _buildCustomTextField(_pengalamanController, "Pengalaman...", TextInputType.text),
              SizedBox(height: 20),

              // --- Tombol Tambah (Rata Kanan) ---
              Align(
                alignment: Alignment.centerRight,
                child: _isLoading
                    ? CircularProgressIndicator(color: accentOrange)
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentOrange,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _simpanData,
                        child: Text(
                          'Tambah', 
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                      ),
              ),

              Spacer(),

              // --- Bottom Back Button ---
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

  // Widget custom untuk TextField
  Widget _buildCustomTextField(TextEditingController controller, String hint, TextInputType type) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor, 
        borderRadius: BorderRadius.circular(10)
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white54, fontWeight: FontWeight.w500),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }
}