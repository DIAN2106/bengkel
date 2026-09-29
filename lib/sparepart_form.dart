import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

class SparepartForm extends StatefulWidget {
  @override
  _SparepartFormState createState() => _SparepartFormState();
}

class _SparepartFormState extends State<SparepartForm> {
  final Color bgColor = Color(0xFF041033);
  final Color cardColor = Color(0xFF13224F);
  final Color accentOrange = Color(0xFFFF6D00);

  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();
  
  bool _isLoading = false;

  // Variabel untuk menampung file foto
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Fungsi untuk membuka galeri dan memilih foto
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengambil foto')));
    }
  }

  Future<void> _simpanData() async {
    if (_namaController.text.isEmpty || _hargaController.text.isEmpty || _stokController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Harap isi semua kolom data!')));
      return;
    }

    setState(() => _isLoading = true);

    // Konversi gambar ke format base64 jika foto dipilih
    String base64Image = "";
    if (_imageFile != null) {
      List<int> imageBytes = await _imageFile!.readAsBytes();
      base64Image = "data:image/jpeg;base64," + base64Encode(imageBytes);
    }

    Map<String, dynamic> data = {
      "nama_barang": _namaController.text,
      "harga": _hargaController.text,
      "stok": _stokController.text,
      "foto": base64Image, // Kirim foto dalam bentuk teks base64
    };

    bool success = await ApiService.tambahSparepart(data);
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context, true); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan sparepart')));
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
                children: [
                  IconButton(
                    icon: Icon(Icons.undo, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Tambah Sparepart',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // --- Form Inputs ---
                      _buildCustomTextField(_namaController, "Nama Barang...", TextInputType.text),
                      SizedBox(height: 15),
                      _buildCustomTextField(_hargaController, "Harga Barang...", TextInputType.number),
                      SizedBox(height: 15),
                      _buildCustomTextField(_stokController, "Stok Barang...", TextInputType.number),
                      SizedBox(height: 30),

                      // --- Kotak Tambah Foto ---
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 200, 
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(15),
                            // Tampilkan gambar jika sudah ada yang dipilih
                            image: _imageFile != null
                                ? DecorationImage(
                                    image: FileImage(_imageFile!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          // Tampilkan ikon plus hanya jika gambar belum ada
                          child: _imageFile == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Tambah Foto\n(JPG/PNG)",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(height: 15),
                                    Icon(Icons.add_a_photo, color: Colors.white, size: 40),
                                  ],
                                )
                              : null,
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // --- Bottom Actions ---
              Container(
                alignment: Alignment.centerRight,
                child: _isLoading
                    ? CircularProgressIndicator(color: accentOrange)
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentOrange,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _simpanData,
                        child: Text('Simpan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

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