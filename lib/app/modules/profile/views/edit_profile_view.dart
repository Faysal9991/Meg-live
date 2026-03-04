import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/widgets/circle_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/profile/controllers/profile_controller.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});
  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final ProfileController _profileController = Get.put(ProfileController());
  final AuthController _authController = Get.find();

  late TextEditingController _editingControllerFullName;
  // late String _countryCode, _countryName;

  @override
  void initState() {
    super.initState();
    _profileController.clearUploadedFiles();
    _editingControllerFullName = TextEditingController();
    _editingControllerFullName.text = _authController.profile.value.full_name!;
  }

  @override
  void dispose() {
    _editingControllerFullName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(
        () => LoadingOverlay(
          isLoading: _profileController.loadingProfile.value,
          // opacity: 0.8,
          progressIndicator: SpinKitThreeInOut(
            color: Theme.of(context).primaryColor,
            size: 50.0,
          ),
          child: Scaffold(
            appBar: AppBar(title: const Text('Edit profile')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 180,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.0),
                                  border: Border.all(
                                    width: 4,
                                    color: Colors.orange,
                                  ),
                                ),
                                child: Obx(() {
                                  if (_profileController
                                          .selectedProfileImageFile
                                          .value
                                          .path !=
                                      '') {
                                    return CircleAvatar(
                                      backgroundColor: Colors.blueGrey,
                                      backgroundImage: FileImage(
                                        _profileController
                                            .selectedProfileImageFile
                                            .value,
                                      ),
                                      radius: 80,
                                    );
                                  } else if (_authController
                                          .profile
                                          .value
                                          .profile_image !=
                                      null) {
                                    return CircleAvatar(
                                      backgroundColor: Colors.blueGrey,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                            _authController
                                                .profile
                                                .value
                                                .profile_image!,
                                          ),
                                      radius: 80,
                                    );
                                  }
                                  return const CircleAvatar(
                                    backgroundColor: Colors.blueGrey,
                                    backgroundImage: AssetImage(
                                      'assets/others/person.jpg',
                                    ),
                                    radius: 80,
                                  );
                                }),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 120,
                            left: 130,
                            right: 0,
                            child: Center(
                              child: CircleButton(
                                icon: MdiIcons.camera,
                                iconSize: 20.0,
                                iconColor: Colors.white,
                                backgroundColor: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(.9),
                                onPressed: () async {
                                  // Profile Image
                                  FilePickerResult? result = await FilePicker
                                      .platform
                                      .pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: [
                                          'jpg',
                                          'jpeg',
                                          'png',
                                          'gif',
                                          'tiff',
                                        ],
                                      );

                                  if (result != null) {
                                    PlatformFile file = result.files.first;
                                    // _fileExtension = file.extension;
                                    File imageFile = File(file.path!);
                                    // CroppedFile? croppedFile =
                                    //     await ImageCropper().cropImage(
                                    //   sourcePath: imageFile.path,
                                    //   aspectRatio: const CropAspectRatio(
                                    //       ratioX: 1, ratioY: 1),
                                    // );
                                    // if (croppedFile != null) {
                                    //   imageFile = File(croppedFile.path);
                                    // }

                                    _profileController.putPageProfileImage(
                                      file: imageFile,
                                      extension: file.extension!,
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    rPrimaryTextField(
                      controller: _editingControllerFullName,
                      keyboardType: TextInputType.name,
                      borderColor: Colors.black45,
                      hintText: 'Your full name',
                      maxLength: 25,
                    ),
                    const SizedBox(height: 16),
                    rPrimaryElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        String fullName = _editingControllerFullName.text
                            .trim();

                        // if (fullName.isNotEmpty && emailAddress.isNotEmpty) {
                        if (fullName.isNotEmpty) {
                          if (fullName.length > 25) {
                            Get.snackbar(
                              'Failed',
                              "Your name must be in 25 characters long.",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                            );
                            return;
                          }
                          _profileController.tryToUpdateProfile(
                            fullName: fullName,
                          );
                        }
                      },
                      primaryColor: Theme.of(context).primaryColor,
                      buttonText: 'SAVE CHANGES',
                      fontSize: 14.0,
                      borderRadius: 8.0,
                      fixedSize: Size(
                        MediaQuery.of(context).size.width - 32,
                        46,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
