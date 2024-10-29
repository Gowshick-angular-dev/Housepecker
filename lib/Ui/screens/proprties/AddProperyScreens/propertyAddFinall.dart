import 'dart:io';

import 'package:Housepecker/exports/main_export.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:Housepecker/utils/responsiveSize.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:latlong2/latlong.dart';
import 'package:http_parser/http_parser.dart' as h;
import 'package:mime/mime.dart';
import '../../../../app/routes.dart';
import '../../../../data/cubits/property/create_property_cubit.dart';
import '../../../../data/helper/widgets.dart';
import '../../../../data/model/property_model.dart';
import '../../../../utils/AppIcon.dart';
import '../../../../utils/api.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/helper_utils.dart';
import '../../../../utils/imagePicker.dart';
import '../../../../utils/ui_utils.dart';
import '../../widgets/AnimatedRoutes/scale_up_route.dart';
import '../../widgets/blurred_dialoge_box.dart';
import '../../widgets/propert_text_form_field.dart';
import '../Property tab/sell_rent_screen.dart';
import 'add_property_details.dart';

class PropertyPostFinalPage extends StatefulWidget {
  final Map? details;
  const PropertyPostFinalPage({this.details});
  @override
  _PropertyPostFinalPageState createState() => _PropertyPostFinalPageState();
}

class _PropertyPostFinalPageState extends State<PropertyPostFinalPage> {

  bool loading = false;
  List parameters = [];
  String titleImageURL = "";
  String metaImageURL = "";
  List amenityList = [];
  List selectedAmenities = [];
  List amenities = [];
  List removedImageId = [];
  List<dynamic> mixedPropertyImageList = [];

  final PickImage _pickMetaTitle = PickImage();
  final PickImage _pickTitleImage = PickImage();
  final PickImage _propertiesImagePicker = PickImage();

  late final TextEditingController _cityNameController =
  TextEditingController();
  late final TextEditingController _stateNameController =
  TextEditingController();
  late final TextEditingController _countryNameController =
  TextEditingController();
  late final TextEditingController _latitudeController =
  TextEditingController();
  late final TextEditingController _longitudeController =
  TextEditingController();
  late final TextEditingController _addressController =
  TextEditingController();
  late final TextEditingController _videoLinkController =
  TextEditingController();

  FocusNode placesFocusNode = FocusNode();

  ///META DETAILS
  late final TextEditingController metaTitleController =
  TextEditingController();
  late final TextEditingController metaDescriptionController =
  TextEditingController();
  late final TextEditingController metaKeywordController =
  TextEditingController();

  @override
  void initState() {
    // print('ttttttttttttttttttttttttttt: ${widget.details?['updateDetails']['gallery']}');
    getAmenityList();
    if(widget.details?['updateDetails'] != null) {
      _cityNameController.text = widget.details?['updateDetails']['city'] ?? '';
      _stateNameController.text = widget.details?['updateDetails']['state'] ?? '';
      _countryNameController.text = widget.details?['updateDetails']['country'] ?? '';
      _latitudeController.text = widget.details?['updateDetails']['latitude'] ?? '';
      _longitudeController.text = widget.details?['updateDetails']['longitude'] ?? '';
      _addressController.text = widget.details?['updateDetails']['address'] ?? '';
      _videoLinkController.text = widget.details?['updateDetails']['video_link'] ?? '';
      metaTitleController.text = widget.details?['updateDetails']['meta_title'] ?? '';
      metaDescriptionController.text = widget.details?['updateDetails']['meta_description'] ?? '';
      metaKeywordController.text = widget.details?['updateDetails']['meta_keywords'] ?? '';
      titleImageURL = widget.details?['updateDetails']['title_image'] ?? "";
      metaImageURL = widget.details?['updateDetails']['meta_image'] ?? "";
      if(widget.details?['updateDetails']['gallery'] != null && widget.details?['updateDetails']['gallery'].isNotEmpty) {
        print('888888888888888888888888: ${widget.details?['updateDetails']['gallery'].map((img) => img.imageUrl).toList()}');
        mixedPropertyImageList = widget.details?['updateDetails']['gallery'].map((img) => img.imageUrl).toList();
      }
      // mixedPropertyImageList = List<dynamic>.from(widget.details?['updateDetails']['gallery'] ?? []);
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

  Future<void> getAmenityList() async {
    var response = await Api.get(url: Api.getAmenities, queryParameters: {
      'post': '1'
    });
    if (!response['error']) {
      setState(() {
        amenityList = response['data'];
      });
      if(widget.details?['updateDetails'] != null) {
        print('uuuuuuuuuuuuuuuuuuuuuuuuuu');
        selectedAmenities = amenityList.where((item) => widget.details?['updateDetails']['amenity'].map((ame) => ame['id']).toList().contains(item['id'])).toList();
      }
    }
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

  void _onTapContinue() async {
    File? titleImage;
    File? metaTitle;

    if (_pickTitleImage.pickedFile != null) {
      titleImage = _pickTitleImage.pickedFile;
    }

    if (_pickMetaTitle.pickedFile != null) {
      metaTitle = _pickMetaTitle.pickedFile;
    }
    var list = mixedPropertyImageList.map((e) {
      if (e is File) {
        return e;
      }
    }).toList()
      ..removeWhere((element) => element == null);

    bool check = _checkIfLocationIsChosen();

    if(_cityNameController.text == '' || _stateNameController.text == '' || _countryNameController.text == ''
        || _latitudeController.text == '' || _longitudeController.text == '' || _addressController.text == ''
        || (titleImage == null && titleImageURL == "") || check == false) {
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
              content: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Please fill all the "',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: "*",
                      style: TextStyle(
                          color:
                          Colors.red), // Customize asterisk color
                    ),
                    TextSpan(
                      text: '" fields!',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ));
      });
      return;
    }

