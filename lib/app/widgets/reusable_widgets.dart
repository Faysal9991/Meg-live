import 'package:flutter/material.dart';

Widget rPrimaryTextButton(
        {required backgroundColor,
        required buttonText,
        buttonTextColor = Colors.white,
        fontSize = 18.0,
        borderRadius = 10.0,
        required onPressed}) =>
    TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(buttonTextColor),
        backgroundColor: MaterialStateProperty.all<Color>(backgroundColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        )),
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          buttonText,
          style: TextStyle(fontSize: fontSize),
        ),
      ),
    );

Widget rPrimaryTextField({
  required controller,
  obscureText = false,
  readOnly = false,
  required keyboardType,
  required borderColor,
  fillColor = Colors.white,
  textColor = Colors.black,
  helpTextColor = Colors.black,
  prefixIcon,
  suffixIcon,
  hintText,
  labelText,
  maxLength,
  maxLines,
  prefixText,
  focusNode,
  double borderRadius = 8.0,
  Function(String)? onChanged,
  EdgeInsetsGeometry contentPadding =
      const EdgeInsets.symmetric(horizontal: 16),
}) =>
    TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: (keyboardType == TextInputType.multiline && maxLines == null)
          ? null
          : maxLines ?? 1,
      style: TextStyle(
        color: textColor,
      ),
      decoration: InputDecoration(
        contentPadding: contentPadding,
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
        prefixIcon: prefixIcon,
        prefixText: prefixText,
        suffixIcon: suffixIcon,
        labelText: labelText,
        hintText: hintText,
        helperStyle: TextStyle(color: helpTextColor),
        hintStyle: TextStyle(color: helpTextColor),
      ),
      onChanged: onChanged,
    );

Widget rPrimaryElevatedButton({
  required VoidCallback onPressed,
  required primaryColor,
  Size? fixedSize,
  required String buttonText,
  Color buttonTextColor = Colors.white,
  required double fontSize,
  FontWeight? fontWeight,
  double? borderRadius = 16.0,
}) =>
    ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        fixedSize: fixedSize,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius!),
          // side: BorderSide(color: Colors.red),
        ),
      ),
      child: Text(
        buttonText,
        style: TextStyle(
            fontSize: fontSize, fontWeight: fontWeight, color: buttonTextColor),
      ),
    );

Widget rPrimaryElevatedButton2({
  required VoidCallback onPressed,
  required primaryColor,
  Size? fixedSize,
  required String buttonText,
  Color buttonTextColor = Colors.white,
  required double fontSize,
  FontWeight? fontWeight,
  double? borderRadius = 16.0,
}) =>
    ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        backgroundColor: primaryColor,
        fixedSize: fixedSize,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius!),
          // side: BorderSide(color: Colors.red),
        ),
      ),
      child: Text(
        buttonText,
        style: TextStyle(
            fontSize: fontSize, fontWeight: fontWeight, color: buttonTextColor),
      ),
    );

Widget rPrimaryElevatedIconButton({
  required VoidCallback onPressed,
  required primaryColor,
  Size? fixedSize,
  required String buttonText,
  Color buttonTextColor = Colors.white,
  required double fontSize,
  FontWeight? fontWeight,
  double? borderRadius = 16.0,
  required IconData iconData,
}) =>
    ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        backgroundColor: primaryColor,
        fixedSize: fixedSize,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius!),
          // side: BorderSide(color: Colors.red),
        ),
      ),
      icon: Icon(iconData),
      label: Text(
        buttonText,
        style: TextStyle(
            fontSize: fontSize, fontWeight: fontWeight, color: buttonTextColor),
      ),
    );

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> rShowSnackBar(
        {required BuildContext context,
        required String title,
        required Color color,
        int? durationInSeconds}) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: color,
        duration: Duration(seconds: durationInSeconds ?? 4),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
      ),
    );

void rShowAlertDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
}) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: const Text("Cancel"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = TextButton(
    onPressed: onConfirm,
    child: const Text("OK"),
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void rShowAlertDialog2({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
}) {
  // set up the buttons

  Widget continueButton = TextButton(
    onPressed: onConfirm,
    child: const Text("OK"),
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void rShowAlertDialog3({
  required BuildContext context,
  required String title,
  required Widget content,
  required VoidCallback onConfirm,
}) {
  // set up the buttons
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    contentPadding: EdgeInsets.zero,
    alignment: Alignment.center,
    title: Text(title),
    content: content,
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void rShowMendatoryAlertDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
}) {
  // set up the buttons
  Widget continueButton = TextButton(
    onPressed: onConfirm,
    child: const Text(
      "OK",
      style: TextStyle(
        fontSize: 20,
      ),
    ),
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 14,
      ),
    ),
    content: Text(
      content,
      style: const TextStyle(
        fontSize: 12,
      ),
    ),
    actions: [
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
