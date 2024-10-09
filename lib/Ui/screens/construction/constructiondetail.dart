import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../settings.dart';
import '../../../utils/api.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/hive_utils.dart';
import '../../../utils/ui_utils.dart';
import '../widgets/blurred_dialoge_box.dart';

class ConstructionDetail extends StatefulWidget {
  final int? id;

  const ConstructionDetail({super.key, this.id});

  @override
  State<ConstructionDetail> createState() => _ServiceDetailState();
}

class _ServiceDetailState extends State<ConstructionDetail> {
  bool loading = false;
  Map? serviceDetails;
  int? selectedStar = -1;
  String dropdownvalue6 = 'Chennai';
  var items6 = ['Chennai', 'Madurai'];
  String dropdownvalue5 = 'Select Locality';
  var items5 = ['Select Locality', 'Tamil'];
  String dropdownvalue4 = 'Loan Type';
  var items4 = ['Loan Type', 'Gold Loan'];
  int currentIndex = 0;
  List<int> items = [1, 2, 3, 4, 5];

  @override
  void initState() {
    getServiceDetails();
    super.initState();
  }

  final List<Map<String, String>> reviews = [
    {
      "rating": "5",
      "name": "Tobi Jr",
      "comment":
          "Write short paragraphs and cover one topic per paragraph.",
      "data" : "05-04-2001"
    },
    {
      "rating": "4",
      "name": "Jane Doe",
      "comment": "Great experience! Highly recommended.",
    "data" : "05-04-2001"
    },
    // Add more review data as needed
  ];

  Future<void> getServiceDetails() async {
    setState(() {
      loading = true;
    });
    var response =
        await Api.get(url: Api.constructionDetails, queryParameters: {
      'constructor_id': widget.id!,
      'current_user': HiveUtils.getUserId(),
    });
    if (!response['error']) {
      setState(() {
        serviceDetails = response['data'];
        if (response['data']!['my_rating'] != null) {
          selectedStar = response['data']['my_rating']['ratting'];
        }
        loading = false;
      });
    }
  }

