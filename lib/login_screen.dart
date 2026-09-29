import 'package:flutter/material.dart';
import 'dashboard.dart'; 
import 'api_service.dart'; 

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Color bgColor = const Color(0xFF041033);
  final Color inputColor = const Color(0xFF13224F); 
  final Color buttonColor = const Color(0xFF2962FF); 

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String _selectedRole = 'Admin';
  bool _isLoading = false;

  Future<void> _prosesLogin() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan Password tidak boleh kosong!'))
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success = await ApiService.login(
      _usernameController.text, 
      _passwordController.text, 
      _selectedRole
    );

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Berhasil!'), backgroundColor: Colors.green)
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username, Password, atau Role salah!'), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Logo Lokal ---
                // Mengambil gambar dari folder assets lokal
                Image.asset(
                  'assets/logo.png', // Pastikan nama ini sama dengan nama file di folder assets
                  height: 180,
                  errorBuilder: (context, error, stackTrace) {
                    // Jika gambar gagal dimuat, tampilkan ikon cadangan
                    return const Icon(Icons.two_wheeler, size: 100, color: Colors.white);
                  },
                ),
                const SizedBox(height: 40),

                // --- Dropdown Role ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: inputColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: inputColor,
                      value: _selectedRole,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      items: ['Admin', 'Kasir', 'Mekanik'].map((String role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role, style: const TextStyle(fontWeight: FontWeight.w500)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRole = newValue!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // --- Input Username ---
                Container(
                  decoration: BoxDecoration(
                    color: inputColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Username',
                      hintStyle: TextStyle(color: Colors.white54),
                      prefixIcon: Icon(Icons.person, color: Colors.white),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // --- Input Password ---
                Container(
                  decoration: BoxDecoration(
                    color: inputColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true, 
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.white54),
                      prefixIcon: Icon(Icons.lock, color: Colors.white),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // --- Lupa Password ---
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Silakan hubungi administrator database'))
                      );
                    },
                    child: const Text(
                      'Lupa password?',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // --- Tombol Login ---
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _prosesLogin,
                          child: const Text(
                            'Login',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}