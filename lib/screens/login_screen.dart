import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:b_cara/resources/auth_methods.dart';
import 'package:b_cara/responsive/mobile_screen_layout.dart';
import 'package:b_cara/responsive/responsive_layout.dart';
import 'package:b_cara/responsive/web_screen_layout.dart';
import 'package:b_cara/screens/signup_screen.dart';
import 'package:b_cara/utils/colors.dart';
import 'package:b_cara/utils/global_variable.dart';
import 'package:b_cara/utils/utils.dart';
import 'package:b_cara/widgets/text_field_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async {
    if (!_form.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
        email: _emailController.text, password: _passwordController.text);
    if (res == 'success') {
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const ResponsiveLayout(
                mobileScreenLayout: MobileScreenLayout(),
                webScreenLayout: WebScreenLayout(),
              ),
            ),
            (route) => false);

        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        showSnackBar(context, res);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          padding: MediaQuery.of(context).size.width > webScreenSize
              ? EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 3)
              : const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 2,
                  child: Container(),
                ),
                // SvgPicture.asset(
                //   'assets/ic_instagram.svg',
                //   color: primaryColor,
                //   height: 64,
                // ),
                const SizedBox(
                  height: 64,
                ),
                TextFieldInput(
                  hintText: 'Enter your email',
                  textInputType: TextInputType.emailAddress,
                  textEditingController: _emailController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Email is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 24,
                ),
                TextFieldInput(
                  hintText: 'Enter your password',
                  textInputType: TextInputType.text,
                  textEditingController: _passwordController,
                  isPass: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Password is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 24,
                ),
                InkWell(
                  onTap: loginUser,
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      color: blueColor,
                    ),
                    child: !_isLoading
                        ? const Text(
                            'Log in',
                          )
                        : const CircularProgressIndicator(
                            color: primaryColor,
                          ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Flexible(
                  flex: 2,
                  child: Container(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        'Dont have an account?',
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text(
                          ' Signup.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
