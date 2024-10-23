
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:Housepecker/Ui/screens/projects/projectAdd2.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:video_compress/video_compress.dart';

import '../../../app/routes.dart';
import '../../../data/helper/designs.dart';
import '../../../utils/api.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import '../../../utils/ui_utils.dart';
import '../Loan/LoanList.dart';
import '../widgets/image_cropper.dart';
import '../widgets/shimmerLoadingContainer.dart';

class ProjectFormFive extends StatefulWidget {
  final Map? body;
  final bool? isEdit;
  final Map? data;
  const ProjectFormFive({super.key, this.body, this.isEdit, this.data});

  @override
  State<ProjectFormFive> createState() => _ProjectFormFiveState();
}

class _ProjectFormFiveState extends State<ProjectFormFive> {

  List<File> gallary = [];
  Map? reqBody;
  List gallaryEdit = [];
  List gallaryImages = [];
  bool loading = false;
  final int _sizeLimit = 2 * 1024 * 1024;
  List<Map<String, dynamic>> floorDetails = [
    {
      'title': TextEditingController(),
      'document': null,
      'id': null,
      'name': ''
    }
  ];
  MediaInfo? _compressedVideo;
  bool compressing = false;
  File? broucher;
  File? pricePlan;
  File? metaImage;
  File? coverImage;
  TextEditingController videoControler = TextEditingController();
  TextEditingController metaTitleControler = TextEditingController();
  TextEditingController metaDescControler = TextEditingController();
  TextEditingController metaKeywordControler = TextEditingController();

  @override
  void initState() {
    if(widget.isEdit!) {
      videoControler.text = widget.data!['video_link'] ?? '';
      metaTitleControler.text = widget.data!['meta_title'] ?? '';
      metaDescControler.text = widget.data!['meta_description'] ?? '';
      metaKeywordControler.text = widget.data!['meta_keywords'] ?? '';
      gallaryEdit = widget.data!['gallary_images'] ?? '';
      // broucher = File(widget.data!['documents']![0]['name']);

      List<Map<String, dynamic>> floorPlans = [];
      for(int i = 0; i < widget.data!['plans'].length; i++) {
        floorPlans.add({
          'title': TextEditingController(text: widget.data!['plans'][i]['title']),
          'document': null,
          'id': widget.data!['plans'][i]['id'],
          'name': widget.data!['plans'][i]['document'].split('/').last
        });
      }
      floorDetails = floorPlans;
      setState(() {});
    }
    super.initState();
  }

  _imgFromGallery() async {
    var images = await ImagePicker().pickMultiImage();
    if (images.length > 0) {
      for(int i = 0; i < images.length; i++) {
        int fileSize = await images[i].length();
        if(fileSize < _sizeLimit) {
          gallary.add(File(images[i].path));
          gallaryImages.add(await MultipartFile.fromFile(File(images[i].path).path));
          setState(() {});
        } else {
          HelperUtils.showSnackBarMessage(
              context, UiUtils.getTranslatedLabel(
              context, "Large images were eliminated"),
              type: MessageType.warning, messageDuration: 3);
        }
      }
    } else {
      gallary = [];
    }
    setState(() {});
  }

