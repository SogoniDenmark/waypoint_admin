import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _religionController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _nicknameController.dispose();
    _religionController.dispose();
    super.dispose();
  }

  Future signUp() async {
    if (passwordConfirmed()) {
      try {
        // Sign up user
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Get the current user
        User? user = userCredential.user;

        // Store user details in Firestore
        await addUserDetails(
          _fullNameController.text.trim(),
          _nicknameController.text.trim(),
          _religionController.text.trim(),
          user!.email!,
          user.uid,
        );

        // Navigate to home page after successful registration
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const HomePage();
            },
          ),
        );
      } catch (e) {
        // Handle sign-up error, display message
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.toString()),
            );
          },
        );
      }
    }
  }

  Future addUserDetails(String fullName, String nickname, String religion,
      String email, String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'fullName': fullName,
      'nickname': nickname,
      'religion': religion,
      'email': email,
      'uid': uid,
    });
  }

  bool passwordConfirmed() {
    if (_passwordController.text.trim() ==
        _confirmPasswordController.text.trim()) {
      return true;
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('Passwords Don\'t Match!'),
          );
        },
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: SafeArea(
        child: Center(
          child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Sign Up',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          _buildInputField(_emailController, 'Email'),
          const SizedBox(height: 15),
          _buildInputField(_religionController, 'Religion'),
          const SizedBox(height: 15),
          _buildInputField(_fullNameController, 'Full Name'),
          const SizedBox(height: 15),
          _buildInputField(_nicknameController, 'Nickname'),
          const SizedBox(height: 15),
          _buildInputField(_passwordController, 'Password', obscureText: true),
          const SizedBox(height: 15),
          _buildInputField(_confirmPasswordController, 'Confirm Password', obscureText: true),
          const SizedBox(height: 25),
          _buildRegisterButton(),
          const SizedBox(height: 25),
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1000),
      padding: const EdgeInsets.all(40),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/logo.png',
                      width: 300,
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'WAYPOINT ADMIN',
                      style: GoogleFonts.bebasNeue(fontSize: 60),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildInputField(_emailController, 'Email'),
                    const SizedBox(height: 20),
                    _buildInputField(_religionController, 'Religion'),
                    const SizedBox(height: 20),
                    _buildInputField(_fullNameController, 'Full Name'),
                    const SizedBox(height: 20),
                    _buildInputField(_nicknameController, 'Nickname'),
                    const SizedBox(height: 20),
                    _buildInputField(_passwordController, 'Password', obscureText: true),
                    const SizedBox(height: 20),
                    _buildInputField(_confirmPasswordController, 'Confirm Password', obscureText: true),
                    const SizedBox(height: 30),
                    _buildRegisterButton(),
                    const SizedBox(height: 30),
                    _buildLoginLink(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hintText, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              fillColor: Colors.grey[200],
              filled: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: GestureDetector(
        onTap: signUp,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'REGISTER',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: widget.showLoginPage,
          child: const Text(
            ' Login now',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}