    setState(() {
      loading = true;
    });

    List gallery = [];
    await Future.forEach(
      list,
          (dynamic item) async {
        var multipartFile = await MultipartFile.fromFile(item.path);
        if (!multipartFile.isFinalized) {
          gallery.add(multipartFile);
        }
      },
    );

    Map<String, dynamic> propertyReqData = {
      ...widget.details!,
      "city": _cityNameController.text,
      "state": _stateNameController.text,
      "country": _countryNameController.text,
      "latitude": _latitudeController.text,
      "longitude": _longitudeController.text,
      "address": _addressController.text,
      "title_image": titleImage != null ? await MultipartFile.fromFile(
          (titleImage as File).path,
          contentType: h.MediaType('image', lookupMimeType((titleImage as File).path)!.split("/")[1]),
          filename: (titleImage as File).path.split("/").last) : null,
      "gallery_images": gallery,
      "remove_gallery_images": removedImageId,
      "amenity_id": selectedAmenities.map((item) => item['id']).toList(),
      "video_link": _videoLinkController.text,
      "meta_image": metaTitle != null ? await MultipartFile.fromFile(
          (metaTitle as File).path,
          contentType: h.MediaType('image', lookupMimeType((metaTitle as File).path)!.split("/")[1]),
          filename: (metaTitle as File).path.split("/").last) : null,
      "meta_title": metaTitleController.text,
      "meta_description": metaDescriptionController.text,
      "meta_keywords": metaKeywordController.text,
    };

    _pickTitleImage.pauseSubscription();
    propertyReqData
      ..remove("isUpdate")
      ..remove("updateDetails");

    await context
        .read<CreatePropertyCubit>()
        .create(parameters: propertyReqData);
    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    _cityNameController.dispose();
    _stateNameController.dispose();
    _countryNameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _addressController.dispose();
    _videoLinkController.dispose();
    _pickTitleImage.dispose();
    _propertiesImagePicker.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiUtils.buildAppBar(context,
        title: widget.details!['isUpdate'] ? 'Edit Property' : 'Post Properties',
        showBackButton: true,
      ),
      bottomNavigationBar: !loading ? Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: UiUtils.buildButton(context,
              onPressed: _onTapContinue,
              height: 48.rh(context),
              fontSize: context.font.large,
              buttonTitle: UiUtils.getTranslatedLabel(context, "Submit")),
        ),
      ) : Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: UiUtils.buildButton(context,
              onPressed: () { },
              height: 48.rh(context),
              fontSize: context.font.large,
              buttonTitle: UiUtils.getTranslatedLabel(context, "Please Wait...")),
        ),
      ),
      body: BlocListener<CreatePropertyCubit, CreatePropertyState>(
        listener: (context, state) {
          if (state is CreatePropertyInProgress) {
            Widgets.showLoader(context);
          }

          if (state is CreatePropertyFailure) {
            Widgets.hideLoder(context);
            HelperUtils.showSnackBarMessage(context, state.errorMessage);
          }

          if (state is CreatePropertySuccess) {
            Widgets.hideLoder(context);
              context.read<PropertyEditCubit>().add(state.propertyModel!);
              context
                  .read<FetchMyPropertiesCubit>()
                  .update(state.propertyModel!);
              cubitReference?.update(state.propertyModel!);
              HelperUtils.showSnackBarMessage(context,
                  widget.details!['isUpdate'] ? 'Property Updated Successfully!' : 'Property Posted Successfully!',
                  type: MessageType.success, onClose: () {
                    Navigator.of(context)..pop()..pop()..pop()..pop(); });
            Future.delayed(Duration.zero, () {
              Navigator.of(context)
                  .pushReplacementNamed(Routes.main, arguments: {'from': "main"});
            });
            }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Text('${widget.details?['updateDetails']}'),
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
                        metaImageURL = '';
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
                    if(metaImageURL != '')
                      Container(
                        width: 65,
                        height: 65,
                        margin: const EdgeInsets.only(right: 5, top: 5),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        child: Image.network(
                          metaImageURL,
                          fit: BoxFit.cover,
                      )),
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
                            text: "Gallery",
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

              ],
            ),
          ),
        ),
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
                    border: Border.all(width: 1, color: const Color(0xff6aabfb))
                ),
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
                    widget.details?['gallary_with_id']
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
}
