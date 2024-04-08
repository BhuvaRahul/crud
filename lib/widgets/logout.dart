import 'package:crud/utils/common_string.dart';
import 'package:flutter/material.dart';

class LogoutDialog extends StatelessWidget {
  void Function()? onPressed;
  LogoutDialog({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(TextUtils.logoutTxt),
      content: Text(TextUtils.logout1Txt),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text(TextUtils.cancelTxt),
        ),
        TextButton(
          onPressed: onPressed ??
              () {
                Navigator.of(context).pop(); // Close the dialog
              },
          child: Text(TextUtils.logoutTxt),
        ),
      ],
    );
  }
}
