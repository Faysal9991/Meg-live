import 'package:doyel_live/app/routes/app_pages.dart';
import 'package:doyel_live/app/widgets/country_phone_code_widget.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class RegistrationView extends StatefulWidget {
  const RegistrationView({Key? key}) : super(key: key);

  @override
  State<RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  final AuthController _authController = Get.find();

  final TextEditingController _editingControllerName = TextEditingController();

  final TextEditingController _editingControllerPhoneNumber =
      TextEditingController();

  final TextEditingController _editingControllerPassword =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Future.delayed(Duration.zero, () {
    //   _authController.setVisibilitySignUpPassword(false);
    // });
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 64,
                  ),
                  Center(
                    child: Image.asset(
                      'assets/logos/doyel_live.jpeg',
                      width: 130,
                      height: 130,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  const Center(
                    child: Text(
                      'Your Phone!',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                  ),
                  showSignUpFormWidget(context),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget showSignUpFormWidget(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 16,
        ),
        rPrimaryTextField(
          controller: _editingControllerName,
          keyboardType: TextInputType.name,
          borderColor: Colors.grey,
          hintText: 'Enter your name !!',
        ),
        const SizedBox(
          height: 16,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Container(
            decoration: BoxDecoration(
              // color: Colors.grey,
              borderRadius: BorderRadius.circular(
                8.0,
              ),
              border: Border.all(
                color: Colors.grey,
              ),
            ),
            child: ListTile(
              dense: true,
              onTap: () => openCountryPickerDialog(
                context: context,
                authController: _authController,
              ),
              title: Obx(
                () {
                  return buildCountryPickerDialogItem(
                    country: _authController.country.value,
                    showAsSelected: true,
                    textEditingControllerPhoneNumber:
                        _editingControllerPhoneNumber,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        rPrimaryTextField(
          controller: _editingControllerPassword,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          borderColor: Colors.grey,
          hintText: 'Enter password',
        ),
        Obx(() {
          if (!_authController.authLoading.value) {
            return Container();
          }
          return const SpinKitFadingCircle(
            color: Colors.orange,
            size: 48.0,
          );
        }),
        const SizedBox(
          height: 16,
        ),
        rPrimaryElevatedButton(
          onPressed: () async {
            if (_authController.authLoading.value) {
              return;
            }

            FocusScope.of(context).unfocus();
            String fullName = _editingControllerName.text.trim();
            String phoneNumber = _editingControllerPhoneNumber.text.trim();
            String password = _editingControllerPassword.text.trim();

            if (fullName.isNotEmpty &&
                phoneNumber.isNotEmpty &&
                // emailAddress.isNotEmpty &&
                password.isNotEmpty) {
              if (password.length < 8) {
                Get.snackbar(
                  'Failed',
                  "Password length must be at least 8 characters long.",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              // ${country.phoneCode} ${country.name} ${country.isoCode} ${country.iso3Code}
              if (_authController.country.value.isoCode == 'BD') {
                // Bangladeshi mobile number
                phoneNumber = int.parse(phoneNumber).toString();
                if (phoneNumber.length < 10 || !phoneNumber.startsWith('1')) {
                  Get.snackbar(
                    'Failed',
                    "${_authController.country.value.name} mobile number is incorrect.",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }
              }
              _authController.tryToSingInWithPassword(
                fullName: fullName,
                mobileNumber:
                    '+${_authController.country.value.phoneCode}$phoneNumber',
                phoneCode: _authController.country.value.phoneCode,
                password: password,
              );
            } else {
              Get.snackbar(
                'Failed',
                "All fields are required.",
                backgroundColor: Colors.red,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
          primaryColor: Theme.of(context).primaryColor,
          buttonText: 'LOGIN',
          fontSize: 16.0,
          fixedSize: Size(
            MediaQuery.of(context).size.width - 21,
            46,
          ),
          borderRadius: 8.0,
        ),
      ],
    );
  }
}
