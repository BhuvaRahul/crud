import 'package:crud/screens/home_screen.dart';
import 'package:crud/utils/colors_utils.dart';
import 'package:crud/utils/common_string.dart';
import 'package:crud/utils/font_utils.dart';
import 'package:crud/utils/helpers.dart';
import 'package:crud/widgets/custom_loader.dart';
import 'package:crud/widgets/pin_input_field.dart';
import 'package:easy_container/easy_container.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';

class VerifyPhoneNumberScreen extends StatefulWidget {
  static const id = 'VerifyPhoneNumberScreen';

  final String phoneNumber;

  const VerifyPhoneNumberScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<VerifyPhoneNumberScreen> createState() => _VerifyPhoneNumberScreenState();
}

class _VerifyPhoneNumberScreenState extends State<VerifyPhoneNumberScreen> with WidgetsBindingObserver {
  bool isKeyboardVisible = false;

  late final ScrollController scrollController;
  String otpController = '';

  @override
  void initState() {
    scrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomViewInsets = WidgetsBinding.instance.window.viewInsets.bottom;
    isKeyboardVisible = bottomViewInsets > 0;
  }

  // scroll to bottom of screen, when pin input field is in focus.
  Future<void> _scrollToBottomOnKeyboardOpen() async {
    while (!isKeyboardVisible) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    await Future.delayed(const Duration(milliseconds: 250));

    await scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FirebasePhoneAuthHandler(
        phoneNumber: widget.phoneNumber,
        signOutOnSuccessfulVerification: false,
        sendOtpOnInitialize: true,
        linkWithExistingUser: false,
        autoRetrievalTimeOutDuration: const Duration(seconds: 60),
        otpExpirationDuration: const Duration(seconds: 60),
        onCodeSent: () {
          log(VerifyPhoneNumberScreen.id, msg: 'OTP sent!');
        },
        onLoginSuccess: (userCredential, autoVerified) async {
          log(
            VerifyPhoneNumberScreen.id,
            msg: autoVerified ? 'OTP was fetched automatically!' : 'OTP was verified manually!',
          );

          showSnackBar('Phone number verified successfully!');

          log(
            VerifyPhoneNumberScreen.id,
            msg: 'Login Success UID: ${userCredential.user?.uid}',
          );

          Navigator.pushNamedAndRemoveUntil(
            context,
            HomeScreen.id,
            (route) => false,
          );
        },
        onLoginFailed: (authException, stackTrace) {
          log(
            VerifyPhoneNumberScreen.id,
            msg: authException.message,
            error: authException,
            stackTrace: stackTrace,
          );

          switch (authException.code) {
            case 'invalid-phone-number':
              return showSnackBar('Invalid phone number!');
            case 'invalid-verification-code':
              return showSnackBar('The entered OTP is invalid!');
            default:
              showSnackBar('Something went wrong!');
          }
        },
        onError: (error, stackTrace) {
          log(
            VerifyPhoneNumberScreen.id,
            error: error,
            stackTrace: stackTrace,
          );

          showSnackBar('An error occurred!');
        },
        builder: (context, controller) {
          return Scaffold(
            body: controller.isSendingCode
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CustomLoader(),
                      const SizedBox(height: 50),
                      Center(
                        child: Text(
                          TextUtils.sendingOTPTxt,
                          style: FontUtils.h24(),
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.isListeningForOtpAutoRetrieve) const SizedBox(height: 15),
                        Text(
                          TextUtils.enterOTPTxt,
                          style: FontUtils.h14(
                            fontColor: ColorUtils.oXFF6750A4,
                            fontWeight: FWT.medium,
                          ),
                        ),
                        const SizedBox(height: 10),
                        PinInputField(
                          length: 6,
                          onFocusChange: (hasFocus) async {
                            if (hasFocus) await _scrollToBottomOnKeyboardOpen();
                          },
                          onSubmit: (enteredOtp) async {
                            otpController = enteredOtp;
                            debugPrint("OTP ----->>>>>>>>> $enteredOtp");
                          },
                        ),
                        const SizedBox(height: 50),
                        Center(
                          child: EasyContainer(
                            width: 150,
                            color: ColorUtils.oXFF6750A4,
                            borderRadius: 50,
                            onTap: () async {
                              final verified = await controller.verifyOtp(otpController);
                              if (verified) {
                              } else {}
                            },
                            child: Text(
                              TextUtils.verifyTxt,
                              style: FontUtils.h18(fontColor: ColorUtils.whiteColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
