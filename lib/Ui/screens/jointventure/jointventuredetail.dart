import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../settings.dart';
import '../../../utils/api.dart';
import '../../../utils/helper_utils.dart';
import '../../../utils/hive_utils.dart';
import '../../../utils/ui_utils.dart';
import '../widgets/blurred_dialoge_box.dart';

class JointventureDetail extends StatefulWidget {
  final int? id;
  const JointventureDetail({super.key, this.id});

  @override
  State<JointventureDetail> createState() => _JointventureDetailState();
}

class _JointventureDetailState extends State<JointventureDetail> {

  bool Loading = false;
  Map? venturesDetails;
  String dropdownvalue6 = 'Chennai';
  var items6 =  ['Chennai','Madurai'];
  String dropdownvalue5 = 'Select Locality';
  var items5 =  ['Select Locality','Tamil'];
  String dropdownvalue4 = 'Loan Type';
  var items4 =  ['Loan Type','Gold Loan'];
  int currentIndex = 0;
  List<int> items = [1, 2, 3, 4, 5];
  int? selectedStar = -1;

  @override
  void initState() {
    getVentures();
    super.initState();
  }

  Future<void> getVentures() async {
    setState(() {
      Loading = true;
    });
    var response = await Api.get(url: Api.ventureDetails, queryParameters: {
      'joint_venture': widget.id,
      'current_user': HiveUtils.getUserId(),
    });
    if(!response['error']) {
      setState(() {
        venturesDetails = response['data'];
        if(response['data']!['my_rating'] != null) {
          selectedStar = response['data']['my_rating']['ratting'];
        }
        Loading = false;
      });
    }
  }

