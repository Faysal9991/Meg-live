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
      : AppColors.onLight;
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
  bool obscureText = false,
  bool readOnly = false,
  required TextInputType keyboardType,
  required Color borderColor,
  Color fillColor = AppColors.surfaceInset,
  Color textColor = AppColors.textPrimary,
  Color helpTextColor = AppColors.textSecondary,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? hintText,
  String? labelText,
  int? maxLength,
  int? minLines,
  int? maxLines,
  String? prefixText,
  FocusNode? focusNode,
  double borderRadius = AppRadius.control,
  Function(String)? onChanged,
  EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  ),
}) {
  final bool isMultiline =
      keyboardType == TextInputType.multiline && !obscureText;

  // Safe maxLines
  final int effectiveMaxLines = obscureText
      ? 1
      : (maxLines ?? (isMultiline ? 5 : 1));

  // Safe minLines
  final int requestedMinLines = obscureText
      ? 1
      : (minLines ?? 1);

  // Prevent:
  // minLines can't be greater than maxLines
  final int effectiveMinLines = requestedMinLines > effectiveMaxLines
      ? effectiveMaxLines
      : requestedMinLines;

  final field = TextField(
    controller: controller,
    focusNode: focusNode,

    obscureText: obscureText,
    autocorrect: !obscureText,
    enableSuggestions: !obscureText,

    readOnly: readOnly,
    keyboardType: keyboardType,

    maxLength: maxLength,

    minLines: effectiveMinLines,
    maxLines: effectiveMaxLines,

    textAlignVertical: isMultiline
        ? TextAlignVertical.top
        : TextAlignVertical.center,

    style: TextStyle(
      color: textColor,
      fontSize: 14,
      height: 1.3,
    ),

    decoration: InputDecoration(
      isDense: true,

      contentPadding: contentPadding,

      filled: true,
      fillColor: fillColor,

      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: borderColor,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),

      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),

      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: borderColor,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),

      prefixIcon: prefixIcon,
      prefixText: prefixText,
      suffixIcon: suffixIcon,

      labelText: labelText,
      hintText: hintText,

      alignLabelWithHint: isMultiline,

      helperStyle: TextStyle(
        color: helpTextColor,
      ),

      hintStyle: TextStyle(
        color: helpTextColor,
        fontSize: 14,
      ),

      counterStyle: TextStyle(
        color: helpTextColor,
        fontSize: 11,
      ),
    ),

    onChanged: onChanged,
  );

  return field;
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