  share(String slugId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.color.backgroundColor,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text("copylink".translate(context)),
              onTap: () async {
                String deepLink = "https://${AppSettings.shareNavigationWebUrl}/constructor/$slugId";

                await Clipboard.setData(ClipboardData(text: deepLink));

                Future.delayed(Duration.zero, () {
                  Navigator.pop(context);
                  HelperUtils.showSnackBarMessage(
                      context, "copied".translate(context));
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text("share".translate(context)),
              onTap: () async {
                String deepLink = "https://${AppSettings.shareNavigationWebUrl}/constructor/$slugId";

                String text =
                    "Exciting find! 🏡 Check out this amazing property I came across.  Let me know what you think! ⭐\n Here are the details:\n$deepLink.";
                await Share.share(text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> saveRatting(String reviewText) async {
    try {
      var response = await Api.post(url: Api.addRatting, parameter: {
        'advertisement_id': widget.id!,
        'ratting': selectedStar!,
        'comment': reviewText.toString(), // Send the review text
      });

      if (!response['error']) {
        getServiceDetails();
      }
    } catch (e) {
      print("Error submitting rating: $e");
    }

    return; // Ensures the function returns a non-null value
  }

  void _showAlertDialog(BuildContext context) async {
    // To store the written review
    String reviewText = ''; // Moved this here for scoping

    await UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBuilderBox(
        title: "Add Rating",
        acceptButtonName: "Submit".translate(context),
        onAccept: () => saveRatting(reviewText),
        contentBuilder: (context, s) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rating stars
                  FittedBox(
                    fit: BoxFit.none,
                    child: Row(
                      children: [
                        for (int i = 0; i < 5; i++)
                          CupertinoButton(
                            onPressed: () {
                              setState(() {
                                selectedStar = i;
                              });
                            },
                            minSize: 10,
                            child: Image.asset(
                              selectedStar! < i
                                  ? "assets/Loans/_-115.png"
                                  : "assets/Loans/_-114.png",
                              width: selectedStar! < i ? 18 : 20,
                              height: selectedStar! < i ? 18 : 20,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Add space between stars and review input
                  SizedBox(height: 10),

                  // Review text field
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: TextField(
                      onChanged: (value) {
                        reviewText = value;
                      },
                      decoration: InputDecoration(
                        hintText: "Write your review...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: tertiaryColor_,
        title: loading
            ? Text('')
            : Text(
                '${serviceDetails!['title'] ?? '--'}',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xff117af9),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              CarouselSlider(
                                options: CarouselOptions(
                                  aspectRatio: 1.9,
                                  viewportFraction: 1.0,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      currentIndex = index;
                                    });
                                  },
                                ),
                                items: [
                                  for (var img in serviceDetails!['image'])
                                    Container(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        child: Image.network(
                                          img,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      ),
                                    )
                                ],
                              ),
                              Positioned(
                                right: 8,
                                top: 10,
                                child: InkWell(
                                  onTap: () {
                                    share(serviceDetails!['id'].toString() ?? "");
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: context.color.primaryColor,
                                      shape: BoxShape.circle,
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Color.fromARGB(33, 0, 0, 0),
                                            offset: Offset(0, 2),
                                            blurRadius: 15,
                                            spreadRadius: 0)
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.share,
                                      color: context.color.tertiaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              if (serviceDetails!['image'].length > 0)
                                Positioned(
                                  bottom: 8,
                                  right: 0,
                                  left: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomDotsIndicator(
                                        dotsCount:
                                            serviceDetails!['image'].length,
                                        position: currentIndex.toDouble(),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              if (serviceDetails!['construnction_role'] != null)
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 3, bottom: 3),
                                  decoration: BoxDecoration(
                                    color: Color(0xff117af9),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    '${serviceDetails!['construnction_role']}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, top: 3, bottom: 3),
                                decoration: BoxDecoration(
                                  color: Color(0xff7e71d8),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  'CONS00${serviceDetails!['id']}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xfff9f9f9),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.network(
                                      "${serviceDetails!['photo']}",
                                      width: 70,
                                      height: 70,
                                    )),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Text(
                                                  '${serviceDetails!['title'] ?? '--'}',
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 2,
                                                ),
                                                if (serviceDetails!['status'] ==
                                                    'Verified')
                                                  Image.asset(
                                                    "assets/verified.png",
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          Image.asset(
                                            "assets/Loans/_-114.png",
                                            width: 15,
                                            height: 15,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            '${UiUtils.trimNumberToOneDecimal(serviceDetails!['reviews_avg_ratting'] ?? '0')}'
                                            ' (${serviceDetails!['user_count']} Ratings)',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Color(0xff7d7d7d)),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Image.asset(
                                            "assets/Home/__location.png",
                                            width: 15,
                                            fit: BoxFit.cover,
                                            height: 15,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            '${serviceDetails!['city'] ?? '--'}',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Color(0xff7d7d7d)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xfff0f0f0),
                                  offset: Offset(0, 2),
                                  blurRadius: 2.0,
                                  spreadRadius: 2.0,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Contact Details',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _showAlertDialog(context),
                                      child: Text(
                                        '+ Add Ratting',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xff117af9),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Company Name:',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xff7d7d7d)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${serviceDetails!['company_name'] ?? '--'}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Company Website:',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xff7d7d7d)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${serviceDetails!['website_link'] ?? '--'}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Office Timing:',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xff7d7d7d)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${serviceDetails!['timing'] ?? '--'}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Total Projects:',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xff7d7d7d)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${serviceDetails!['projects'] ?? '--'}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Experiance:',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xff7d7d7d)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${serviceDetails!['experience'] ?? '--'}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Phone No:',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xff7d7d7d)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '+91 ${serviceDetails!['phone'] ?? '--'}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Email Id:',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xff7d7d7d)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${serviceDetails!['email'] ?? '--'}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Locations:',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xff7d7d7d)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${serviceDetails!['location'] ?? '--'}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Brokerage:',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xff7d7d7d)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${serviceDetails!['brokerage'] ?? '--'}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xfff0f0f0),
                                  offset: Offset(0, 2),
                                  blurRadius: 2.0,
                                  spreadRadius: 2.0,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Other Services',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      for (var ser
                                          in serviceDetails!['property_type'])
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                left: 12,
                                                right: 12,
                                                top: 6,
                                                bottom: 6),
                                            decoration: BoxDecoration(
                                              color: Color(0xfffffbf3),
                                              border: Border.all(
                                                  color: Color(0xffffe8c2),
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            alignment: Alignment.center,
                                            child: Row(
                                              children: [
                                                SvgPicture.network(
                                                  ser['icon'],
                                                  width: 15,
                                                  height: 15,
                                                  fit: BoxFit.cover,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  '${ser['name']}',
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xff333333)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xfff0f0f0),
                                  offset: Offset(0, 2),
                                  blurRadius: 2.0,
                                  spreadRadius: 2.0,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Address',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '${serviceDetails!['address'] ?? '--'}',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xff707070)),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '${serviceDetails!['description'] ?? '--'}',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xff707070)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            'Reviews',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 150,
                            child: ListView.builder(
                              itemCount: reviews.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xfff0f0f0),
                                        offset: Offset(0, 2),
                                        blurRadius: 2.0,
                                        spreadRadius: 2.0,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              reviews[index]["rating"]!,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(width: 5),
                                            Icon(
                                              CupertinoIcons.star_fill,
                                              size: 11,
                                              color: Colors.orange,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              child: Text(
                                                reviews[index]["name"]!,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              ),
                                            ),
                                            Spacer(),
                                            Text(
                                              reviews[index]["data"]!,
                                              style: TextStyle(
                                                color: Colors.grey,
                                                  fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Text(
                                          reviews[index]["comment"]!,
                                          style: TextStyle(fontSize: 14),
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xfff0f0f0),
                        offset: Offset(0, 2),
                        blurRadius: 2.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () async {
                          final url =
                              'tel:${serviceDetails!['phone']}'; // Create a tel URL with the phone number
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        child: Container(
                          height: 40,
                          padding: EdgeInsets.only(
                              left: 15, right: 15, top: 10, bottom: 10),
                          decoration: BoxDecoration(
                            color: Color(0xff117af9),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/NewPropertydetailscreen/__call.png",
                                width: 18,
                                height: 18,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Call',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // InkWell(
                      //   onTap: () async {
                      //     final url =
                      //         'sms:${serviceDetails!['phone']}'; // Create a tel URL with the phone number
                      //     if (await canLaunchUrl(Uri.parse(url))) {
                      //       await launchUrl(Uri.parse(url));
                      //     } else {
                      //       throw 'Could not launch $url';
                      //     }
                      //   },
                      //   child: Container(
                      //     height: 40,
                      //     padding: EdgeInsets.only(
                      //         left: 15, right: 15, top: 10, bottom: 10),
                      //     decoration: BoxDecoration(
                      //       color: Color(0xff117af9),
                      //       borderRadius: BorderRadius.circular(7),
                      //     ),
                      //     child: Row(
                      //       children: [
                      //         Image.asset(
                      //           "assets/NewPropertydetailscreen/__chat.png",
                      //           width: 18,
                      //           height: 18,
                      //         ),
                      //         SizedBox(
                      //           width: 10,
                      //         ),
                      //         Text(
                      //           'Message',
                      //           style: TextStyle(
                      //             color: Colors.white,
                      //             fontSize: 12,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      InkWell(
                        onTap: () async {
                          final url =
                              'whatsapp://send?phone=:+91${serviceDetails!['whatsapp_number']}&text=';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        child: Container(
                          height: 40,
                          padding: EdgeInsets.only(
                              left: 15, right: 15, top: 10, bottom: 10),
                          decoration: BoxDecoration(
                            color: Color(0xff25d366),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/NewPropertydetailscreen/__whatsapp.png",
                                width: 18,
                                height: 18,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Whatsapp',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}

class CustomDotsIndicator extends StatelessWidget {
  final int dotsCount;
  final double position;

  CustomDotsIndicator({
    required this.dotsCount,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dotsCount, (index) {
        bool isSelected = index == position.round();
        return Container(
          width: 8.0,
          height: 8.0,
          margin: EdgeInsets.symmetric(horizontal: 1.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Color(0xff4f72d6) : Color(0xffdcdcdc),
              width: 1.0,
            ),
            color: isSelected ? Colors.white : Colors.white,
          ),
        );
      }),
    );
  }
}
