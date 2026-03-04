import 'package:country_pickers/country.dart';
import 'package:flutter/material.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';

Widget rBuildCountryPickerDropdown({
  bool filtered = false,
  bool sortedByIsoCode = false,
  bool hasPriorityList = false,
  bool hasSelectedItemBuilder = false,
  required BuildContext context,
  required TextEditingController textEditingControllerPhoneNumber,
  required Function onCountryPicked,
}) {
  double dropdownButtonWidth = MediaQuery.of(context).size.width * 0.5;
  //respect dropdown button icon size
  double dropdownItemWidth = dropdownButtonWidth - 30;
  double dropdownSelectedItemWidth = dropdownButtonWidth - 30;
  return Container(
    decoration: BoxDecoration(
      // color: Colors.grey,
      borderRadius: BorderRadius.circular(
        8.0,
      ),
      border: Border.all(
        color: Colors.grey,
      ),
    ),
    child: Row(
      children: <Widget>[
        const SizedBox(
          width: 16,
        ),
        CountryPickerDropdown(
          /* underline: Container(
              height: 2,
              color: Colors.red,
            ),*/
          //show'em (the text fields) you're in charge now
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          //if you have menu items of varying size, itemHeight being null respects
          //that, IntrinsicHeight under the hood ;).
          itemHeight: null,
          //itemHeight being null and isDense being true doesn't play along
          //well together. One is trying to limit size and other is saying
          //limit is the sky, therefore conflicts.
          //false is default but still keep that in mind.
          isDense: false,
          //if you want your dropdown button's selected item UI to be different
          //than itemBuilder's(dropdown menu item UI), then provide this selectedItemBuilder.
          selectedItemBuilder: hasSelectedItemBuilder == true
              ? (Country country) => _buildDropdownSelectedItemBuilder(
                  country, dropdownSelectedItemWidth)
              : null,
          itemBuilder: (Country country) => hasSelectedItemBuilder == true
              ? _buildDropdownItemWithLongText(country, dropdownItemWidth)
              : _buildDropdownItem(country, dropdownItemWidth),
          initialValue: 'BD',
          // itemFilter: filtered
          //     ? (c) => ['AR', 'DE', 'GB', 'CN'].contains(c.isoCode)
          //     : null,
          //priorityList is shown at the beginning of list
          // priorityList: hasPriorityList
          //     ? [
          //         CountryPickerUtils.getCountryByIsoCode('BD'),
          //         CountryPickerUtils.getCountryByIsoCode('IN'),
          //       ]
          //     : null,
          sortComparator: sortedByIsoCode
              ? (Country a, Country b) => a.isoCode.compareTo(b.isoCode)
              : null,
          onValuePicked: (Country country) {
            onCountryPicked(country);
          },
        ),
        const SizedBox(
          width: 8.0,
        ),
        Expanded(
          child: TextField(
            controller: textEditingControllerPhoneNumber,
            decoration: const InputDecoration(
              hintText: "Phone Number",
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.number,
          ),
        )
      ],
    ),
  );
}

Widget _buildDropdownItem(Country country, double dropdownItemWidth) =>
    SizedBox(
      width: 110,
      child: Row(
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          const SizedBox(
            width: 8.0,
          ),
          Expanded(child: Text("+${country.phoneCode}")),
        ],
      ),
    );

Widget _buildDropdownItemWithLongText(
        Country country, double dropdownItemWidth) =>
    SizedBox(
      width: dropdownItemWidth,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            CountryPickerUtils.getDefaultFlagImage(country),
            const SizedBox(
              width: 8.0,
            ),
            Expanded(child: Text("${country.name}")),
          ],
        ),
      ),
    );

Widget _buildDropdownSelectedItemBuilder(
        Country country, double dropdownItemWidth) =>
    SizedBox(
        width: dropdownItemWidth,
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                CountryPickerUtils.getDefaultFlagImage(country),
                const SizedBox(
                  width: 8.0,
                ),
                Expanded(
                    child: Text(
                  '${country.name}',
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                )),
              ],
            )));

// Dialog
Widget buildCountryPickerDialogItem(
        {required Country country,
        bool showAsSelected = false,
        TextEditingController? textEditingControllerPhoneNumber}) =>
    Row(
      children: <Widget>[
        CountryPickerUtils.getDefaultFlagImage(country),
        const SizedBox(width: 8.0),
        Text("(${country.isoCode}) +${country.phoneCode}"),
        !showAsSelected ? const SizedBox(width: 8.0) : Container(),
        !showAsSelected ? Flexible(child: Text(country.name)) : Container(),
        showAsSelected
            ? const Text(
                '   ▾   ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              )
            : Container(),
        showAsSelected
            ? Expanded(
                child: TextField(
                  controller: textEditingControllerPhoneNumber,
                  decoration: const InputDecoration(
                    hintText: "Phone Number",
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.number,
                ),
              )
            : Container(),
      ],
    );

void openCountryPickerDialog({
  required BuildContext context,
  AuthController? authController,
}) =>
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(primaryColor: Colors.pink),
        child: CountryPickerDialog(
          titlePadding: const EdgeInsets.all(8.0),
          searchCursorColor: Colors.pinkAccent,
          searchInputDecoration: const InputDecoration(hintText: 'Search...'),
          isSearchable: true,
          title: const Text('Select your phone code'),
          onValuePicked: (Country country) =>
              authController?.setCountryPicked(country),
          itemBuilder: (country) =>
              buildCountryPickerDialogItem(country: country),
          priorityList: [
            CountryPickerUtils.getCountryByPhoneCode('880'),
            // CountryPickerUtils.getCountryByIsoCode('US'),
          ],
        ),
      ),
    );
