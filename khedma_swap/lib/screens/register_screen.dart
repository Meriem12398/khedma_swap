import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;

  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _personalFormKey = GlobalKey<FormState>();
  final _accountFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_accountFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      AuthService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte créé avec succès 🎉')),
      );

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_personalFormKey.currentState!.validate()) {
        setState(() {
          _currentStep = 1;
        });
      }
    } else if (_currentStep == 1) {
      if (_accountFormKey.currentState!.validate()) {
        setState(() {
          _currentStep = 2;
        });
      }
    } else if (_currentStep == 2) {
      if (!_isLoading) {
        _submit();
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  StepState _stepState(int step) {
    if (_currentStep > step) return StepState.complete;
    if (_currentStep == step) return StepState.editing;
    return StepState.indexed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final steps = [
      Step(
        title: const Text('Infos personnelles'),
        state: _stepState(0),
        isActive: _currentStep >= 0,
        content: Form(
          key: _personalFormKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nom obligatoire';
                  }
                  if (value.trim().length < 3) {
                    return 'Nom trop court';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Ville (optionnel)',
                  prefixIcon: Icon(Icons.location_city_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      Step(
        title: const Text('Compte'),
        state: _stepState(1),
        isActive: _currentStep >= 1,
        content: Form(
          key: _accountFormKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email obligatoire';
                  }
                  if (!value.contains('@')) {
                    return 'Email non valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mot de passe obligatoire';
                  }
                  if (value.length < 6) {
                    return 'Au moins 6 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirmation obligatoire';
                  }
                  if (value != _passwordController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      Step(
        title: const Text('Récapitulatif'),
        state: _stepState(2),
        isActive: _currentStep >= 2,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vérifiez vos informations avant de créer le compte :',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person_outline),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Nom : ${_nameController.text.trim()}'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_cityController.text.trim().isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.location_city_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Ville : ${_cityController.text.trim()}'),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.email_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Email : ${_emailController.text.trim()}'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            Text(
              'Appuyez sur "Créer mon compte" pour terminer l’inscription.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        steps: steps,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        onStepTapped: (index) {
          setState(() {
            _currentStep = index;
          });
        },
        controlsBuilder: (context, details) {
          final isLast = _currentStep == steps.length - 1;
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : details.onStepContinue,
                  child: _isLoading && isLast
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isLast ? 'Créer mon compte' : 'Suivant'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _isLoading ? null : details.onStepCancel,
                  child: Text(_currentStep == 0 ? 'Annuler' : 'Retour'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
