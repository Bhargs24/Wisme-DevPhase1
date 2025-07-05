import 'package:flutter/material.dart';
import '../../../shared/ui/widgets/widgets.dart';
import '../../../shared/ui/theme/app_theme.dart';
import '../../user_manager.dart';
import '../../../app/navigation/app_router.dart';
import '../../../core/error/app_exceptions.dart';

/// Login screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Placeholder implementation - will be enhanced when UserManager is fully implemented
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        AppNavigation.pushNamedAndClearStack(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome Back'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(WismeSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: WismeSpacing.xl),
                        
                        // Welcome message
                        Text(
                          'Sign in to continue your learning journey',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: WismeSpacing.lg),

                        // Email field
                        WismeTextField(
                          label: 'Email',
                          hint: 'Enter your email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: WismeSpacing.md),

                        // Password field
                        WismeTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: WismeSpacing.sm),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: WismeTextButton(
                            text: 'Forgot Password?',
                            onPressed: () {
                              AppNavigation.pushNamed(AppRoutes.forgotPassword);
                            },
                          ),
                        ),
                        const SizedBox(height: WismeSpacing.lg),

                        // Social login buttons
                        // Social login placeholder
                      ],
                    ),
                  ),
                ),

                // Bottom section
                Column(
                  children: [
                    // Login button
                    WismePrimaryButton(
                      text: 'Sign In',
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: WismeSpacing.md),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        WismeTextButton(
                          text: 'Sign Up',
                          onPressed: () {
                            AppNavigation.pushReplacementNamed(AppRoutes.register);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Register screen
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the terms and conditions')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Placeholder implementation - will be enhanced when UserManager is fully implemented
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        AppNavigation.pushNamedAndClearStack(AppRoutes.emailVerification);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(WismeSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: WismeSpacing.xl),
                        
                        // Welcome message
                        Text(
                          'Join thousands of learners on Wisme',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: WismeSpacing.lg),

                        // Name field
                        WismeTextField(
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.person_outlined),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: WismeSpacing.md),

                        // Email field
                        WismeTextField(
                          label: 'Email',
                          hint: 'Enter your email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: WismeSpacing.md),

                        // Password field
                        WismeTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter your password';
                            }
                            if (value!.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: WismeSpacing.md),

                        // Confirm password field
                        WismeTextField(
                          label: 'Confirm Password',
                          hint: 'Confirm your password',
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                            },
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: WismeSpacing.md),

                        // Terms and conditions
                        WismeSwitchTile(
                          title: 'I agree to the Terms and Conditions',
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() => _agreeToTerms = value);
                          },
                        ),
                        const SizedBox(height: WismeSpacing.lg),

                        // Social login buttons
                        // Social login placeholder
                      ],
                    ),
                  ),
                ),

                // Bottom section
                Column(
                  children: [
                    // Register button
                    WismePrimaryButton(
                      text: 'Create Account',
                      onPressed: _handleRegister,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: WismeSpacing.md),

                    // Sign in link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? '),
                        WismeTextButton(
                          text: 'Sign In',
                          onPressed: () {
                            AppNavigation.pushReplacementNamed(AppRoutes.login);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Forgot password screen
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Placeholder implementation - will be enhanced when UserManager is fully implemented
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() => _emailSent = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(WismeSpacing.lg),
          child: _emailSent ? _buildEmailSentView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: WismeSpacing.xl),
          
          Text(
            'Forgot your password?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: WismeSpacing.sm),
          
          Text(
            "Enter your email address and we'll send you a link to reset your password.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: WismeSpacing.xl),

          WismeTextField(
            label: 'Email',
            hint: 'Enter your email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: WismeSpacing.xl),

          WismePrimaryButton(
            text: 'Send Reset Link',
            onPressed: _handleResetPassword,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSentView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.mark_email_read,
          size: 80,
          color: Colors.green,
        ),
        const SizedBox(height: WismeSpacing.lg),
        
        Text(
          'Reset link sent!',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: WismeSpacing.sm),
        
        Text(
          'We\'ve sent a password reset link to ${_emailController.text}',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: WismeSpacing.xl),

        WismePrimaryButton(
          text: 'Back to Sign In',
          onPressed: () {
            AppNavigation.pushReplacementNamed(AppRoutes.login);
          },
        ),
      ],
    );
  }
}

/// Email verification screen
class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(WismeSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_unread,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: WismeSpacing.lg),
              
              Text(
                'Check your email',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: WismeSpacing.sm),
              
              Text(
                'We\'ve sent you a verification link. Please check your email and click the link to verify your account.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: WismeSpacing.xl),

              WismePrimaryButton(
                text: 'Continue to App',
                onPressed: () {
                  AppNavigation.pushNamedAndClearStack(AppRoutes.onboarding);
                },
              ),
              const SizedBox(height: WismeSpacing.md),

              WismeTextButton(
                text: 'Resend Email',
                onPressed: () {
                  // Resend verification email
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
