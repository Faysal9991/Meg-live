import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/theme/app_radius.dart';
import 'package:doyel_live/app/widgets/app_design_widgets.dart';
import 'package:flutter/material.dart';

Color _resolveReadableForegroundColor({
  required Color backgroundColor,
  Color? requestedColor,
}) {
  if (requestedColor != null) {
    return requestedColor;
  }
  final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
  return brightness == Brightness.dark
      ? AppColors.onPrimary
      : AppColors.textPrimary;
}

Widget rPrimaryTextButton({
  required Color backgroundColor,
  required String buttonText,
  Color? buttonTextColor,
  double fontSize = 18.0,
  double borderRadius = AppRadius.button,
  required VoidCallback onPressed,
}) => PrimaryButton(
  label: buttonText,
  onPressed: onPressed,
  backgroundColor: backgroundColor,
  foregroundColor: buttonTextColor,
  fontSize: fontSize,
  borderRadius: borderRadius,
);

Widget rPrimaryTextField({
  required TextEditingController controller,
  obscureText = false,
  readOnly = false,
  required TextInputType keyboardType,
  required borderColor,
  fillColor = AppColors.surfaceInset,
  textColor = AppColors.textPrimary,
  helpTextColor = AppColors.textSecondary,
  prefixIcon,
  suffixIcon,
  hintText,
  labelText,
  maxLength,
  maxLines,
  prefixText,
  focusNode,
  double borderRadius = AppRadius.control,
  Function(String)? onChanged,
  bool useNeumorphic = true,
  EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 16,
  ),
}) {
  final field = TextField(
    controller: controller,
    focusNode: focusNode,
    obscureText: obscureText,
    autocorrect: !obscureText,
    enableSuggestions: !obscureText,
    readOnly: readOnly,
    keyboardType: keyboardType,
    maxLength: maxLength,
    maxLines: obscureText
        ? 1
        : (keyboardType == TextInputType.multiline && maxLines == null)
        ? null
        : maxLines ?? 1,
    style: TextStyle(color: textColor),
    decoration: InputDecoration(
      contentPadding: contentPadding,
      filled: true,
      fillColor: useNeumorphic ? AppColors.transparent : fillColor,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: useNeumorphic ? AppColors.transparent : borderColor,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(borderRadius),
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
  return useNeumorphic
      ? AppInsetSurface(color: fillColor, radius: borderRadius, child: field)
      : field;
}

Widget rPrimaryElevatedButton({
  required VoidCallback onPressed,
  required Color primaryColor,
  Size? fixedSize,
  required String buttonText,
  Color? buttonTextColor,
  required double fontSize,
  FontWeight? fontWeight,
  double? borderRadius = AppRadius.button,
}) {
  final resolvedTextColor = _resolveReadableForegroundColor(
    backgroundColor: primaryColor,
    requestedColor: buttonTextColor,
  );
  return PrimaryButton(
    label: buttonText,
    onPressed: onPressed,
    backgroundColor: primaryColor,
    foregroundColor: resolvedTextColor,
    fixedSize: fixedSize,
    fontSize: fontSize,
    fontWeight: fontWeight ?? FontWeight.w600,
    borderRadius: borderRadius!,
  );
}

Widget rPrimaryElevatedButton2({
  required VoidCallback onPressed,
  required Color primaryColor,
  Size? fixedSize,
  required String buttonText,
  Color? buttonTextColor,
  required double fontSize,
  FontWeight? fontWeight,
  double? borderRadius = AppRadius.button,
}) {
  final resolvedTextColor = _resolveReadableForegroundColor(
    backgroundColor: primaryColor,
    requestedColor: buttonTextColor,
  );
  return PrimaryButton(
    label: buttonText,
    onPressed: onPressed,
    backgroundColor: primaryColor,
    foregroundColor: resolvedTextColor,
    fixedSize: fixedSize,
    fontSize: fontSize,
    fontWeight: fontWeight ?? FontWeight.w600,
    borderRadius: borderRadius!,
    compact: true,
  );
}

Widget rPrimaryElevatedIconButton({
  required VoidCallback onPressed,
  required Color primaryColor,
  Size? fixedSize,
  required String buttonText,
  Color? buttonTextColor,
  required double fontSize,
  FontWeight? fontWeight,
  double? borderRadius = AppRadius.button,
  required IconData iconData,
}) {
  final resolvedTextColor = _resolveReadableForegroundColor(
    backgroundColor: primaryColor,
    requestedColor: buttonTextColor,
  );
  return PrimaryButton(
    label: buttonText,
    icon: iconData,
    onPressed: onPressed,
    backgroundColor: primaryColor,
    foregroundColor: resolvedTextColor,
    fixedSize: fixedSize,
    fontSize: fontSize,
    fontWeight: fontWeight ?? FontWeight.w600,
    borderRadius: borderRadius!,
  );
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> rShowSnackBar({
  required BuildContext context,
  required String title,
  required Color color,
  int? durationInSeconds,
}) => ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      title,
      style: TextStyle(
        color: _resolveReadableForegroundColor(backgroundColor: color),
      ),
    ),
    backgroundColor: color,
    duration: Duration(seconds: durationInSeconds ?? 4),
    behavior: SnackBarBehavior.floating,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
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
    actions: [cancelButton, continueButton],
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
    actions: [continueButton],
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
    child: const Text("OK", style: TextStyle(fontSize: 20)),
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title, style: const TextStyle(fontSize: 14)),
    content: Text(content, style: const TextStyle(fontSize: 12)),
    actions: [continueButton],
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
