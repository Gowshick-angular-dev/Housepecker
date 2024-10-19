import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

import '../../../../app/routes.dart';
import '../../../../data/Repositories/property_repository.dart';
import '../../../../data/Repositories/system_repository.dart';
import '../../../../data/model/category.dart';
import '../../../../data/model/property_model.dart';
import '../../../../utils/AppIcon.dart';
import '../../../../utils/Extensions/extensions.dart';
import '../../../../utils/api.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/guestChecker.dart';
import '../../../../utils/helper_utils.dart';
import '../../../../utils/hive_utils.dart';
import '../../../../utils/imagePicker.dart';
import '../../../../utils/responsiveSize.dart';
import '../../../../utils/ui_utils.dart';
import '../../widgets/AnimatedRoutes/blur_page_route.dart';
import '../../widgets/blurred_dialoge_box.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../widgets/panaroma_image_view.dart';
import '../../widgets/propert_text_form_field.dart';

class AddPropertyDetails extends StatefulWidget {
  final Map? propertyDetails;
  final int catid;

  const AddPropertyDetails(
      {super.key, this.propertyDetails, required this.catid});

  static Route route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return AddPropertyDetails(
          propertyDetails: arguments?['details'],
          catid: 1,
        );
      },
    );
  }

  @override
  State<AddPropertyDetails> createState() => _AddPropertyDetailsState();
}

