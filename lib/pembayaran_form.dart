import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class PembayaranForm extends StatefulWidget {
  final Map<String, dynamic> servisData; 
  const PembayaranForm({Key? key, required this.servisData}) : super(key: key);

  @override
  _PembayaranFormState createState() => _PembayaranFormState();
}

class _PembayaranFormState extends State<PembayaranForm> {
  final Color bgColor = Color(0xFF041033);
  final Color cardColor = Color(0xFF13224F);
  final Color accentGreen = Color(0xFF00E676);
  final Color accentOrange = Color(0xFFFF6D00);

  bool _isLoading = false;
  late String _motorName;
  late double _totalBayar;
  
  List<Map<String, dynamic>> _parsedSpareparts = [];
  double _totalHargaSpareparts = 0;

  String? _selectedMetode; 
  final TextEditingController _uangDiberikanController = TextEditingController();
  double _uangDiberikan = 0;
  double _kembalian = 0;

  @override
  void initState() {
    super.initState();
    _parseData();
  }

  @override
  void dispose() {
    _uangDiberikanController.dispose();
    super.dispose();
  }

  void _parseData() {
    String rawKeluhan = widget.servisData['keluhan'] ?? '';
    List<String> parts = rawKeluhan.split(' | ');

    if (parts.length >= 3) {
      _motorName = parts[0];
      String sparepartRaw = parts[2];
      
      // Memecah list sparepart dari string
      if (sparepartRaw != '-') {
        List<String> items = sparepartRaw.split('^');
        for (var item in items) {
          List<String> detail = item.split('~');
          if (detail.length == 2) {
            double hrg = double.tryParse(detail[1]) ?? 0;
            _parsedSpareparts.add({"nama": detail[0], "harga": hrg});
            _totalHargaSpareparts += hrg;
          }
        }
      }
    } else {
      _motorName = 'Motor Unknown';
    }

    double dbBiaya = double.tryParse(widget.servisData['biaya_jasa'].toString()) ?? 0;
    _totalBayar = dbBiaya > 0 ? dbBiaya : 0;
  }

  String formatRupiah(double amount) {
    final formatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  void _hitungKembalian() {
    String text = _uangDiberikanController.text.replaceAll(RegExp(r'[^0-9]'), '');
    double uang = double.tryParse(text) ?? 0;
    setState(() {
      _uangDiberikan = uang;
      _kembalian = _uangDiberikan - _totalBayar;
    });
  }

  Future<void> _prosesBayar() async {
    if (_selectedMetode == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pilih metode pembayaran terlebih dahulu!')));
      return;
    }
    if (_selectedMetode == 'Cash' && _uangDiberikan < _totalBayar) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uang yang diberikan kurang dari total bayar!')));
      return;
    }

    setState(() => _isLoading = true);

    Map<String, dynamic> data = {
      "id_servis": widget.servisData['id_servis'],
      "total_bayar": _totalBayar,
      "metode_bayar": _selectedMetode,
    };

    bool success = await ApiService.bayarServis(data);
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pembayaran $_selectedMetode Berhasil! Mencetak struk...')));
      Navigator.pop(context, true); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memproses pembayaran')));
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
                  Text('Bayar', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        Text(
                          widget.servisData['nama_pelanggan'] ?? 'Unknown',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          _motorName,
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 30),

                        // Render List Sparepart Dinamis
                        if (_parsedSpareparts.isEmpty) 
                          _buildItemRow("- Servis Saja", "Rp 0")
                        else
                          ..._parsedSpareparts.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildItemRow("- ${item['nama']}", formatRupiah(item['harga'])),
                          )).toList(),

                        // Tampilkan Biaya Jasa jika ada
                        if (_totalBayar - _totalHargaSpareparts > 0) ...[
                          SizedBox(height: 10),
                          _buildItemRow("- Biaya Jasa Mekanik", formatRupiah(_totalBayar - _totalHargaSpareparts)),
                        ],
                        
                        SizedBox(height: 25),
                        Divider(color: Colors.white54, thickness: 1),
                        SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total:", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(formatRupiah(_totalBayar), style: TextStyle(color: accentGreen, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 40),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPaymentMethod(Icons.money, "Cash"),
                            _buildPaymentMethod(Icons.qr_code_2, "Qris"),
                          ],
                        ),

                        if (_selectedMetode == 'Cash') ...[
                          SizedBox(height: 25),
                          Divider(color: Colors.white24, thickness: 1),
                          SizedBox(height: 20),
                          Align(alignment: Alignment.centerLeft, child: Text("Uang Diberikan:", style: TextStyle(color: Colors.white, fontSize: 14))),
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                            child: TextField(
                              controller: _uangDiberikanController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              onChanged: (value) => _hitungKembalian(),
                              decoration: InputDecoration(
                                prefixText: "Rp ",
                                prefixStyle: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Kembalian:", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              Text(
                                _kembalian < 0 ? "Rp 0" : formatRupiah(_kembalian),
                                style: TextStyle(color: _kembalian < 0 ? Colors.redAccent : accentGreen, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ] 
                        else if (_selectedMetode == 'Qris') ...[
                          SizedBox(height: 25),
                          Divider(color: Colors.white24, thickness: 1),
                          SizedBox(height: 20),
                          Center(
                            child: Column(
                              children: [
                                Text("Scan QRIS untuk Membayar", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(height: 15),
                                Container(
                                  padding: EdgeInsets.all(15),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                                  child: Icon(Icons.qr_code_2, size: 150, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        SizedBox(height: 40),

                        if (_selectedMetode != null) ...[
                          _isLoading
                            ? CircularProgressIndicator(color: accentGreen)
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentOrange,
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: Icon(Icons.print, color: Colors.white),
                                  label: Text("Bayar & Cetak Struk", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  onPressed: _prosesBayar,
                                ),
                              )
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemRow(String itemName, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(itemName, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        Text(price, style: TextStyle(color: accentGreen, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPaymentMethod(IconData icon, String value) {
    bool isSelected = _selectedMetode == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMetode = value;
          if (value == 'Qris') {
            _uangDiberikanController.clear();
            _kembalian = 0;
            _uangDiberikan = 0;
          }
        });
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? accentGreen.withOpacity(0.1) : Colors.transparent,
          border: Border.all(color: isSelected ? accentGreen : Colors.white24, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? accentGreen : Colors.white, size: 40),
            SizedBox(height: 8),
            Text(value, style: TextStyle(color: isSelected ? accentGreen : Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}