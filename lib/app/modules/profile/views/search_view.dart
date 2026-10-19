import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SearchView extends StatelessWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // const SpinKitFadingCube(
        //   color: Colors.orange,
        //   size: 48.0,
        // ),
        Image.asset('assets/logos/biho.png', width: 100, height: 100),
        const SizedBox(height: 32),
        Center(
          child: Text(
            'UNDER CONSTRUCTION',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
