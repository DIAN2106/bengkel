import 'package:flutter/material.dart'; 
import 'pelanggan_list.dart';  
import 'servis_list.dart'; 
import 'sparepart_list.dart'; 
import 'motor_list.dart'; 
import 'mekanik_list.dart'; 
import 'login_screen.dart'; // Import halaman login untuk rute logout

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Warna tema menyesuaikan gambar
    final Color bgColor = Color(0xFF041033);
    final Color cardColor = Color(0xFF13224F);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Bagian Header Profile ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(
                            'https://cdn-icons-png.flaticon.com/512/3135/3135715.png'), // Placeholder avatar
                        backgroundColor: Colors.orange,
                      ),
                      SizedBox(width: 15),
                      Text(
                        'Halo Dian!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications, color: Colors.white, size: 28),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Belum ada notifikasi baru')));
                    },
                  ),
                ],
              ),
              
              SizedBox(height: 40),

              // --- Bagian Grid Menu ---
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.1, // Mengatur proporsi kotak agar pas
                  children: [
                    _buildMenuCard(
                      context, 
                      title: 'Service', 
                      icon: Icons.build, 
                      cardColor: cardColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ServisList()),
                        );
                      }
                    ),
                    _buildMenuCard(
                      context, 
                      title: 'Sparepart', 
                      icon: Icons.inventory_2, 
                      cardColor: cardColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SparepartList()),
                        );
                      }
                    ),
                    _buildMenuCard(
                      context, 
                      title: 'Motor', 
                      icon: Icons.motorcycle, 
                      cardColor: cardColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MotorList()),
                        );
                      }
                    ),
                    _buildMenuCard(
                      context, 
                      title: 'Pelanggan', 
                      icon: Icons.people, 
                      cardColor: cardColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PelangganList()),
                        );
                      }
                    ),
                    _buildMenuCard(
                      context, 
                      title: 'Mekanik', 
                      icon: Icons.engineering, 
                      cardColor: cardColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MekanikList()),
                        );
                      }
                    ),
                    _buildMenuCard(
                      context, 
                      title: 'Logout', 
                      icon: Icons.logout, 
                      cardColor: cardColor,
                      onTap: () {
                        // Tampilkan pesan
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Anda telah berhasil Logout'))
                        );
                        // Navigasi ke halaman login dan hapus semua history halaman sebelumnya
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                          (route) => false,
                        );
                      }
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget custom agar kodenya tidak berulang untuk setiap kotak menu
  Widget _buildMenuCard(BuildContext context, {
    required String title, 
    required IconData icon, 
    required Color cardColor, 
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}