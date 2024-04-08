import 'package:crud/screens/verify_phone_number_screen.dart';
import 'package:crud/utils/colors_utils.dart';
import 'package:crud/utils/common_string.dart';
import 'package:crud/utils/font_utils.dart';
import 'package:crud/utils/helpers.dart';
import 'package:easy_container/easy_container.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class AuthenticationScreen extends StatefulWidget {
  static const id = 'AuthenticationScreen';

  const AuthenticationScreen({
    Key? key,
  }) : super(key: key);

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  String? phoneNumber;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                TextUtils.continuewithTxt,
                style: FontUtils.h24(fontWeight: FWT.medium),
              ),
              const SizedBox(height: 15),
              EasyContainer(
                elevation: 0,
                borderRadius: 10,
                color: Colors.transparent,
                child: Form(
                  key: _formKey,
                  child: IntlPhoneField(
                    autofocus: true,
                    showCountryFlag: false,
                    initialCountryCode: 'IN',
                    showDropdownIcon: false,
                    flagsButtonPadding: const EdgeInsets.only(left: 10),
                    decoration: InputDecoration(
                      labelText: TextUtils.phoneNumberTxt,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                    ),
                    languageCode: "en",
                    onChanged: (phone) => phoneNumber = phone.completeNumber,
                    onCountryChanged: (country) {
                      debugPrint('Country changed to: ${country.name}');
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),
              EasyContainer(
                width: 150,
                color:  ColorUtils.oXFF6750A4,
                borderRadius: 50,
                onTap: () async {
                  if (isNullOrBlank(phoneNumber) || !_formKey.currentState!.validate()) {
                    showSnackBar('Please enter a valid phone number!');
                  } else {
                    Navigator.pushNamed(
                      context,
                      VerifyPhoneNumberScreen.id,
                      arguments: phoneNumber,
                    );
                  }
                },
                child: Text(
                  TextUtils.continueTxt,
                  style: FontUtils.h18(fontColor: ColorUtils.whiteColor)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}