import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class ServisForm extends StatefulWidget {
  @override
  _ServisFormState createState() => _ServisFormState();
}

class _ServisFormState extends State<ServisForm> {
  final Color bgColor = Color(0xFF041033);
  final Color cardColor = Color(0xFF13224F);
  final Color accentOrange = Color(0xFFFF6D00);
  final Color accentGreen = Color(0xFF00E676);

  final _namaPelangganController = TextEditingController();
  final _noHpController = TextEditingController(); 
  final _motorController = TextEditingController();
  final _keluhanController = TextEditingController(); 
  final _biayaJasaController = TextEditingController(text: "0"); // Input Biaya Jasa
  
  String _statusServis = 'Proses'; 
  bool _isLoading = false;

  List<dynamic> _listMekanik = [];
  String? _selectedMekanikId;

  List<dynamic> _listSparepart = [];
  String? _selectedSparepartId;
  
  // List keranjang untuk menyimpan banyak sparepart
  List<Map<String, dynamic>> _keranjangSparepart = [];

  @override
  void initState() {
    super.initState();
    _fetchMekanik(); 
    _fetchSparepart(); 
  }

  Future<void> _fetchMekanik() async {
    try {
      final data = await ApiService.getMekanik();
      if (mounted) {
        setState(() {
          _listMekanik = data;
          if (_listMekanik.isNotEmpty) {
            _selectedMekanikId = _listMekanik[0]['id_mekanik'].toString();
          }
        });
      }
    } catch (e) {
      print("Gagal load mekanik: $e");
    }
  }

  Future<void> _fetchSparepart() async {
    try {
      final data = await ApiService.getSparepart();
      if (mounted) {
        setState(() {
          _listSparepart = data;
        });
      }
    } catch (e) {
      print("Gagal load sparepart: $e");
    }
  }

  void _tambahKeKeranjang() {
    if (_selectedSparepartId != null) {
      final selected = _listSparepart.firstWhere((e) => e['id_sparepart'].toString() == _selectedSparepartId);
      setState(() {
        _keranjangSparepart.add({
          "id": selected['id_sparepart'],
          "nama_barang": selected['nama_barang'],
          "harga": double.tryParse(selected['harga'].toString()) ?? 0
        });
      });
    }
  }

  Future<void> _simpanTransaksi() async {
    if (_namaPelangganController.text.isEmpty || _motorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nama pelanggan dan jenis motor wajib diisi!')));
      return;
    }
    if (_selectedMekanikId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pilih mekanik terlebih dahulu!')));
      return;
    }

    setState(() => _isLoading = true);

    // Menghitung Total Harga (Semua Sparepart + Biaya Jasa)
    double totalSparepart = _keranjangSparepart.fold(0, (sum, item) => sum + item['harga']);
    double biayaJasa = double.tryParse(_biayaJasaController.text) ?? 0;
    double totalKeseluruhan = totalSparepart + biayaJasa;

    String keluhanText = _keluhanController.text.isEmpty ? 'Servis Rutin' : _keluhanController.text;
    
    // Memformat sparepart menjadi string agar bisa disimpan di 1 kolom database
    String sparepartString = _keranjangSparepart.isEmpty 
        ? "-" 
        : _keranjangSparepart.map((e) => "${e['nama_barang']}~${e['harga']}").join("^");

    String combinedKeluhan = "${_motorController.text} | $keluhanText | $sparepartString";

    Map<String, dynamic> data = {
      "nama_pelanggan": _namaPelangganController.text,
      "no_hp": _noHpController.text.isEmpty ? "-" : _noHpController.text,
      "tgl_servis": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "keluhan": combinedKeluhan, 
      "biaya_jasa": totalKeseluruhan, // Harga total langsung masuk ke database
      "status": _statusServis,
      "id_mekanik": _selectedMekanikId 
    };

    bool success = await ApiService.tambahServis(data);
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context, true); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan transaksi')));
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
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.undo, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Tambah Servis',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCustomTextField(_namaPelangganController, "Nama Pelanggan..."),
                      SizedBox(height: 15),