  Future<void> saveRatting(String? message) async {

    var parameters = {
      'advertisement_id': widget.id!.toString(),
      'ratting': selectedStar!.toString(),
    };

    if (message != null && message.isNotEmpty) {
      parameters['comment'] = message;
    }

    // Send the API request
    var response = await Api.post(url: Api.addRatting, parameter: parameters);

    // Check for errors in the response
    if (!response['error']) {
      getVentures();
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
                String deepLink = "https://${AppSettings.shareNavigationWebUrl}/join-venture/$slugId";

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
                String deepLink = "https://${AppSettings.shareNavigationWebUrl}/join-venture/$slugId";

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

  void _showAlertDialog(BuildContext context) async {
    TextEditingController feedbackController = TextEditingController();

    await UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBuilderBox(
          title: "Add Rating",
          acceptButtonName: "Submit".translate(context),
          onAccept: ()  async{
            String feedback = feedbackController.text;
            saveRatting(feedback);
          },
          contentBuilder: (context, s) {
            return StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        // Star Rating Section
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
                      const SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        height: 45,
                        decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(10),
                         color: Colors.white,
                          border: Border.all( color: Colors.grey.withOpacity(0.5))
                        ),
                        child: TextFormField(
                          style: TextStyle(fontSize: 14),
                          controller: feedbackController,
                          decoration: InputDecoration(
                            hintText: 'Enter your feedback',
                            hintStyle: TextStyle(fontSize: 14),
                            border: InputBorder.none,
                          ),
                          maxLines: 3,
                        ),
                      ),
                    ],
                  );
                });
          }),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: UiUtils.buildAppBar(context,
          showBackButton: true,
        title: "${Loading ?"":'${venturesDetails!['post_name']}: ${venturesDetails!['land_size']}'}",
          actions: [
          ]),

      body: Loading ? Center(child: Center(
    child: UiUtils.progress(
      normalProgressColor: context.color.tertiaryColor,
    ),
    ),) : Column(
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
                            aspectRatio: 1.5,
                            viewportFraction: 1.0,
                            onPageChanged: (index, reason) {
                              setState(() {
                                currentIndex = index;
                              });
                            },
                          ),
                          items: [
                            if(venturesDetails!['image']!=null&&venturesDetails!['image'].isNotEmpty)
                          ...[
                            for(var img in venturesDetails!['image'])
                              Container(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: UiUtils.getImage(
                                    img,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    height: 150,
                                  ),
                                ),
                              )
                          ]else    Container(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: UiUtils.getImage(
                                  "",
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  height: 150,
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
                              share(venturesDetails!['id'].toString() ?? "");
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
                        if(venturesDetails!['image'].length > 0)
                          Positioned(
                            bottom: 8,
                            right: 0,
                            left: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomDotsIndicator(
                                  dotsCount: venturesDetails!['image'].length,
                                  position: currentIndex.toDouble(),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 15,),
                    Container(
                      padding: EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
                      decoration: BoxDecoration(
                        color: Color(0xff06e300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('${venturesDetails!['code']}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 5,),
                    Text('${venturesDetails!['post_name']}: ${venturesDetails!['title']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 15,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ClipRRect( borderRadius: BorderRadius.circular(50), child:
                        Image.network("${venturesDetails!['photo']}",width: 60,height: 60,)),
                        SizedBox(width: 8,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text('${venturesDetails!['company_name']}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Container(
                                    padding: EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
                                    decoration: BoxDecoration(
                                      color: Color(0xff7e71d8),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text('${venturesDetails!['role_name']}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                children: [
                                  Image.asset("assets/Loans/_-114.png",width: 15,height: 15,),
                                  SizedBox(width: 5,),
                                  Text('${UiUtils.trimNumberToOneDecimal(venturesDetails!['reviews_avg_ratting'] ?? '0')} (${venturesDetails!['user_count']} Ratings)',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xff7d7d7d)
                                    ),)
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        "assets/Home/__location.png",
                                        width: 15,
                                        fit: BoxFit.cover,
                                        height: 15,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        venturesDetails!['city'] != null
                                            ? '${venturesDetails!['city']}'
                                            : 'Location not available',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xff7d7d7d),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text('${venturesDetails!['post_date']}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xff7d7d7d)
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 15,),
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
                                  'Land Size:',
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
                                  '${venturesDetails!['land_size'] ?? '--'}',
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
                                  '${venturesDetails!['website_link'] ?? '--'}',
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
                                  '+91 ${venturesDetails!['phone'] ?? '--'}',
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
                                  '${venturesDetails!['email'] ?? '--'}',
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
                                  '${venturesDetails!['location'] ?? '--'}',
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
                                  '${venturesDetails!['brokerage'] ?? '--'}',
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
                    SizedBox(height: 15,),
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
                          Text('Address',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),),
                          SizedBox(height: 10,),

                          Text(  venturesDetails!['address'] != null
                              ? '${venturesDetails!['address']}'
                              : 'Location not available',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xff707070)
                            ),),
                          SizedBox(height: 10,),
                          Text('Description',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),),
                          SizedBox(height: 10,),
                          Text(
                            venturesDetails!['description'] != null
                                ? '${venturesDetails!['description']}'
                                : 'Description not available',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff707070)
                          ),),
                        ],
                      ),
                    ),
                    SizedBox(height: 15,),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10,bottom: 10,left: 15,right: 15),
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
                    final url = 'tel:${venturesDetails!['phone']}'; // Create a tel URL with the phone number
                    if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                    } else {
                    throw 'Could not launch $url';
                    }
                  },
                  child: Container(
                    height: 40,
                    padding: EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 10),
                    decoration: BoxDecoration(
                      color: Color(0xff117af9),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      children: [
                        Image.asset("assets/NewPropertydetailscreen/__call.png",width: 18,height: 18,),
                        SizedBox(width: 10,),
                        Text('Call',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final url = 'sms:${venturesDetails!['phone']}'; // Create a tel URL with the phone number
                    if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                    } else {
                    throw 'Could not launch $url';
                    }
                  },
                  child: Container(
                    height: 40,
                    padding: EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 10),
                    decoration: BoxDecoration(
                      color: Color(0xff117af9),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      children: [
                        Image.asset("assets/NewPropertydetailscreen/__chat.png",width: 18,height: 18,),
                        SizedBox(width: 10,),
                        Text('Message',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final url = 'whatsapp://send?phone=:+91${venturesDetails!['whatsapp_number']}&text='; // Create a tel URL with the phone number
                    if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                    } else {
                    throw 'Could not launch $url';
                    }
                  },
                  child: Container(
                    height: 40,
                    padding: EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 10),
                    decoration: BoxDecoration(
                      color: Color(0xff25d366),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Image.asset("assets/NewPropertydetailscreen/__whatsapp.png",width: 18,height: 18,),
                        SizedBox(width: 5,),
                        Text('Whatsapp',
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
            color: isSelected ? Colors.white :  Colors.white,
          ),
        );
      }),
    );
  }
}
