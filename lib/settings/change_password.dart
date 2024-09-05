import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _showCurrentPin = false;
  bool _showNewPin = false;
  bool _showConfirmPin = false;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current PIN
              TextFormField(
                controller: _currentPinController,
                obscureText: !_showCurrentPin,
                decoration: InputDecoration(
                  labelText: 'Current PIN',
                  suffixIcon: IconButton(
                    icon: Icon(_showCurrentPin ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _showCurrentPin = !_showCurrentPin;
                      });
                    },
                  ),
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current PIN';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // New PIN
              TextFormField(
                controller: _newPinController,
                obscureText: !_showNewPin,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: 'New PIN',
                  suffixIcon: IconButton(
                    icon: Icon(_showNewPin ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _showNewPin = !_showNewPin;
                      });
                    },
                  ),
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.length != 4) {
                    return 'New PIN must be exactly 4 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm New PIN
              TextFormField(
                controller: _confirmPinController,
                obscureText: !_showConfirmPin,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: 'Confirm New PIN',
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirmPin ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _showConfirmPin = !_showConfirmPin;
                      });
                    },
                  ),
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.length != 4) {
                    return 'Confirm PIN must be exactly 4 digits';
                  } else if (value != _newPinController.text) {
                    return 'PINs do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Change PIN Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      userProvider.changePassword(
                        _currentPinController.text,
                        _newPinController.text,
                      ).then((success) {
                        if (success) {
                          Navigator.of(context).pop(); // Go back to settings
                        } else {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Failed to change PIN")),
                          );
                        }
                      });
                    }
                  },
                  child: const Text("Change PIN"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
