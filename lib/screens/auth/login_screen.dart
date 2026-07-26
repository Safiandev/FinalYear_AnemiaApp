import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hemoglobe_ai/user_provider.dart';
import 'package:hemoglobe_ai/screens/auth/signup_screen.dart';
import 'package:hemoglobe_ai/main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? email;
  final String? password;

  const LoginScreen({super.key, this.email, this.password});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email ?? '');
    _passwordController = TextEditingController(text: widget.password ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ------------------- UPDATED LOGIN FUNCTION -------------------
  Future<void> _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Firebase Sign In
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      User? user = userCredential.user;

      // ✉️ EMAIL VERIFICATION CHECK
      if (user != null && !user.emailVerified) {
        await _auth.signOut();
        _showErrorSnackBar(
            'Please verify your email address before logging in.');
        return;
      }

      // ✅ 2. DYNAMIC ID & DATA UPDATION LOGIC
      if (user != null) {
        String uid = user.uid;
        String name = user.displayName ?? "User";

        // Globally user info update kar di
        UserProvider.setUser(uid, name);

        // ✅ FIX: Login hotay hi profile photo & Firestore data initialize kar do
        await UserProvider.initUserData();

        debugPrint("Successfully Logged In & Data Loaded. UID: $uid");
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          (route) => false, // Is se pichli saari screens remove ho jayengi
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      }
      _showErrorSnackBar(message);
    } catch (e) {
      _showErrorSnackBar("Check your internet connection");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

// ------------------- FORGOT PASSWORD DIALOG & LOGIC -------------------
  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController(
      text: _emailController.text.trim(),
    );

    showDialog(
      context: context,
      builder: (context) {
        bool isSending = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Reset Password',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your registered email address and we will send you a link to reset your password.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(
                        'your@email.com', Icons.email_outlined),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSending ? null : () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          String email = resetEmailController.text.trim();
                          if (email.isEmpty) {
                            _showErrorSnackBar(
                                'Please enter your email address');
                            return;
                          }

                          setDialogState(() => isSending = true);

                          try {
                            await _auth.sendPasswordResetEmail(email: email);

                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Password reset link sent to $email! Check your inbox.'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            String errorMsg = 'Failed to send reset email';
                            if (e.code == 'user-not-found') {
                              errorMsg = 'No user registered with this email.';
                            } else if (e.code == 'invalid-email') {
                              errorMsg = 'Please enter a valid email address.';
                            }
                            _showErrorSnackBar(errorMsg);
                          } catch (e) {
                            _showErrorSnackBar(
                                'Something went wrong. Please try again.');
                          } finally {
                            setDialogState(() => isSending = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isSending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Send Link'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.remove_red_eye_rounded,
                        size: 45,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Welcome',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Securely sign in to check your\nhemoglobin status with AI.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blueGrey, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildLabel('Email Address'),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    _inputDecoration('your@email.com', Icons.email_outlined),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel('Password'),
                  TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: const Text('Forgot?',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration:
                    _inputDecoration('••••••••', Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text(
                          'Login',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("New here? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper UI Methods
  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      );

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.blueGrey),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:hemoglobe_ai/user_provider.dart';
// import 'package:hemoglobe_ai/screens/auth/signup_screen.dart';
// import 'package:hemoglobe_ai/main_navigation_screen.dart';

// class LoginScreen extends StatefulWidget {
//   final String? email;
//   final String? password;

//   const LoginScreen({super.key, this.email, this.password});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   bool _obscurePassword = true;
//   bool _isLoading = false;

//   late TextEditingController _emailController;
//   late TextEditingController _passwordController;

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   @override
//   void initState() {
//     super.initState();
//     _emailController = TextEditingController(text: widget.email ?? '');
//     _passwordController = TextEditingController(text: widget.password ?? '');
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   // ------------------- UPDATED LOGIN FUNCTION -------------------
//   Future<void> _handleLogin() async {
//     String email = _emailController.text.trim();
//     String password = _passwordController.text.trim();

//     if (email.isEmpty || password.isEmpty) {
//       _showErrorSnackBar('Please fill in all fields');
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       // 1. Firebase Sign In
//       // 1. Firebase Sign In
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//           email: email, password: password);

//       User? user = userCredential.user;

//       // ✉️ EMAIL VERIFICATION CHECK
//       if (user != null && !user.emailVerified) {
//         // Agar email verify nahi hai, to session signOut kar do aur block kar do
//         await _auth.signOut();
//         _showErrorSnackBar(
//             'Please verify your email address before logging in.');
//         return;
//       }

//       // ✅ 2. DYNAMIC ID UPDATION LOGIC
//       if (user != null) {
//         String uid = user.uid;
//         String name = user.displayName ?? "User";

//         // Globally user info update kar di
//         UserProvider.setUser(uid, name);

//         debugPrint("Successfully Logged In. UID: $uid");
//       }

//       if (mounted) {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
//           (route) => false, // Is se pichli saari screens remove ho jayengi
//         );
//       }
//     } on FirebaseAuthException catch (e) {
//       String message = 'Login failed';
//       if (e.code == 'user-not-found') {
//         message = 'No user found for that email.';
//       } else if (e.code == 'wrong-password') {
//         message = 'Wrong password provided.';
//       } else if (e.code == 'invalid-credential') {
//         message = 'Invalid email or password.';
//       }
//       _showErrorSnackBar(message);
//     } catch (e) {
//       _showErrorSnackBar("Check your internet connection");
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.redAccent,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(10),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }

// // ------------------- FORGOT PASSWORD DIALOG & LOGIC -------------------
//   void _showForgotPasswordDialog() {
//     final TextEditingController resetEmailController = TextEditingController(
//       text: _emailController.text
//           .trim(), // Pre-fill email if user already typed it
//     );

//     showDialog(
//       context: context,
//       builder: (context) {
//         bool isSending = false;
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               title: const Text(
//                 'Reset Password',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Enter your registered email address and we will send you a link to reset your password.',
//                     style: TextStyle(fontSize: 13, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 15),
//                   TextField(
//                     controller: resetEmailController,
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: _inputDecoration(
//                         'your@email.com', Icons.email_outlined),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: isSending ? null : () => Navigator.pop(context),
//                   child: const Text('Cancel',
//                       style: TextStyle(color: Colors.grey)),
//                 ),
//                 ElevatedButton(
//                   onPressed: isSending
//                       ? null
//                       : () async {
//                           String email = resetEmailController.text.trim();
//                           if (email.isEmpty) {
//                             _showErrorSnackBar(
//                                 'Please enter your email address');
//                             return;
//                           }

//                           setDialogState(() => isSending = true);

//                           try {
//                             // Firebase password reset trigger
//                             await _auth.sendPasswordResetEmail(email: email);

//                             if (mounted) {
//                               Navigator.pop(context); // Close dialog
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   content: Text(
//                                       'Password reset link sent to $email! Check your inbox.'),
//                                   backgroundColor: Colors.green,
//                                   behavior: SnackBarBehavior.floating,
//                                   margin: const EdgeInsets.all(10),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                 ),
//                               );
//                             }
//                           } on FirebaseAuthException catch (e) {
//                             String errorMsg = 'Failed to send reset email';
//                             if (e.code == 'user-not-found') {
//                               errorMsg = 'No user registered with this email.';
//                             } else if (e.code == 'invalid-email') {
//                               errorMsg = 'Please enter a valid email address.';
//                             }
//                             _showErrorSnackBar(errorMsg);
//                           } catch (e) {
//                             _showErrorSnackBar(
//                                 'Something went wrong. Please try again.');
//                           } finally {
//                             setDialogState(() => isSending = false);
//                           }
//                         },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: isSending
//                       ? const SizedBox(
//                           height: 18,
//                           width: 18,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : const Text('Send Link'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 30),
//               Center(
//                 child: Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.withOpacity(0.1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.remove_red_eye_rounded,
//                         size: 45,
//                         color: Colors.blueAccent,
//                       ),
//                     ),
//                     const SizedBox(height: 25),
//                     const Text(
//                       'Welcome',
//                       style:
//                           TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 10),
//                     const Text(
//                       'Securely sign in to check your\nhemoglobin status with AI.',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.blueGrey, height: 1.5),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 40),
//               _buildLabel('Email Address'),
//               TextField(
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration:
//                     _inputDecoration('your@email.com', Icons.email_outlined),
//               ),
//               const SizedBox(height: 25),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _buildLabel('Password'),
//                   TextButton(
//                     onPressed: _showForgotPasswordDialog,
//                     child: const Text('Forgot?',
//                         style: TextStyle(fontWeight: FontWeight.bold)),
//                   ),
//                 ],
//               ),
//               TextField(
//                 controller: _passwordController,
//                 obscureText: _obscurePassword,
//                 decoration:
//                     _inputDecoration('••••••••', Icons.lock_outline).copyWith(
//                   suffixIcon: IconButton(
//                     icon: Icon(_obscurePassword
//                         ? Icons.visibility_off
//                         : Icons.visibility),
//                     onPressed: () =>
//                         setState(() => _obscurePassword = !_obscurePassword),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 40),
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _handleLogin,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15)),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(
//                           height: 24,
//                           width: 24,
//                           child: CircularProgressIndicator(
//                               color: Colors.white, strokeWidth: 2))
//                       : const Text(
//                           'Login',
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                 ),
//               ),
//               const SizedBox(height: 40),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text("New here? "),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const SignUpScreen()),
//                       );
//                     },
//                     child: const Text(
//                       'Create Account',
//                       style: TextStyle(
//                           color: Colors.blue, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper UI Methods
//   Widget _buildLabel(String text) => Padding(
//         padding: const EdgeInsets.only(bottom: 8, left: 4),
//         child: Text(text,
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//       );

//   InputDecoration _inputDecoration(String hint, IconData icon) {
//     return InputDecoration(
//       hintText: hint,
//       prefixIcon: Icon(icon, color: Colors.blueGrey),
//       filled: true,
//       fillColor: Colors.grey.shade50,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(15),
//         borderSide: BorderSide.none,
//       ),
//       contentPadding: const EdgeInsets.symmetric(vertical: 18),
//     );
//   }
// }