  metaFromGallery() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    int fileSize = await image!.length();
    if(fileSize < _sizeLimit) {
      metaImage = File(image.path);
      setState(() {});
    } else {
      HelperUtils.showSnackBarMessage(
          context, UiUtils.getTranslatedLabel(
          context, "Upload image size below 2mb!"),
          type: MessageType.warning, messageDuration: 3);
    }
  }

  coverFromGallery() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    int fileSize = await image!.length();
    if(fileSize < _sizeLimit) {
      coverImage = File(image!.path);
      setState(() {});
    } else {
      HelperUtils.showSnackBarMessage(
          context, UiUtils.getTranslatedLabel(
          context, "Upload image size below 2mb!"),
          type: MessageType.warning, messageDuration: 3);
    }
  }

  Future<File> floorPlanImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    return File(image!.path);
  }

  void showPicker() {
    showModalBottomSheet(
        context: context,
        shape: setRoundedBorder(10),
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: Text("Gallery"),
                    onTap: () {
                      videoFromGallery(ImageSource.gallery);
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: Text(UiUtils.getTranslatedLabel(context, "camera")),
                  onTap: () {
                    videoFromGallery(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  videoFromGallery(source) async {
    CropImage.init(context);
    var video = await ImagePicker().pickVideo(source: source);
    if (video != null) {
      setState(() {
        compressing = true;
      });
      // Compress the video
      final MediaInfo? compressedVideo = await VideoCompress.compressVideo(
        video.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false, // Set to true to delete the original video
      );

      setState(() {
        _compressedVideo = compressedVideo;
        compressing = false;
      });
    }
  }

  Future<File?> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null && result.files.single.path != null) {
      File docu = File(result.files.single.path!);
      int fileSize = await docu!.length();
      if(fileSize < _sizeLimit) {
        return File(result.files.single.path!);
      } else {
        HelperUtils.showSnackBarMessage(
            context, UiUtils.getTranslatedLabel(
            context, "Upload file size below 2mb!"),
            type: MessageType.warning, messageDuration: 3);
      }
    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: UiUtils.buildAppBar(context,
            title: widget.isEdit! ? "Update Project" : "Add Project",
            actions: const [
              Text("8/8",style: TextStyle(color: Colors.white)),
              SizedBox(
                width: 14,
              ),
            ],
            showBackButton: true),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10,),
                      Text('SEO DETAILS',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                      SizedBox(height: 15,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: "Meta Title",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600
                                  ),),
                                // TextSpan(
                                //   text: " *",
                                //   style: TextStyle(color: Colors.red), // Customize asterisk color
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1,
                                        color: Color(0xffe1e1e1)
                                    ),
                                    color: Color(0xfff5f5f5),
                                    borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0,right: 5),
                                    child: TextFormField(
                                      controller: metaTitleControler,
                                      decoration: const InputDecoration(
                                          hintText: 'Enter Meta Title..',
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
                                              ))
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          Text('Note:  Meta Title length should not exceed 60 characters.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red,

                              )
                          ),
                          SizedBox(height: 25,),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: "Meta Image",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600
                                  ),),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  metaFromGallery();
                                },
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1,
                                        color: Color(0xffe1e1e1)
                                    ),
                                    color: Color(0xfff5f5f5),
                                    borderRadius: BorderRadius.circular(15.0), // Optional: Add border radius
                                  ),
                                  child: Center(
                                    child: metaImage != null ? Stack(
                                      children: [
                                        GestureDetector(
                                          child: Container(
                                            width: double.infinity,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 1,
                                                  color: Color(0xffe1e1e1)
                                              ),
                                              color: Color(0xfff5f5f5),
                                              borderRadius: BorderRadius.circular(15.0), // Optional: Add border radius
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(Radius.circular(15)),
                                              child: Image.file(metaImage!),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                metaImage = null;
                                              });
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ) : widget.isEdit! && widget.data!['meta_image'] != null ? Container(
                                      width: double.infinity,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1,
                                            color: Color(0xffe1e1e1)
                                        ),
                                        color: Color(0xfff5f5f5),
                                        borderRadius: BorderRadius.circular(15.0), // Optional: Add border radius
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                        child: Image.network(widget.data!['meta_image']),
                                      ),
                                    ) :  Text('+',
                                      style: TextStyle(
                                          color: Colors.black26,
                                          fontSize: 70,
                                          fontWeight: FontWeight.w100
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15,),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(text: "(Upload image size below 2 mb)",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400
                                      ),),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: "Meta Keywords",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600
                                  ),),
                                // TextSpan(
                                //   text: " *",
                                //   style: TextStyle(color: Colors.red), // Customize asterisk color
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1,
                                        color: Color(0xffe1e1e1)
                                    ),
                                    color: Color(0xfff5f5f5),
                                    borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0,right: 5),
                                    child: TextFormField(
                                      maxLines: 4,
                                      controller: metaKeywordControler,
                                      decoration: const InputDecoration(
                                          hintText: 'Meta Keywords..',
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
                                              ))
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          Text('Note:  The meta keywords should consist of no more than 10 keyword phrases and should be separated by commas ",".',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red,
                              )
                          ),
                          SizedBox(height: 25,),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: "Meta Description",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600
                                  ),),
                                // TextSpan(
                                //   text: " *",
                                //   style: TextStyle(color: Colors.red), // Customize asterisk color
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1,
                                        color: Color(0xffe1e1e1)
                                    ),
                                    color: Color(0xfff5f5f5),
                                    borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0,right: 5),
                                    child: TextFormField(
                                      maxLines: 4,
                                      controller: metaDescControler,
                                      decoration: const InputDecoration(
                                        hintText: 'Meta Description..',
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
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          Text('Note:  Meta Description length should between 50 to 160 characters.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red,
                              )
                          ),
                          SizedBox(height: 25,),
                        ],
                      ),
                      SizedBox(height: 25),
                      Text('IMAGES, VIDEOS & DOCUMENTS',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                      SizedBox(height: 15,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: "Project Title Image",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600
                                  ),),
                                TextSpan(
                                  text: " *",
                                  style: TextStyle(color: Colors.red), // Customize asterisk color
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  coverFromGallery();
                                },
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1,
                                        color: Color(0xffe1e1e1)
                                    ),
                                    color: Color(0xfff5f5f5),
                                    borderRadius: BorderRadius.circular(15.0), // Optional: Add border radius
                                  ),
                                  child: Center(
                                    child: coverImage != null ? Stack(
                                      children: [
                                        GestureDetector(
                                          child: Container(
                                            width: double.infinity,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 1,
                                                  color: Color(0xffe1e1e1)
                                              ),
                                              color: Color(0xfff5f5f5),
                                              borderRadius: BorderRadius.circular(15.0), // Optional: Add border radius
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(Radius.circular(15)),
                                              child: Image.file(coverImage!),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                coverImage = null;
                                              });
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ) : widget.isEdit! && widget.data!['image'] != null ? Container(
                                      width: double.infinity,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1,
                                            color: Color(0xffe1e1e1)
                                        ),
                                        color: Color(0xfff5f5f5),
                                        borderRadius: BorderRadius.circular(15.0), // Optional: Add border radius
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                        child: Image.network(widget.data!['image']),
                                      ),
                                    ) : Text('+',
                                      style: TextStyle(
                                          color: Colors.black26,
                                          fontSize: 70,
                                          fontWeight: FontWeight.w100
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15,),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(text: "(Upload image size below 2 mb)",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400
                                      ),),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: "Upload Broucher",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600
                                  ),),
                                // TextSpan(
                                //   text: " *",
                                //   style: TextStyle(color: Colors.red), // Customize asterisk color
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    File? brouch = await _pickFile();
                                    setState(() {
                                      broucher = brouch;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: Color(0xffe1e1e1)
                                      ),
                                      color: Color(0xfff5f5f5),
                                      borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(child: Text(broucher != null ? broucher!.path.split('/').last : widget.isEdit! ? '' : 'Browse File...')),
                                          InkWell(
                                            onTap: () async {
                                              if(broucher != null) {
                                                setState(() {
                                                  broucher = null;
                                                });
                                              } else {
                                                File? brouch = await _pickFile();
                                                setState(() {
                                                  broucher = brouch;
                                                });
                                              }
                                            },
                                            child: Icon(broucher != null ? Icons.delete : Icons.upload),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          Text('Note:  File size should be below 2 MB.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red,
                              )
                          ),
                          SizedBox(height: 25,),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: "Galary Images",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600
                                  ),
                                ),
                                TextSpan(
                                  text: " *",
                                  style: TextStyle(color: Colors.red), // Customize asterisk color
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  _imgFromGallery();
                                },
                                child: Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1,
                                        color: Color(0xffe1e1e1)
                                    ),
                                    color: Color(0xfff5f5f5),
                                    borderRadius: BorderRadius.circular(15.0), // Optional: Add border radius
                                  ),
                                  child: Center(
                                    child: Text('+',
                                      style: TextStyle(
                                          color: Colors.black26,
                                          fontSize: 70,
                                          fontWeight: FontWeight.w100
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15,),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(text: "(Upload each image size below 2 mb)",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400
                                      ),),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                        ],
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                            mainAxisSpacing: 10, crossAxisCount: 3, height: 100, crossAxisSpacing: 10),
                        itemCount: gallary.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              GestureDetector(
                                child: Container(
                                  width: double.infinity,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1,
                                        color: Color(0xffe1e1e1)
                                    ),
                                    color: Color(0xfff5f5f5),
                                    borderRadius: BorderRadius.circular(15.0), // Optional: Add border radius
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                    child: Image.file(gallary[index]),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      gallary.removeAt(index);
                                    });
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      if(widget.isEdit!)
                        SizedBox(height: 10,),
                      if(widget.isEdit!)
                        GridView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                          ),
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                              mainAxisSpacing: 10, crossAxisCount: 3, height: 100, crossAxisSpacing: 10),
                          itemCount: gallaryEdit.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                GestureDetector(
                                  child: Container(
                                    width: double.infinity,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: Color(0xffe1e1e1)
                                      ),
                                      color: Color(0xfff5f5f5),
                                      borderRadius: BorderRadius.circular(15.0), // Optional: Add border radius
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                      child: Image.network(gallaryEdit[index]['name']),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () async {
                                      var responseAgent = await Api.get(
                                          url: Api.getProject, queryParameters: {
                                        'remove_gallery_images': gallaryEdit[index]['id'],
                                      });
                                      if (!responseAgent['error']) {
                                        setState(() {
                                          gallaryEdit.removeAt(index);
                                        });
                                      }
                                    },
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      SizedBox(height: 15,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: "Video URL",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600
                                  ),),
                                // TextSpan(
                                //   text: " *",
                                //   style: TextStyle(color: Colors.red), // Customize asterisk color
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1,
                                        color: Color(0xffe1e1e1)
                                    ),
                                    color: Color(0xfff5f5f5),
                                    borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0,right: 5),
                                    child: TextFormField(
                                      controller: videoControler,
                                      decoration: const InputDecoration(
                                          hintText: 'Enter Video URL..',
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
                                              ))
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 25,),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: "Price List & Payment Plan",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600
                                  ),),
                                // TextSpan(
                                //   text: " *",
                                //   style: TextStyle(color: Colors.red), // Customize asterisk color
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    File? brouch = await _pickFile();
                                    setState(() {
                                      pricePlan = brouch;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: Color(0xffe1e1e1)
                                      ),
                                      color: Color(0xfff5f5f5),
                                      borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(child: Text(pricePlan != null ? pricePlan!.path.split('/').last : widget.isEdit! ? '' : 'Browse File...')),
                                          InkWell(
                                            onTap: () async {
                                              if(pricePlan != null) {
                                                setState(() {
                                                  pricePlan = null;
                                                });
                                              } else {
                                                File? brouch = await _pickFile();
                                                setState(() {
                                                  pricePlan = brouch;
                                                });
                                              }
                                            },
                                            child: Icon(pricePlan != null ? Icons.delete : Icons.upload),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 25,),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: "Floor Details",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600
                                  ),),
                                // TextSpan(
                                //   text: " *",
                                //   style: TextStyle(color: Colors.red), // Customize asterisk color
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10,),
                          for(int i = 0; i < floorDetails.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Stack(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: Color(0xffe1e1e1)
                                            ),
                                            borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Floor Title'),
                                                    SizedBox(height: 5),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 1,
                                                            color: Color(0xffe1e1e1)
                                                        ),
                                                        color: Color(0xfff5f5f5),
                                                        borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(left: 8.0,right: 5),
                                                        child: TextFormField(
                                                          controller: floorDetails[i]['title'],
                                                          decoration: const InputDecoration(
                                                              hintText: 'Enter Floor Title..',
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
                                                                  ))
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Floor Plan'),
                                                    SizedBox(height: 5),
                                                    InkWell(
                                                      onTap: () async {
                                                        File? brouch = await floorPlanImage();
                                                        setState(() {
                                                          floorDetails[i]['document'] = brouch;
                                                        });
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                              width: 1,
                                                              color: Color(0xffe1e1e1)
                                                          ),
                                                          color: Color(0xfff5f5f5),
                                                          borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(12),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Container(
                                                                width: 100,
                                                                child: Text(floorDetails[i]['document'] != null ? floorDetails[i]['document']!.path.split('/').last : widget.isEdit! ? '${floorDetails[i]['name']}' : 'Browse File...',
                                                                    overflow: TextOverflow.ellipsis
                                                                ),
                                                              ),
                                                              InkWell(
                                                                onTap: () async {
                                                                  if(floorDetails[i]['document'] != null) {
                                                                    setState(() {
                                                                      floorDetails[i]['document'] = null;
                                                                    });
                                                                  } else {
                                                                    File? brouch = await floorPlanImage();
                                                                    setState(() {
                                                                      floorDetails[i]['document'] = brouch;
                                                                    });
                                                                  }
                                                                },
                                                                child: Icon(floorDetails[i]['document'] != null ? Icons.delete : Icons.upload),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if(floorDetails.length != 1)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: InkWell(
                                        onTap: () async {
                                          if(widget.isEdit! && floorDetails[i]['id'] != null) {
                                            var responseAgent = await Api.get(
                                                url: Api.getProject,
                                                queryParameters: {
                                                  'remove_plans': floorDetails[i]['id'],
                                                });
                                            if (!responseAgent['error']) {
                                              setState(() {
                                                floorDetails.removeAt(i);
                                              });
                                            }
                                          } else {
                                            setState(() {
                                              floorDetails.removeAt(i);
                                            });
                                          }
                                        },
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          SizedBox(height: 5,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    floorDetails.add({
                                      'title': TextEditingController(),
                                      'document': null,
                                      'id': null,
                                      'name': '',
                                    });
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    color: Color(0xff117af9),
                                    borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
                                  ),
                                  child: Text('Add Floor +',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15,),
                        ],
                      ),
                      SizedBox(height: 25,),
                      // Text('$reqBody'),
                    ],
                  ),
                ),
              ),
            ),

            InkWell(
              onTap: () async {
                if (!loading) {
                  // Check if coverImage and gallaryImages are empty
                  if (!widget.isEdit! && (coverImage == null || gallaryImages.isEmpty)) {
                    HelperUtils.showSnackBarMessage(
                      context,
                      UiUtils.getTranslatedLabel(context, "Title image and Gallery images cannot be empty"),
                      type: MessageType.error,
                      messageDuration: 3,
                    );
                    return;
                  }

                  setState(() {
                    loading = true;
                  });

                  var floorPlans = [];
                  for (int i = 0; i < floorDetails.length; i++) {
                    if (!widget.isEdit! && floorDetails[i]['document'] != null) {
                      floorPlans.add({
                        'id': null,
                        'title': floorDetails[i]['title'].text,
                        'document': await MultipartFile.fromFile(floorDetails[i]['document']!.path),
                      });
                    } else if (widget.isEdit!) {
                      floorPlans.add({
                        'id': floorDetails[i]['id'],
                        'title': floorDetails[i]['title'].text,
                        'document': floorDetails[i]['document'] != null
                            ? await MultipartFile.fromFile(floorDetails[i]['document']!.path)
                            : null,
                      });
                    }
                  }

                  Map<String, dynamic> body = {
                    'image': coverImage != null ? await MultipartFile.fromFile(coverImage!.path) : null,
                    'gallery_images': gallaryImages,
                    'video_link': videoControler.text,
                    'documents': broucher != null ? [await MultipartFile.fromFile(broucher!.path)] : [],
                    'plans': floorPlans,
                    'payment_plan': pricePlan != null ?  await MultipartFile.fromFile(pricePlan!.path): null,
                    'meta_title': metaTitleControler.text,
                    'meta_description': metaDescControler.text,
                    'meta_keywords': metaKeywordControler.text,
                    'meta_image': metaImage != null ? await MultipartFile.fromFile(metaImage!.path) : null,
                    ...widget.body!,
                  };

                  setState(() {
                    reqBody = body;
                  });
                  print('ffffffffffffffff: ${body}');

                  try {
                    if (!widget.isEdit!) {
                      print('parameter_body: $body');
                      var response = await Api.post(url: Api.postProject, parameter: body);
                      setState(() {
                        loading = false;
                      });
                      HelperUtils.showSnackBarMessage(
                        context,
                        UiUtils.getTranslatedLabel(
                            context, "${response['message']}"),
                        type: MessageType.success,
                        messageDuration: 3,
                      );
                      if(!response['error']) {
                        Future.delayed(Duration.zero, () {
                          Navigator.of(context)
                              .pushReplacementNamed(Routes.main, arguments: {'from': "main"});
                        });
                      }
                    } else {
                      var response = await Api.post(
                          url: Api.postProject + '?id=${widget.data!['id']}', parameter: body);
                      setState(() {
                        loading = false;
                      });
                      HelperUtils.showSnackBarMessage(
                        context,
                        UiUtils.getTranslatedLabel(
                            context, "${response['message']}"),
                        type: MessageType.success,
                        messageDuration: 3,
                      );
                      if(!response['error']) {
                        Future.delayed(Duration.zero, () {
                          Navigator.of(context)
                              .pushReplacementNamed(Routes.main, arguments: {'from': "main"});
                        });
                      }
                    }
                  } catch (err) {
                    setState(() {
                      loading = false;
                    });
                    HelperUtils.showSnackBarMessage(
                      context,
                      UiUtils.getTranslatedLabel(
                          context, 'Exception: ${err}'),
                      type: MessageType.success,
                      messageDuration: 3,
                    );
                  }
                }
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 10, left: 15, right: 15),
                width: double.infinity,
                height: 48.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xff117af9),
                ),
                child: Text(
                  loading ? 'Please wait...' : 'Submit',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

