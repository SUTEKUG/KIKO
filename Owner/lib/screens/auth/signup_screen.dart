import 'package:flutter/material.dart';
import 'package:owner/screens/owner_home_screen.dart';
import 'package:owner/services/owner_services.dart';
import 'package:owner/widgets/custom_button.dart';
import 'package:owner/widgets/custom_text_field.dart';

class OwnerSignupScreen extends StatefulWidget {
  const OwnerSignupScreen({Key? key}) : super(key: key);

  @override
  _OwnerSignupScreenState createState() => _OwnerSignupScreenState();
}

class _OwnerSignupScreenState extends State<OwnerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _restaurantNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();
  final _ownerService = OwnerService();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await _ownerService.signUp(
          email: _emailController.text,
          password: _passwordController.text,
          username: _usernameController.text,
          restaurantName: _restaurantNameController.text,
          location: _locationController.text,
          category: _categoryController.text,
        );

        if (response.user != null && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const OwnerHomeScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Restaurant Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                obscureText: true,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              CustomTextField(
                controller: _usernameController,
                label: 'Username',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              CustomTextField(
                controller: _restaurantNameController,
                label: 'Restaurant Name',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              CustomTextField(
                controller: _locationController,
                label: 'Location',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              CustomTextField(
                controller: _categoryController,
                label: 'Category',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              CustomButton(
                onPressed: _signUp,
                isLoading: _isLoading,
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _restaurantNameController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
