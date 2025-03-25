import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:quiz_crafter/theme/theme.dart';
import 'package:quiz_crafter/view/auth/set_password_screen.dart';
import 'package:quiz_crafter/widgets/body_background.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _pinTEController = TextEditingController();

  bool isError = false;
  late Timer _timer = Timer(Duration.zero, () {});
  int _secondsRemaining = 120;
  bool _isResendEnabled = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _isResendEnabled = true;
          _timer.cancel();
        });
      }
    });
  }

  void _resendCode() async {
    _secondsRemaining = 120;
    _isResendEnabled = false;
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColors,
      body: BodyBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Verify OTP",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "A 4 digit code has been sent to your email",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  PinCodeTextField(
                    controller: _pinTEController,
                    appContext: context,
                    length: 4,
                    obscureText: true,
                    animationType: AnimationType.fade,
                    backgroundColor: Colors.transparent,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    keyboardType: TextInputType.number,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldWidth: 40,
                      fieldHeight: 50,
                      activeFillColor: Colors.transparent,
                      inactiveFillColor: Colors.transparent,
                      selectedFillColor: Colors.transparent,
                      activeColor: isError ? Colors.red : AppTheme.primaryColor,
                      inactiveColor: Colors.grey,
                      selectedColor:
                          isError ? Colors.red : AppTheme.secondaryColor,
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: false,
                    textStyle: TextStyle(
                      color: isError ? Colors.red : AppTheme.secondaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    onCompleted: (v) {
                      setState(
                        () {
                          if (v == "0000") {
                            isError = false;
                          } else {
                            isError = true;
                          }
                        },
                      );
                    },
                    onChanged: (value) {
                      setState(
                        () {
                          isError = false;
                        },
                      );
                    },
                    beforeTextPaste: (text) => true,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SetPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "VERIFY",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                      children: [
                        TextSpan(
                          text: "This code will expire in ",
                        ),
                        TextSpan(
                          text: "$_secondsRemaining s",
                          style: TextStyle(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _isResendEnabled ? _resendCode : null,
                    child: Text(
                      "Resend Code",
                      style: TextStyle(
                        color: _isResendEnabled
                            ? AppTheme.secondaryColor
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
