import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp_pin_field/otp_pin_field.dart';
import '../home_screen/home_screen.dart';

class OtpScreen extends StatefulWidget {
  bool _isInit = true;
  var _contact = '';

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late String phoneNo;
  late String smsOTP;
  late String verificationId;
  String errorMessage = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _otpPinFieldKey = GlobalKey<OtpPinFieldState>();
  late Timer _timer;
  int _start = 90;
  bool _isResendVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget._isInit) {
      widget._contact =
      '${ModalRoute.of(context)?.settings.arguments as String}';
      generateOtp(widget._contact);
      startTimer();
      widget._isInit = false;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    _start = 90;
    _isResendVisible = false;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isResendVisible = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  String getTimerText() {
    int minutes = _start ~/ 60;
    int seconds = _start % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                Image.asset(
                  'assets/otp_icon.png',
                  height: screenHeight * 0.3,
                  fit: BoxFit.contain,
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                const Text(
                  'Verification',
                  style: TextStyle(fontSize: 28, color: Colors.black),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                Text(
                  'Enter a 6 digit number that was sent to ${widget._contact}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.04,
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: screenWidth > 600 ? screenWidth * 0.2 : 16),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(16.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          OtpPinField(
                            key: _otpPinFieldKey,
                            textInputAction: TextInputAction.done,
                            maxLength: 6,
                            fieldWidth: 30,
                            onSubmit: (text) {
                              smsOTP = text;
                            },
                            onChange: (text) {},
                          ),
                          Positioned(
                            right: 0,
                            bottom: 35, // Adjust this value as needed
                            child: GestureDetector(
                              onTap: _isResendVisible ? resendOtp : null,
                              child: Text(
                                _isResendVisible ? 'Resend OTP' : getTimerText(),
                                style: TextStyle(
                                  color: _isResendVisible ? Colors.blue : Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (errorMessage.isNotEmpty) // Show error message if it exists
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(
                        height: screenHeight * 0.04,
                      ),
                      GestureDetector(
                        onTap: verifyOtp,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          height: 45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 253, 188, 51),
                            borderRadius: BorderRadius.circular(36),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Verify',
                            style: TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> generateOtp(String contact) async {
    final PhoneCodeSent smsOTPSent = (verId, forceResendingToken) {
      verificationId = verId;
    };
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: contact,
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
        codeSent: smsOTPSent,
        timeout: const Duration(seconds: 90), // Updated duration to 1:30
        verificationCompleted: (AuthCredential phoneAuthCredential) {},
        verificationFailed: (error) {
          print(error);
        },
      );
    } catch (e) {
      handleError(e as PlatformException);
    }
  }

  Future<void> verifyOtp() async {
    if (smsOTP.isEmpty || smsOTP == '') {
      showAlertDialog(context, 'please enter 6 digit otp');
      return;
    }
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsOTP,
      );
      final UserCredential user = await _auth.signInWithCredential(credential);
      final User? currentUser = _auth.currentUser;
      assert(user.user?.uid == currentUser?.uid);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(phoneNumber: widget._contact),
        ),
      );
    } on FirebaseAuthException catch (e) {
      handleError(e);
    } catch (e) {
      print('error $e');
    }
  }

  void resendOtp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OtpScreen(),
        settings: RouteSettings(arguments: widget._contact),
      ),
    );
  }

  void handleError(Exception error) {
    String message;
    if (error is PlatformException && error.code == 'ERROR_INVALID_VERIFICATION_CODE') {
      message = 'Invalid Code';
    } else if (error is FirebaseAuthException && error.code == 'invalid-verification-code') {
      message = 'Invalid Code';
    } else {
      message = error.toString();
    }
    setState(() {
      errorMessage = message;
    });
    showAlertDialog(context, message);
  }

  void showAlertDialog(BuildContext context, String message) {
    final CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: const Text('Error'),
      content: Text('\n$message'),
      actions: <Widget>[
        CupertinoDialogAction(
          isDefaultAction: true,
          child: const Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
