import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memory_flutter/providers/auth_provider.dart';
import 'package:memory_flutter/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      bool success = false;
      try {
        if (_isLogin) {
          success = await authProvider.signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );
        } else {
          success = await authProvider.register(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );
        }
        
        if (!success && mounted) {
          setState(() {
            _errorMessage = authProvider.error;
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.memory,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // App name
                Center(
                  child: Text(
                    'Memory AI',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Tagline
                Center(
                  child: Text(
                    'Your Life Events',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Login/Register form
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title
                          Text(
                            _isLogin ? 'Login to your account' : 'Create an account',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          
                          // Name field (only for register)
                          if (!_isLogin) ...[
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                hintText: 'Enter your name',
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: Validators.validateName,
                              textInputAction: TextInputAction.next,
                              enabled: !_isLoading,
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Email field
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              prefixIcon: Icon(Icons.email),
                            ),
                            validator: Validators.validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            enabled: !_isLoading,
                          ),
                          const SizedBox(height: 16),
                          
                          // Password field
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: Validators.validatePassword,
                            obscureText: _obscurePassword,
                            textInputAction: _isLogin
                                ? TextInputAction.done
                                : TextInputAction.next,
                            enabled: !_isLoading,
                          ),
                          const SizedBox(height: 24),
                          
                          // Error message
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Submit button
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(_isLogin ? 'Login' : 'Register'),
                          ),
                          const SizedBox(height: 16),
                          
                          // Toggle login/register
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _isLogin = !_isLogin;
                                      _errorMessage = null;
                                      _formKey.currentState?.reset();
                                    });
                                  },
                            child: Text(
                              _isLogin
                                  ? 'Don\'t have an account? Register'
                                  : 'Already have an account? Login',
                            ),
                          ),
                        ],
                      ),
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