                      _buildCustomTextField(_noHpController, "No. HP Pelanggan...", type: TextInputType.phone), 
                      SizedBox(height: 15),

                      _buildCustomTextField(_motorController, "Jenis Motor..."),
                      SizedBox(height: 15),

                      _buildCustomTextField(_keluhanController, "Keluhan (Misal: Mesin brebet)..."),
                      SizedBox(height: 25),
                      
                      // --- Keranjang Sparepart ---
                      Text("Pilih Sparepart:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  dropdownColor: cardColor,
                                  hint: Text("Pilih...", style: TextStyle(color: Colors.white54)),
                                  value: _selectedSparepartId,
                                  icon: Icon(Icons.arrow_drop_down, color: Colors.white54),
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                  items: _listSparepart.map((item) {
                                      return DropdownMenuItem<String>(
                                        value: item['id_sparepart'].toString(),
                                        child: Text("${item['nama_barang']} - Rp${item['harga']}"),
                                      );
                                    }).toList(),
                                  onChanged: (value) {
                                    setState(() => _selectedSparepartId = value);
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          InkWell(
                            onTap: _tambahKeKeranjang,
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(color: accentOrange, borderRadius: BorderRadius.circular(10)),
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                          )
                        ],
                      ),
                      
                      // List Item Keranjang
                      if (_keranjangSparepart.isNotEmpty) ...[
                        SizedBox(height: 15),
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Keranjang Sparepart:", style: TextStyle(color: accentGreen, fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              ..._keranjangSparepart.asMap().entries.map((entry) {
                                int idx = entry.key;
                                var item = entry.value;
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("- ${item['nama_barang']}", style: TextStyle(color: Colors.white, fontSize: 14)),
                                    Row(
                                      children: [
                                        Text("Rp ${item['harga']}", style: TextStyle(color: accentGreen, fontSize: 14)),
                                        SizedBox(width: 5),
                                        GestureDetector(
                                          onTap: () => setState(() => _keranjangSparepart.removeAt(idx)),
                                          child: Icon(Icons.close, color: Colors.redAccent, size: 20),
                                        )
                                      ],
                                    )
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 25),

                      Text("Biaya Jasa Mekanik:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      _buildCustomTextField(_biayaJasaController, "Isi 0 jika tidak ada...", type: TextInputType.number),
                      SizedBox(height: 25),

                      Text("Mekanik Bertugas:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            dropdownColor: cardColor,
                            hint: Text("Pilih Mekanik...", style: TextStyle(color: Colors.white54)),
                            value: _selectedMekanikId,
                            icon: Icon(Icons.arrow_drop_down, color: Colors.white54),
                            style: TextStyle(color: Colors.white, fontSize: 16),
                            items: _listMekanik.map((item) {
                              return DropdownMenuItem<String>(
                                value: item['id_mekanik'].toString(),
                                child: Text(item['nama']),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedMekanikId = value),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),

                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Keterangan Service:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            SizedBox(height: 15),
                            _buildStatusOption("Proses", Icons.water_drop_outlined),
                            SizedBox(height: 15),
                            _buildStatusOption("Antri", Icons.menu),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.only(top: 10),
                alignment: Alignment.centerRight,
                child: _isLoading
                    ? CircularProgressIndicator(color: accentOrange)
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentOrange,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _simpanTransaksi,
                        child: Text('Simpan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField(TextEditingController controller, String hint, {TextInputType type = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(10)),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildStatusOption(String title, IconData icon) {
    bool isSelected = _statusServis == title;
    return GestureDetector(
      onTap: () {
        setState(() => _statusServis = title);
      },
      child: Row(
        children: [
          Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
          SizedBox(width: 15),
          Icon(icon, color: isSelected ? accentOrange : Colors.white24, size: 24)
        ],
      ),
    );
  }
}