class _AddPropertyDetailsState extends State<AddPropertyDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  String PropertyTyperole = '';
  String? selectedDuration;

  int remainFreeProPost = 0;
  String selectedRole = 'Free Listing';
  int? selectedPackage = 0;
  int freeDuration = 0;

  FocusNode placesFocusNode = FocusNode();

  late final TextEditingController _propertyNameController =
      TextEditingController(text: widget.propertyDetails?['name']);
  late final TextEditingController _reraController =
      TextEditingController(text: widget.propertyDetails?['rera']);
  late final TextEditingController _FLoorController =
      TextEditingController(text: widget.propertyDetails?['']);
  late final TextEditingController _sqftController =
      TextEditingController(text: widget.propertyDetails?['sqft'].toString());
  late final TextEditingController _highlightController =
      TextEditingController(text: widget.propertyDetails?['highlight']);
  late final TextEditingController _brokerageControler =
      TextEditingController(text: widget.propertyDetails?['brokerage']);
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.propertyDetails?['desc']);
  late final TextEditingController _cityNameController =
      TextEditingController(text: widget.propertyDetails?['city']);
  late final TextEditingController _stateNameController =
      TextEditingController(text: widget.propertyDetails?['state']);
  late final TextEditingController _countryNameController =
      TextEditingController(text: widget.propertyDetails?['country']);
  late final TextEditingController _latitudeController =
      TextEditingController(text: widget.propertyDetails?['latitude']);
  late final TextEditingController _longitudeController =
      TextEditingController(text: widget.propertyDetails?['longitude']);
  late final TextEditingController _addressController =
      TextEditingController(text: widget.propertyDetails?['address']);
  late final TextEditingController _priceController =
      TextEditingController(text: widget.propertyDetails?['price']);
  late final TextEditingController _clientAddressController =
      TextEditingController(text: widget.propertyDetails?['client']);

  late final TextEditingController _videoLinkController =
      TextEditingController();

  ///META DETAILS
  late final TextEditingController metaTitleController =
      TextEditingController(text: widget.propertyDetails?['metaTitle']);
  late final TextEditingController metaDescriptionController =
      TextEditingController(text: widget.propertyDetails?['metaDescription']);
  late final TextEditingController metaKeywordController =
      TextEditingController(text: widget.propertyDetails?['metaKeywords']);

  ///
  Map propertyData = {};
  final PickImage _pickTitleImage = PickImage();
  final PickImage _propertiesImagePicker = PickImage();
  final PickImage _pick360deg = PickImage();
  final PickImage _pickMetaTitle = PickImage();
  List editPropertyImageList = [];
  String titleImageURL = "";
  String selectedRentType = "Monthly";
  List removedImageId = [];
  List amenityList = [];
  List selectedAmenities = [];
  List amenities = [];

  bool loading = false;
  List packages = [];

  List<dynamic> mixedPropertyImageList = [];

  @override
  void initState() {
    print("dddddddd${widget.propertyDetails}");
    getAmenityList();
    getPackages();
    print(
        'THe selected Property Details ................................................${widget.propertyDetails?['id']}');
    titleImageURL = widget.propertyDetails?['titleImage'] ?? "";
    mixedPropertyImageList =
        List<dynamic>.from(widget.propertyDetails?['images'] ?? []);
    if ((widget.propertyDetails != null)) {
      selectedRentType = widget.propertyDetails?['rentduration'] ?? "Monthly";
    }

    _propertiesImagePicker.listener((images) {
      try {
        mixedPropertyImageList.addAll(List<dynamic>.from(images));
      } catch (e) {}

      setState(() {});
    });
    _pickTitleImage.listener((p0) {
      titleImageURL = "";
      WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
        if (mounted) setState(() {});
      });
    });
    super.initState();
  }

  Future<void> getPackages() async {
    try {
      setState(() {
        loading = true;
      });

      final SystemRepository _systemRepository = SystemRepository();
      Map settings =
          await _systemRepository.fetchSystemSettings(isAnonymouse: false);

      List allPacks = settings['data']['package']['user_purchased_package'];
      Map freepackage = settings['data']['free_package'];

      if (freepackage != null) {
        setState(() {
          remainFreeProPost = freepackage['property_limit'] -
              freepackage['used_property_limit'];
        });
      }

      // print('dflksndlsdgkdsg${allPacks}');

      List temp = [];
      if (settings['data']['package'] != null && allPacks != null) {
        for (int i = 0; i < allPacks.length; i++) {
          print(
              'hhhhhhhhhhhhhhhhhhhhhhhhhhh2: ${allPacks[i]['used_limit_for_project']}, ${allPacks[i]['package']['project_limit']}');

          if (((allPacks[i]['package']['project_limit'] ?? 0) -
                  (allPacks[i]['used_limit_for_project'] ?? 0)) >
              0) {
            temp.add(allPacks[i]);
          }
        }
      }
      setState(() {
        packages = temp;
        print('dfsdklgnsdlgnsdlkgn${packages}');
      });

      // Update state with the filtered packages
    } catch (e, stacktrace) {
      // Handle any error that occurs in the try block
      print('An error occurred: $e');
      print('Stacktrace: $stacktrace');

      // Optionally, you can show an error message to the user using a Snackbar or AlertDialog
    } finally {
      // Stop loading, whether an error occurred or not
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> getAmenityList() async {
    var response = await Api.get(url: Api.getAmenities, queryParameters: {
      'post': '1'
    });
    if (!response['error']) {
      setState(() {
        amenityList = response['data'];
      });
    }
  }

  void _onTapChooseLocation(FormFieldState state) async {
    FocusManager.instance.primaryFocus?.unfocus();
    Map? placeMark =
        await Navigator.pushNamed(context, Routes.chooseLocaitonMap) as Map?;
    var latlng = placeMark?['latlng'] as LatLng?;
    Placemark? place = placeMark?['place'] as Placemark?;
    if (latlng != null && place != null) {
      _latitudeController.text = latlng.latitude.toString();
      _longitudeController.text = latlng.longitude.toString();
      _cityNameController.text = place.locality ?? "";
      _countryNameController.text = place.country ?? "";
      _stateNameController.text = place.administrativeArea ?? "";
      _addressController.text = "";
      _addressController.text = getAddress(place);

      state.didChange(true);
    } else {
      // state.didChange(false);
    }
  }

  String getAddress(Placemark place) {
    try {
      String address = "";
      if (place.street == null && place.subLocality != null) {
        address = place.subLocality!;
      } else if (place.street == null && place.subLocality == null) {
        address = "";
      } else {
        address = "${place.street ?? ""},${place.subLocality ?? ""}";
      }

      return address;
    } catch (e, st) {
      throw Exception("$st");
    }
  }

  void _onTapContinue() async {
    File? titleImage;
    File? v360Image;
    File? metaTitle;

    if (_pickTitleImage.pickedFile != null) {
      titleImage = _pickTitleImage.pickedFile;
    }

    if (_pick360deg.pickedFile != null) {
      v360Image = _pick360deg.pickedFile;
    }

    if (_pickMetaTitle.pickedFile != null) {
      metaTitle = _pickMetaTitle.pickedFile;
    }

    // if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      bool check = _checkIfLocationIsChosen();
      if (check == false) {
        Future.delayed(Duration.zero, () {
          UiUtils.showBlurredDialoge(
            context,
            sigmaX: 5,
            sigmaY: 5,
            dialoge: BlurredDialogBox(
              svgImagePath: AppIcons.warning,
              title: UiUtils.getTranslatedLabel(context, "incomplete"),
              showCancleButton: false,
              onAccept: () async {},
              acceptTextColor: context.color.buttonColor,
              content: Text(
                UiUtils.getTranslatedLabel(context, "addressError"),
              ),
            ),
          );
        });

        return;
      } else if (titleImage == null && titleImageURL == "") {
        Future.delayed(Duration.zero, () {
          UiUtils.showBlurredDialoge(context,
              sigmaX: 5,
              sigmaY: 5,
              dialoge: BlurredDialogBox(
                svgImagePath: AppIcons.warning,
                title: UiUtils.getTranslatedLabel(context, "incomplete"),
                showCancleButton: false,
                acceptTextColor: context.color.buttonColor,
                onAccept: () async {
                  // Navigator.pop(context);
                },
                content: Text(
                  UiUtils.getTranslatedLabel(context, "uploadImgMsgLbl"),
                ),
              ));
        });
        return;
      } else if (selectedRole != 'Free Listing') {
        if (selectedPackage == null && remainFreeProPost == 0) {
          Future.delayed(Duration.zero, () {
            UiUtils.showBlurredDialoge(context,
                sigmaX: 5,
                sigmaY: 5,
                dialoge: BlurredDialogBox(
                  svgImagePath: AppIcons.warning,
                  title: UiUtils.getTranslatedLabel(context, "incomplete"),
                  showCancleButton: false,
                  acceptTextColor: context.color.buttonColor,
                  onAccept: () async {
                    // Navigator.pop(context);
                  },
                  content: const Text(
                    "Select a package to continue",
                  ),
                ));
          });
          return;
        }
      } else if (_propertyNameController.text == '' || PropertyTyperole == '' ||  _priceController.text == ''
          || _descriptionController.text == '' || _sqftController.text == '' || _priceController.text == '' ||
          _FLoorController.text == '' || _cityNameController.text == '' || _stateNameController.text == '' ||
          _countryNameController.text == '' || _latitudeController.text == '' || _longitudeController.text == ''
          || _addressController.text == '') {
        Future.delayed(Duration.zero, () {
          UiUtils.showBlurredDialoge(context,
              sigmaX: 5,
              sigmaY: 5,
              dialoge: BlurredDialogBox(
                svgImagePath: AppIcons.warning,
                title: UiUtils.getTranslatedLabel(context, "incomplete"),
                showCancleButton: false,
                acceptTextColor: context.color.buttonColor,
                onAccept: () async {
                  // Navigator.pop(context);
                },
                content: Text("",
                ),
              ));
        });
        return;
      }

    var list = mixedPropertyImageList.map((e) {
        if (e is File) {
          return e;
        }
      }).toList()
        ..removeWhere((element) => element == null);

      // return;

      propertyData.addAll({
        'userid': HiveUtils.getUserId(),
        'package_id': selectedPackage.toString(),
        "title": _propertyNameController.text,
        "rera": _reraController.text,
        "sqft": _sqftController.text,
        "highlight": _highlightController.text,
        "brokerage": _brokerageControler.text,
        "description": _descriptionController.text,
        "city": _cityNameController.text,
        "state": _stateNameController.text,
        "country": _countryNameController.text,
        "latitude": _latitudeController.text,
        "longitude": _longitudeController.text,
        "address": _addressController.text,
        "client_address": _clientAddressController.text,
        "price": _priceController.text,
        "floor": _FLoorController.text,
        "title_image": titleImage,
        "gallery_images": list,
        "remove_gallery_images": removedImageId,
        "amenity_id": selectedAmenities.map((item) => item['id']).toList(),
        "category_id": widget.propertyDetails == null
            ? (Constant.addProperty['category'] as Category).id
            : widget.propertyDetails?['catId'],
        "property_type": PropertyTyperole == 'Rent/Lease' ? '1' : '0',
        "threeD_image": v360Image,
        "video_link": _videoLinkController.text,
        "meta_image": metaTitle,
        if ((widget.propertyDetails == null
                    ? (Constant.addProperty['propertyType'] as PropertyType)
                        .name
                    : widget.propertyDetails?['propType'])
                .toString()
                .toLowerCase() ==
            "rent")
        "rentduration": selectedRentType,
        "meta_title": metaTitleController.text,
        "meta_description": metaDescriptionController.text,
        "meta_keywords": metaKeywordController.text
      });

      if (widget.propertyDetails?.containsKey("assign_facilities") ?? false) {
        propertyData?["assign_facilities"] =
            widget.propertyDetails!['assign_facilities'];
      }
      if (widget.propertyDetails != null) {
        propertyData['id'] = widget.propertyDetails?['id'];
        propertyData['action_type'] = "0";
      }

      Future.delayed(
        Duration.zero,
        () {
          _pickTitleImage.pauseSubscription();

          Navigator.pushNamed(
            context,
            Routes.setPropertyParametersScreen,
            arguments: {
              "details": propertyData,
              "isUpdate": (widget.propertyDetails != null)
            },
          ).then((value) {
            _pickTitleImage.resumeSubscription();
          });
        },
      );
    // }
  }

  bool _checkIfLocationIsChosen() {
    if (_cityNameController.text == "" ||
        _stateNameController.text == "" ||
        _countryNameController.text == "" ||
        _latitudeController.text == "" ||
        _longitudeController.text == "") {
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    _highlightController.dispose();
    _sqftController.dispose();
    _reraController.dispose();
    _FLoorController.dispose();
    _brokerageControler.dispose();
    _descriptionController.dispose();
    _cityNameController.dispose();
    _stateNameController.dispose();
    _countryNameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _clientAddressController.dispose();
    _videoLinkController.dispose();
    _pick360deg.dispose();
    _pickTitleImage.dispose();
    _propertiesImagePicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: UiUtils.buildButton(context,
              onPressed: _onTapContinue,
              height: 48.rh(context),
              fontSize: context.font.large,
              buttonTitle: UiUtils.getTranslatedLabel(context, "next")),
        ),
      ),
      appBar: UiUtils.buildAppBar(
        context,
        title: widget.propertyDetails == null
            ? UiUtils.getTranslatedLabel(context, "Add Post")
            : UiUtils.getTranslatedLabel(context, "updateProperty"),
        actions: const [
          Text(
            "2/4",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            width: 14,
          ),
        ],
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Property Details",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 15),
                  // if(!widget.isEdit)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Continue With",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: " *",
                              style: TextStyle(
                                  color:
                                      Colors.red), // Customize asterisk color
                            ),
                          ],
                        ),
                      ),
                      if (selectedRole == 'Free Listing' && !loading)
                        Text(
                          remainFreeProPost > 0
                              ? "Note: This post is valid for $freeDuration days from the date of posting."
                              : "Free Listing limit exceeded.",
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      const SizedBox(height: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display loader if data is being fetched
                          if (loading) // Assuming 'isLoading' is a boolean to track the loading state
                            Center(
                              child: const CupertinoActivityIndicator(
                                radius:
                                    8, // You can adjust the size of the loader here
                              ),
                            )
                          else ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    height: size.height * 0.06,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      children: [
                                        Radio<String>(
                                          activeColor: Colors.blue,
                                          value: 'Free Listing',
                                          groupValue: selectedRole,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedRole = value!;
                                              selectedPackage = 0;
                                            });
                                          },
                                        ),
                                        Text(
                                          "Free Listing (${remainFreeProPost})",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Container(
                                    height: size.height * 0.06,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      children: [
                                        Radio<String>(
                                          activeColor: Colors.blue,
                                          value: 'Package',
                                          groupValue: selectedRole,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedRole = value!;
                                            });
                                          },
                                        ),
                                        const Text(
                                          "Package",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            if (selectedRole == 'Package') ...[
                              const SizedBox(height: 15),
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Package",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    TextSpan(
                                      text: " *",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (packages.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.only(
                                      top: 10, right: 10, left: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color(0xffe5e5e5), width: 1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    children: [
                                      // Expanded(
                                      //   child: MultiSelectDropDown(
                                      //     onOptionSelected: (List<ValueItem> selectedOptions) {
                                      //       setState(() {
                                      //         selectedPackage = int.parse(selectedOptions[0].value!);
                                      //       });
                                      //     },
                                      //     options: [
                                      //       for (int i = 0; i < packages.length; i++)
                                      //         ValueItem(
                                      //           label: '${packages[i]['package']['name']}, Listing (${packages[i]['package']['project_limit']}), Units (${packages[i]['package']['no_of_units'] ?? 0}), Valid until (${DateFormat('dd MMM yyyy').format(DateTime.parse(packages[i]['end_date']))})',
                                      //           value: '${packages[i]['package']['id']}',
                                      //         ),
                                      //     ],
                                      //     selectionType: SelectionType.single,
                                      //     chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                                      //     dropdownHeight: 300,
                                      //     optionTextStyle: const TextStyle(fontSize: 16),
                                      //     selectedOptionIcon: const Icon(Icons.check_circle),
                                      //   ),
                                      // ),
                                      for (int i = 0; i < packages.length; i++)
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedPackage =
                                                  packages[i]['package']['id'];
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: selectedPackage !=
                                                        packages[i]['package']
                                                            ['id']
                                                    ? Color(0xfff9f9f9)
                                                    : Color(0xfffffbf3),
                                                border: Border.all(
                                                    color: selectedPackage !=
                                                            packages[i]
                                                                    ['package']
                                                                ['id']
                                                        ? Color(0xffe5e5e5)
                                                        : Color(0xffffa920),
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              // alignment: Alignment.center,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: 20,
                                                        width: 20,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: Color(
                                                                  0xffe5e5e5),
                                                              width: 1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        child: selectedPackage ==
                                                                packages[i][
                                                                        'package']
                                                                    ['id']
                                                            ? Container(
                                                                height: 10,
                                                                width: 10,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Color(
                                                                      0xffffa920),
                                                                  border: Border.all(
                                                                      color: Color(
                                                                          0xffffffff),
                                                                      width: 3),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15),
                                                                ),
                                                              )
                                                            : Container(),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                        packages[i]['package']
                                                            ['name'],
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xff646464),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Expanded(
                                                        child: Text(
                                                          'Total Listings',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Color(
                                                                0xff646464),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          ':  ${packages[i]['package']['advertisement_limit']}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 11,
                                                            color: Color(
                                                                0xff646464),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Expanded(
                                                        child: Text(
                                                          'Available Listings',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Color(
                                                                0xff646464),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          ':  ${packages[i]['package']['advertisement_limit'] - packages[i]['used_limit_for_advertisement']}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 11,
                                                            color: Color(
                                                                0xff646464),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Expanded(
                                                        child: Text(
                                                          'Valid until',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Color(
                                                                0xff646464),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          ':  ${DateFormat('dd MMM yyyy').format(DateTime.parse(packages[i]['end_date']))}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 11,
                                                            color: Color(
                                                                0xff646464),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              if (packages.isEmpty)
                                Column(
                                  children: [
                                    Text(
                                      'You dont have any active packages for post a project. If you want to buy click here!',
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        GuestChecker.check(onNotGuest: () {
                                          Navigator.pushNamed(
                                              context,
                                              Routes
                                                  .subscriptionPackageListRoute);
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            bottom: 10, left: 15, right: 15),
                                        width: double.infinity,
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Color(0xff117af9),
                                        ),
                                        child: Text(
                                          'Buy Subscription Plan',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (packages.isEmpty) const SizedBox(height: 10),
                            ],
                          ]
                        ],
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Property Type",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: " *",
                              style: TextStyle(
                                  color: Colors.red), // Customize asterisk color
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              height: size.height * 0.06,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    activeColor: Colors.blue,
                                    value: 'Sell',
                                    groupValue: PropertyTyperole,
                                    onChanged: (value) {
                                      setState(() {
                                        PropertyTyperole = value!;
                                      });
                                    },
                                  ),
                                  Text(
                                    "Sell",
                                    style: const TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Container(
                              height: size.height * 0.06,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    activeColor: Colors.blue,
                                    value: 'Rent/Lease',
                                    groupValue: PropertyTyperole,
                                    onChanged: (value) {
                                      setState(() {
                                        PropertyTyperole = value!;
                                      });
                                    },
                                  ),
                                  const Text(
                                    "Rent/Lease",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Title",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: " *",
                              style: TextStyle(
                                  color:
                                  Colors.red), // Customize asterisk color
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                      CustomTextFormField1(
                        controller: _propertyNameController,
                        // validator: CustomTextFieldValidator1.nullCheck,
                        action: TextInputAction.next,
                        hintText: UiUtils.getTranslatedLabel(
                            context, "propertyNameLbl"),
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((widget.propertyDetails == null
                          ? (Constant.addProperty['propertyType']
                      as PropertyType)
                          .name
                          : widget.propertyDetails?['propType'])
                          .toString()
                          .toLowerCase() ==
                          "rent") ...[
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Rent Price",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                    color: Colors.red), // Customize asterisk color
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Price",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                    color: Colors.red), // Customize asterisk color
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(
                        height: 10.rh(context),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextFormField1(
                              action: TextInputAction.next,
                              prefix: Text("${Constant.currencySymbol} ",
                              style: TextStyle(
                                  color: Color(0xff929292),
                                  fontSize: 13,
                                  fontFamily: 'Roboto'),
                              ),
                              controller: _priceController,
                              formaters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d*')),
                              ],
                              isReadOnly: false,
                              keyboard: TextInputType.number,
                              // validator: CustomTextFieldValidator1.nullCheck,
                              hintText: "Enter proprty price (₹)",
                            ),
                          ),
                          if ((widget.propertyDetails == null
                              ? (Constant.addProperty['propertyType']
                          as PropertyType)
                              .name
                              : widget.propertyDetails?['propType'])
                              .toString()
                              .toLowerCase() ==
                              "rent") ...[
                            const SizedBox(
                              width: 5,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: context.color.secondaryColor,
                                  border: Border.all(
                                      color: context.color.borderColor, width: 1.5),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(7.0),
                                child: DropdownButton<String>(
                                  value: selectedRentType,
                                  dropdownColor: context.color.primaryColor,
                                  underline: const SizedBox.shrink(),
                                  items: [
                                    DropdownMenuItem(
                                      value: "Daily",
                                      child: Text(
                                        "Daily".translate(context),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: "Monthly",
                                      child: Text("Monthly".translate(context)),
                                    ),
                                    DropdownMenuItem(
                                      value: "Quarterly",
                                      child: Text("Quarterly".translate(context)),
                                    ),
                                    DropdownMenuItem(
                                      value: "Yearly",
                                      child: Text("Yearly".translate(context)),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    selectedRentType = value ?? "";
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),
                  if (PropertyTyperole == 'Rent/Lease')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Rent Duration",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: " *",
                                style: TextStyle(
                                  color:
                                      Colors.red, // Customize asterisk color
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: 10), // Add spacing between text and dropdown
                        Container(
                          width: size.width,
                          height: 60,
                          padding: EdgeInsets.symmetric(
                              horizontal: 15), // Add horizontal padding
                          decoration: BoxDecoration(
                            color: Color(
                                0xFFf4f5f4), // Background color for the container
                            borderRadius:
                                BorderRadius.circular(8), // Rounded corners
                            // border: Border.all(color: Colors.grey), // Border styling
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              hint: Text('Select duration'),
                              value:
                                  selectedDuration, // Store selected value in a variable
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedDuration = newValue!;
                                });
                              },
                              items: <String>[
                                'Daily',
                                'Monthly',
                                'Quarterly',
                                'Yearly'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15.rh(context),
                        ),
                      ],
                    ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Description",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: " *",
                              style: TextStyle(
                                  color: Colors.red), // Customize asterisk color
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                      CustomTextFormField1(
                        action: TextInputAction.next,
                        controller: _descriptionController,
                        // validator: CustomTextFieldValidator1.nullCheck,
                        hintText: UiUtils.getTranslatedLabel(context, "writeSomething"),
                        maxLine: 100,
                        minLine: 6,
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Text("More Information",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('RERA No.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),),
                      SizedBox(
                        height: 10,
                      ),
                      CustomTextFormField1(
                        controller: _reraController,
                        action: TextInputAction.next,
                        hintText: 'RERA No.',
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Size(Sq.Ft)",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: " *",
                              style: TextStyle(
                                  color: Colors.red), // Customize asterisk color
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      CustomTextFormField1(
                        controller: _sqftController,
                        // validator: CustomTextFieldValidator1.nullCheck,
                        action: TextInputAction.next,
                        hintText: 'Property Area',
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Brokerage",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: " *",
                              style: TextStyle(
                                  color:
                                  Colors.red), // Customize asterisk color
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: MultiSelectDropDown(
                              onOptionSelected:
                                  (List<ValueItem> selectedOptions) {
                                setState(() {
                                  _brokerageControler.text =
                                  selectedOptions[0].value!;
                                });
                              },
                              options: [
                                const ValueItem(label: "Yes", value: "yes"),
                                const ValueItem(label: "No", value: "no"),
                              ],
                              selectionType: SelectionType.single,
                              chipConfig:
                              const ChipConfig(wrapType: WrapType.wrap),
                              dropdownHeight: 300,
                              optionTextStyle: const TextStyle(fontSize: 16),
                              selectedOptionIcon:
                              const Icon(Icons.check_circle),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Property Highlights",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: '  (Note: Add highlights using commas ",")',
                              style: TextStyle(color: Colors.red, fontSize: 11), // Customize asterisk color
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                      CustomTextFormField1(
                        controller: _highlightController,
                        // validator: CustomTextFieldValidator1.nullCheck,
                        action: TextInputAction.next,
                        hintText: 'Highlights',
                        minLine: 4,
                        maxLine: 4,
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Floor No",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: " *",
                              style: TextStyle(
                                  color: Colors.red), // Customize asterisk color
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                      CustomTextFormField1(
                        controller: _FLoorController,
                        // validator: CustomTextFieldValidator1.nullCheck,
                        action: TextInputAction.next,
                        hintText: '0',
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),



                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 25),
                      const Text("Amenities",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Wrap(
                        children: List.generate((amenityList!.length), (index) {
                          return Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: GestureDetector(
                              onTap: () {
                                if (selectedAmenities.any((item) =>
                                    item['id'].toString() ==
                                    amenityList![index]['id'].toString())) {
                                  selectedAmenities.removeWhere((element) =>
                                      element['id'] ==
                                      amenityList![index]['id']);
                                  amenities.removeWhere((element) =>
                                      element['facility_id'] ==
                                      amenityList![index]['id']);
                                  setState(() {});
                                } else {
                                  selectedAmenities.add(amenityList![index]);
                                  amenities.add({
                                    'amenity_id': amenityList![index]['id'],
                                  });
                                  setState(() {});
                                }
                              },
                              child: Chip(
                                  avatar: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: SvgPicture.network(
                                      amenityList![index]['image'],
                                      width: 18.0,
                                      height: 18.0,
                                      fit: BoxFit.cover,
                                      color: context.color.tertiaryColor
                                    ),
                                  ),
                                  shape: StadiumBorder(
                                      side: BorderSide(
                                          color: selectedAmenities.any((item) =>
                                                  item['id'] ==
                                                  amenityList![index]['id'])
                                              ? const Color(0xffffa920)
                                              : const Color(0xffd9d9d9))),
                                  backgroundColor: selectedAmenities.any(
                                          (item) =>
                                              item['id'] ==
                                              amenityList![index]['id'])
                                      ? const Color(0xfffffbf3)
                                      : const Color(0xfff2f2f2),
                                  padding: const EdgeInsets.all(1),
                                  label: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8, bottom: 8, right: 8),
                                      child: Text(
                                        '${amenityList![index]['name']}',
                                        style: const TextStyle(
                                          color: Color(0xff333333),
                                          fontSize: 11,
                                        ),
                                      ))),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                  
                  

                  // SizedBox(
                  //   height: 35.rh(context),
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.max,
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       Expanded(
                  //         flex: 3,
                  //         child: RichText(
                  //           text: const TextSpan(
                  //             children: [
                  //               TextSpan(
                  //                 text: "Address",
                  //                 style: TextStyle(
                  //                     color: Colors.black,
                  //                     fontSize: 15,
                  //                     fontWeight: FontWeight.w400),
                  //               ),
                  //               TextSpan(
                  //                 text: " *",
                  //                 style: TextStyle(
                  //                     color: Colors
                  //                         .red), // Customize asterisk color
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //       // const Spacer(),
                  //       // Expanded(
                  //       //   flex: 3,
                  //       //   child: ChooseLocationFormField(
                  //       //     initialValue: false,
                  //       //     validator: (bool? value) {
                  //       //       //Check if it has already data so we will not validate it.
                  //       //       if ((widget.propertyDetails != null)) {
                  //       //         return null;
                  //       //       }
                  //       //
                  //       //       if (value == true) {
                  //       //         return null;
                  //       //       } else {
                  //       //         return "Select location";
                  //       //       }
                  //       //     },
                  //       //     build: (state) {
                  //       //       return Container(
                  //       //         decoration: BoxDecoration(
                  //       //             // color: context.color.teritoryColor,
                  //       //             border: Border.all(
                  //       //                 width: 1.5,
                  //       //                 color: state.hasError
                  //       //                     ? Colors.red
                  //       //                     : Colors.transparent),
                  //       //             borderRadius: BorderRadius.circular(9)),
                  //       //         child: MaterialButton(
                  //       //             height: 30,
                  //       //             onPressed: () {
                  //       //               _onTapChooseLocation.call(state);
                  //       //             },
                  //       //             child: FittedBox(
                  //       //               fit: BoxFit.fitWidth,
                  //       //               child: Row(
                  //       //                 mainAxisSize: MainAxisSize.min,
                  //       //                 children: [
                  //       //                   Image.asset(
                  //       //                     "assets/AddPostforms/_-98.png",
                  //       //                     width: 15,
                  //       //                     height: 15,
                  //       //                     fit: BoxFit.cover,
                  //       //                   ),
                  //       //                   // UiUtils.getSvg(AppIcons.location,
                  //       //                   //     color:
                  //       //                   //         context.color.textLightColor),
                  //       //                   const SizedBox(
                  //       //                     width: 3,
                  //       //                   ),
                  //       //                   Text(
                  //       //                     UiUtils.getTranslatedLabel(
                  //       //                         context, "chooseLocation"),
                  //       //                   ).size(12).color(
                  //       //                       context.color.tertiaryColor),
                  //       //                 ],
                  //       //               ),
                  //       //             )),
                  //       //       );
                  //       //     },
                  //       //   ),
                  //       // )
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 25),
                  const Text("Location",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Address",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: " *",
                          style: TextStyle(
                              color: Colors.red), // Customize asterisk color
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  Container(
                    height: 60,
                    child: GooglePlaceAutoCompleteTextField(
                      textEditingController: _addressController,
                      focusNode: placesFocusNode,
                      inputDecoration: const InputDecoration(
                          hintText: 'Enter location..',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.0,
                            color: Color(0xff9c9c9c),
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              )
                          )
                      ),
                      googleAPIKey: "AIzaSyDDJ17OjVJ0TS2qYt7GMOnrMjAu1CYZFg8",
                      debounceTime: 800,
                      countries: ["in"],
                      isLatLngRequired: true,
                      getPlaceDetailWithLatLng: (Prediction prediction) {
                        print("placeDetails" + prediction.lng.toString());
                        _latitudeController.text = prediction.lat.toString();
                        _longitudeController.text = prediction.lng.toString();
                        setState(() { });
                      },
                      itemClick: (Prediction prediction) {
                        _addressController.text = prediction.description!;
                        _addressController.selection =
                            TextSelection.fromPosition(TextPosition(
                                offset: prediction.description!.length));
                        print('yyyyyyyyyyyyyyyyyyyyyyyyyy: ${prediction.lat}, ${prediction.lng}');
                        List address = prediction.description!.split(',').reversed.toList();
                        if(address.length >= 3) {
                          _cityNameController.text = address[2];
                          _stateNameController.text = address[1];
                          _countryNameController.text = address[0];
                          setState(() { });
                        } else if(address.length == 2) {
                          _cityNameController.text = address[1];
                          _stateNameController.text = address[1];
                          _countryNameController.text = address[0];
                          setState(() { });
                        } else if(address.length == 1) {
                          _cityNameController.text = address[0];
                          _stateNameController.text = address[0];
                          _countryNameController.text = address[0];
                          setState(() { });
                        } else if(address.length == 0) {
                          _cityNameController.text = '';
                          _stateNameController.text = '';
                          _countryNameController.text = '';
                          setState(() { });
                        }
                        // cityControler.text = place.locality ?? '';
                        // StateController.text = place.administrativeArea ?? '';
                        // ContryControler.text = place.country ?? '';
                        // setState(() { });
                        // getAddressFromLatLng(prediction.placeId);
                      },
                      itemBuilder: (context, index, Prediction prediction) {
                        return Container(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Icon(Icons.location_on),
                              SizedBox(
                                width: 7,
                              ),
                              Expanded(
                                  child:
                                  Text("${prediction.description ?? ""}"))
                            ],
                          ),
                        );
                      },
                      seperatedBuilder: Divider(),
                      isCrossBtnShown: true,
                      containerHorizontalPadding: 10,
                      placeType: PlaceType.geocode,
                    ),
                  ),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  CustomTextFormField1(
                    action: TextInputAction.next,
                    controller: _cityNameController,
                    isReadOnly: true,
                    // validator: CustomTextFieldValidator1.nullCheck,
                    hintText: UiUtils.getTranslatedLabel(context, "city"),
                  ),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  CustomTextFormField1(
                    action: TextInputAction.next,
                    controller: _stateNameController,
                    isReadOnly: true,
                    // validator: CustomTextFieldValidator1.nullCheck,
                    hintText: UiUtils.getTranslatedLabel(context, "state"),
                  ),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  CustomTextFormField1(
                    action: TextInputAction.next,
                    controller: _countryNameController,
                    isReadOnly: true,
                    // validator: CustomTextFieldValidator1.nullCheck,
                    hintText: UiUtils.getTranslatedLabel(context, "country"),
                  ),
                  SizedBox(
                    height: 10.rh(context),
                  ),
                  CustomTextFormField1(
                    action: TextInputAction.next,
                    controller: _addressController,
                    isReadOnly: true,
                    hintText: UiUtils.getTranslatedLabel(context, "addressLbl"),
                    maxLine: 100,
                    // validator: CustomTextFieldValidator1.nullCheck,
                    minLine: 4,
                  ),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.end,
                  //   children: [
                  //     Row(
                  //       mainAxisAlignment: MainAxisAlignment.end,
                  //       children: [
                  //         Image.asset(
                  //           "assets/AddPostforms/_-98.png",
                  //           width: 15,
                  //           height: 15,
                  //           fit: BoxFit.cover,
                  //         ),
                  //         TextButton(
                  //             onPressed: () {
                  //               _clientAddressController.clear();
                  //               _clientAddressController.text =
                  //                   HiveUtils.getUserDetails().address ?? "";
                  //             },
                  //             style: ButtonStyle(
                  //                 overlayColor: MaterialStatePropertyAll(context
                  //                     .color.tertiaryColor
                  //                     .withOpacity(0.3))),
                  //             child: Text("useYourLocation".translate(context))
                  //                 .size(12)
                  //                 .color(context.color.tertiaryColor)),
                  //       ],
                  //     ),
                  //     CustomTextFormField1(
                  //       action: TextInputAction.next,
                  //       controller: _clientAddressController,
                  //       validator: CustomTextFieldValidator1.nullCheck,
                  //       hintText: UiUtils.getTranslatedLabel(
                  //           context, "clientaddressLbl"),
                  //       maxLine: 100,
                  //       minLine: 4,
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(
                  //   height: 10.rh(context),
                  // ),

                  const SizedBox(height: 25),
                  const Text("Images & Video",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Title Image",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: " *",
                              style: TextStyle(
                                  color: Colors.red), // Customize asterisk color
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10.rh(context),
                      ),
                      Wrap(
                        children: [
                          if (_pickTitleImage.pickedFile != null) ...[] else ...[],
                          titleImageListener(),
                        ],
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Gallary",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: " *",
                              style: TextStyle(
                                  color: Colors.red), // Customize asterisk color
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10.rh(context),
                      ),
                      propertyImagesListener(),
                      SizedBox(
                        height: 10.rh(context),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Video Link',
                          style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 10.rh(context),
                      ),
                      CustomTextFormField1(
                        controller: _videoLinkController,
                        hintText: "http://example.com/video.mp4",
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),
                  // GestureDetector(
                  //   onTap: () {
                  //     _pick360deg.pick(pickMultiple: false);
                  //   },
                  //   child: Container(
                  //     clipBehavior: Clip.antiAlias,
                  //     decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(10),
                  //         color: const Color(0xfff8f9ff),
                  //         border: Border.all(
                  //             width: 1, color: const Color(0xff6aabfb))),
                  //     alignment: Alignment.center,
                  //     height: 65.rh(context),
                  //     width: 65.rh(context),
                  //     child: Center(
                  //         child: Image.asset(
                  //       "assets/AddPostforms/_-100.png",
                  //       width: 25,
                  //       height: 25,
                  //     )),
                  //   ),
                  // ),
                  // _pick360deg.listenChangesInUI((context, image) {
                  //   if (image != null) {
                  //     return Stack(
                  //       children: [
                  //         Container(
                  //             width: 65,
                  //             height: 65,
                  //             margin: const EdgeInsets.only(right: 5, top: 5),
                  //             clipBehavior: Clip.antiAlias,
                  //             decoration: BoxDecoration(
                  //                 borderRadius: BorderRadius.circular(10)),
                  //             child: Image.file(
                  //               image,
                  //               fit: BoxFit.cover,
                  //             )),
                  //         Positioned.fill(
                  //           child: GestureDetector(
                  //             onTap: () {
                  //               Navigator.push(context, BlurredRouter(
                  //                 builder: (context) {
                  //                   return PanaromaImageScreen(
                  //                     imageUrl: image.path,
                  //                     isFileImage: true,
                  //                   );
                  //                 },
                  //               ));
                  //             },
                  //             child: Container(
                  //               width: 65,
                  //               margin: const EdgeInsets.only(right: 5, top: 5),
                  //               height: 65,
                  //               decoration: BoxDecoration(
                  //                   color:
                  //                       context.color.tertiaryColor.withOpacity(
                  //                     0.68,
                  //                   ),
                  //                   borderRadius: BorderRadius.circular(10)),
                  //               child: FittedBox(
                  //                 fit: BoxFit.none,
                  //                 child: Container(
                  //                   decoration: BoxDecoration(
                  //                     shape: BoxShape.circle,
                  //                     color: context.color.secondaryColor,
                  //                   ),
                  //                   width: 60.rw(context),
                  //                   height: 60.rh(context),
                  //                   child: Center(
                  //                     child: Column(
                  //                       mainAxisSize: MainAxisSize.min,
                  //                       children: [
                  //                         SizedBox(
                  //                             height: 30.rh(context),
                  //                             width: 40.rw(context),
                  //                             child: UiUtils.getSvg(
                  //                                 AppIcons.v360Degree,
                  //                                 color: context
                  //                                     .color.textColorDark)),
                  //                         Text(UiUtils.getTranslatedLabel(
                  //                                 context, "view"))
                  //                             .color(
                  //                                 context.color.textColorDark)
                  //                             .size(context.font.small)
                  //                             .bold()
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     );
                  //   }
                  //
                  //   return Container();
                  // }),
                  // SizedBox(
                  //   height: 15.rh(context),
                  // ),





                  const SizedBox(height: 25),
                  const Text("SEO Settings",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 15.rh(context),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Meta Title',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 10.rh(context),
                      ),
                      CustomTextFormField1(
                        controller: metaTitleController,
                        validator: CustomTextFieldValidator1.nullCheck,
                        hintText: "Title".translate(context),
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text("metaTitleLength".translate(context))
                            .size(context.font.small - 1.5)
                            .color(Colors.red),
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Meta Keyword',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 10.rh(context),
                      ),
                      CustomTextFormField1(
                        controller: metaKeywordController,
                        hintText: "Keywords".translate(context),
                        validator: CustomTextFieldValidator1.nullCheck,
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text("metaKeywordsLength".translate(context))
                            .size(context.font.small - 1.5)
                            .color(Colors.red),
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Og Image',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 10.rh(context),
                      ),
                      GestureDetector(
                        onTap: () {
                          _pickMetaTitle.pick(pickMultiple: false);
                        },
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xfff8f9ff),
                              border: Border.all(
                                  width: 1, color: const Color(0xff6aabfb))),
                          alignment: Alignment.center,
                          height: 65.rh(context),
                          width: 65.rh(context),
                          child: Center(
                              child: Image.asset(
                                "assets/AddPostforms/_-100.png",
                                width: 25,
                                height: 25,
                              )),
                        ),
                      ),
                      _pickMetaTitle.listenChangesInUI((context, image) {
                        if (image != null) {
                          return Container(
                              width: 65,
                              height: 65,
                              margin: const EdgeInsets.only(right: 5, top: 5),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Image.file(
                                image,
                                fit: BoxFit.cover,
                              ));
                        }

                        return Container();
                      }),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Meta Description',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 10.rh(context),
                      ),
                      CustomTextFormField1(
                        controller: metaDescriptionController,
                        validator: CustomTextFieldValidator1.nullCheck,
                        hintText: "Description".translate(context),
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text("metaDescriptionLength".translate(context))
                            .size(context.font.small - 1.5)
                            .color(Colors.red),
                      ),
                      SizedBox(
                        height: 15.rh(context),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 30,
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget propertyImagesListener() {
    return _propertiesImagePicker.listenChangesInUI((context, file) {
      Widget current = Container();

      current = Wrap(
          children: mixedPropertyImageList
              .map((image) {
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HelperUtils.unfocus();
                        if (image is String) {
                          UiUtils.showFullScreenImage(context,
                              provider: NetworkImage(image));
                        } else {
                          UiUtils.showFullScreenImage(context,
                              provider: FileImage(image));
                        }
                      },
                      child: Container(
                          width: 65,
                          height: 65,
                          margin: const EdgeInsets.only(right: 5, bottom: 5),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ImageAdapter(
                            image: image,
                          )),
                    ),

                    // Positioned(
                    //   right: 5,
                    //   top: 5,
                    //   child: Container(
                    //       width: 100,
                    //       height: 100,
                    //       margin: const EdgeInsets.all(5),
                    //       clipBehavior: Clip.antiAlias,
                    //       decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(10)),
                    //       child: Icon(Icons.close)),
                    // ),
                    closeButton(context, () {
                      mixedPropertyImageList.remove(image);

                      if (image is String) {
                        List<Gallery> properyDetail =
                            widget.propertyDetails?['gallary_with_id']
                                as List<Gallery>;
                        var id = properyDetail
                            .where((element) => element.imageUrl == image)
                            .first
                            .id;

                        removedImageId.add(id);
                      }
                      setState(() {});
                    }),

                    // child: GestureDetector(
                    //   onTap: () {
                    //     mixedPropertyImageList.remove(image);
                    //     // removedImageId.add();
                    //
                    //     setState(() {});
                    //   },
                    //   child: Icon(
                    //     Icons.close,
                    //     color: context.color.secondaryColor,
                    //   ),
                    // ),
                    // )
                  ],
                );
              })
              .toList()
              .cast<Widget>());

      // if (propertyImageList.isEmpty && editPropertyImageList.isNotEmpty) {
      //   current = Wrap(
      //       children: editPropertyImageList
      //           .map((image) {
      //             log(image.runtimeType.toString());
      //             return Stack(
      //               children: [
      //                 GestureDetector(
      //                   onTap: () {
      //                     HelperUtils.unfocus();
      //                     UiUtils.showFullScreenImage(context,
      //                         provider: FileImage(image));
      //                   },
      //                   child: Container(
      //                       width: 100,
      //                       height: 100,
      //                       margin: const EdgeInsets.all(5),
      //                       clipBehavior: Clip.antiAlias,
      //                       decoration: BoxDecoration(
      //                           borderRadius: BorderRadius.circular(10)),
      //                       child: Image.network(
      //                         image,
      //                         fit: BoxFit.cover,
      //                       )),
      //                 ),
      //                 Positioned(
      //                   right: 5,
      //                   top: 5,
      //                   child: GestureDetector(
      //                     onTap: () {
      //                       editPropertyImageList.remove(image);
      //                       // removedImageId.add();
      //
      //                       setState(() {});
      //                     },
      //                     child: Icon(
      //                       Icons.close,
      //                       color: context.color.secondaryColor,
      //                     ),
      //                   ),
      //                 )
      //               ],
      //             );
      //           })
      //           .toList()
      //           .cast<Widget>());
      // }
      //
      // if (file is List<File>) {
      //   current = Wrap(
      //       children: propertyImageList
      //           .map((image) {
      //             return Stack(
      //               children: [
      //                 GestureDetector(
      //                   onTap: () {
      //                     HelperUtils.unfocus();
      //                     UiUtils.showFullScreenImage(context,
      //                         provider: FileImage(image));
      //                   },
      //                   child: Container(
      //                       width: 100,
      //                       height: 100,
      //                       margin: const EdgeInsets.all(5),
      //                       clipBehavior: Clip.antiAlias,
      //                       decoration: BoxDecoration(
      //                           borderRadius: BorderRadius.circular(10)),
      //                       child: Image.file(
      //                         image,
      //                         fit: BoxFit.cover,
      //                       )),
      //                 ),
      //                 closeButton(context, () {
      //                   propertyImageList.remove(image);
      //                   setState(() {});
      //                 })
      //               ],
      //             );
      //           })
      //           .toList()
      //           .cast<Widget>());
      // }

      return Wrap(
        runAlignment: WrapAlignment.start,
        children: [
          if (file == null && mixedPropertyImageList.isEmpty)
            GestureDetector(
              onTap: () {
                _propertiesImagePicker.pick(pickMultiple: true);
              },
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xfff8f9ff),
                    border:
                        Border.all(width: 1, color: const Color(0xff6aabfb))),
                alignment: Alignment.center,
                height: 65.rh(context),
                width: 65.rh(context),
                child: Center(
                    child: Image.asset(
                  "assets/AddPostforms/_-100.png",
                  width: 25,
                  height: 25,
                )),
              ),
            ),
          current,
          if (file != null || titleImageURL != "")
            uploadPhotoCard(context, onTap: () {
              _propertiesImagePicker.pick(pickMultiple: true);
            })
        ],
      );
    });
  }

  Widget titleImageListener() {
    return _pickTitleImage.listenChangesInUI((context, file) {
      Widget currentWidget = Container();
      if (titleImageURL != "") {
        currentWidget = GestureDetector(
          onTap: () {
            UiUtils.showFullScreenImage(context,
                provider: NetworkImage(titleImageURL));
          },
          child: Container(
            width: 65,
            height: 65,
            margin: const EdgeInsets.only(right: 5),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Image.network(
              titleImageURL,
              fit: BoxFit.cover,
            ),
          ),
        );
      }
      if (file is File) {
        currentWidget = GestureDetector(
          onTap: () {
            UiUtils.showFullScreenImage(context, provider: FileImage(file));
          },
          child: Column(
            children: [
              Container(
                  width: 65,
                  height: 65,
                  margin: const EdgeInsets.only(right: 5),
                  clipBehavior: Clip.antiAlias,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Image.file(
                    file,
                    fit: BoxFit.cover,
                  )),
            ],
          ),
        );
      }

      return Wrap(
        children: [
          if (file == null && titleImageURL == "")
            GestureDetector(
              onTap: () {
                _pickTitleImage.resumeSubscription();
                _pickTitleImage.pick(pickMultiple: false);
                _pickTitleImage.pauseSubscription();
                titleImageURL = "";
                setState(() {});
              },
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xfff8f9ff),
                    border:
                        Border.all(width: 1, color: const Color(0xff6aabfb))),
                alignment: Alignment.center,
                height: 65.rh(context),
                width: 65.rh(context),
                child: Center(
                    child: Image.asset(
                  "assets/AddPostforms/_-100.png",
                  width: 25,
                  height: 25,
                )),
              ),
            ),
          Stack(
            children: [
              currentWidget,
              closeButton(context, () {
                _pickTitleImage.clearImage();
                titleImageURL = "";
                setState(() {});
              })
            ],
          ),
          if (file != null || titleImageURL != "")
            uploadPhotoCard(context, onTap: () {
              _pickTitleImage.resumeSubscription();
              _pickTitleImage.pick(pickMultiple: false);
              _pickTitleImage.pauseSubscription();
              titleImageURL = "";
              setState(() {});
            })
          // GestureDetector(
          //   onTap: () {
          //     _pickTitleImage.resumeSubscription();
          //     _pickTitleImage.pick(pickMultiple: false);
          //     _pickTitleImage.pauseSubscription();
          //     titleImageURL = "";
          //     setState(() {});
          //   },
          //   child: Container(
          //     width: 100,
          //     height: 100,
          //     margin: const EdgeInsets.all(5),
          //     clipBehavior: Clip.antiAlias,
          //     decoration:
          //         BoxDecoration(borderRadius: BorderRadius.circular(10)),
          //     child: DottedBorder(
          //         borderType: BorderType.RRect,
          //         radius: Radius.circular(10),
          //         child: Container(
          //           alignment: Alignment.center,
          //           child: Text("Upload \n Photo"),
          //         )),
          //   ),
          // ),
        ],
      );
    });
  }
}

Widget uploadPhotoCard(BuildContext context, {required Function onTap}) {
  return GestureDetector(
    onTap: () {
      onTap.call();
    },
    child: Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xfff8f9ff),
          border: Border.all(width: 1, color: const Color(0xff6aabfb))),
      alignment: Alignment.center,
      height: 65.rh(context),
      width: 65.rh(context),
      child: Center(
          child: Image.asset(
        "assets/AddPostforms/_-100.png",
        width: 25,
        height: 25,
      )),
    ),
  );
}

PositionedDirectional closeButton(BuildContext context, Function onTap) {
  return PositionedDirectional(
    top: 6,
    end: 6,
    child: GestureDetector(
      onTap: () {
        onTap.call();
      },
      child: Container(
        decoration: BoxDecoration(
            color: context.color.primaryColor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10)),
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Icon(
            Icons.close,
            size: 24,
            color: Colors.black,
          ),
        ),
      ),
    ),
  );
}

class ChooseLocationFormField extends FormField<bool> {
  ChooseLocationFormField(
      {super.key,
      FormFieldSetter<bool>? onSaved,
      FormFieldValidator<bool>? validator,
      bool? initialValue,
      required Widget Function(FormFieldState<bool> state) build,
      bool autovalidateMode = false})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<bool> state) {
              return build(state);
            });
}

class ImageAdapter extends StatelessWidget {
  final dynamic image;
  ImageAdapter({super.key, this.image});

  @override
  Widget build(BuildContext context) {
    if (image is String) {
      return Image.network(
        image,
        fit: BoxFit.cover,
      );
    } else if (image is File) {
      return Image.file(
        image,
        fit: BoxFit.cover,
      );
    }
    return Container();
  }
}
