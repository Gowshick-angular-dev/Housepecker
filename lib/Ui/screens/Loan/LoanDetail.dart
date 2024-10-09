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

class LoanDetail extends StatefulWidget {
  final int? id;
  const LoanDetail({super.key, this.id});

  @override
  State<LoanDetail> createState() => _LoanDetailState();
}

class _LoanDetailState extends State<LoanDetail> {

  bool loading = false;
  Map? agentInfo;
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
    getAgentDetails();

    super.initState();
  }

  Future<void> getAgentDetails() async {
    setState(() {
      loading = true;
    });
    var response = await Api.get(url: Api.agentsDetails, queryParameters: {
      'loan_id': widget.id!,
      'current_user': HiveUtils.getUserId(),
    });
    if(!response['error']) {
      setState(() {
        agentInfo = response['data'];
        if(response['data']!['my_rating'] != null) {
          selectedStar = response['data']['my_rating']['ratting'];
        }
        loading = false;
      });
    }
  }

  Future<void> saveRatting() async {
    var response =
    await Api.post(url: Api.addRatting, parameter: {
      'advertisement_id': widget.id!,
      'ratting': selectedStar!,
    });
    if (!response['error']) {
      getAgentDetails();
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
                String deepLink = "https://${AppSettings.shareNavigationWebUrl}/project-details/$slugId";

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
    await UiUtils.showBlurredDialoge(
      context,
      dialoge: BlurredDialogBuilderBox(
          title: "Add Ratting",
          acceptButtonName: "submit".translate(context),
          onAccept: saveRatting,
          contentBuilder: (context, s) {
            return StatefulBuilder(
                builder: (context, setState) {
                  return FittedBox(
                    fit: BoxFit.none,
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
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
                              selectedStar! < i ?
                              "assets/Loans/_-115.png" : "assets/Loans/_-114.png",
                              width: selectedStar! < i ? 18 : 20,
                              height: selectedStar! < i ? 18 : 20,
                            ),
                          ),
                      ],
                    ),
                  );
                }
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: tertiaryColor_,
        title: Text('${loading ? '' : agentInfo!['title'] }',
          style: TextStyle(
              fontSize: 14,color: Colors.white
          ),
        ),
      ),

      body: loading ? Center(
        child: CircularProgressIndicator(
          color: Color(0xff117af9),
        ),
      ) : Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 15,),
              Stack(
                children: [
                  if(agentInfo!['image'].length > 0)
                    CarouselSlider(
                        options: CarouselOptions(
                          aspectRatio: 2.5,
                          viewportFraction: 1.0,
                          onPageChanged: (index, reason) {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                        ),
                        items: [
                          for(var img in agentInfo!['image'])
                            Container(
                              margin: EdgeInsets.only(right: 15, left: 15),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.network(
                                  img,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            )
                        ]
                    ),
                  Positioned(
                    right: 8,
                    top: 10,
                    child: InkWell(
                      onTap: () {
                        share(agentInfo!['id'].toString() ?? "");
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
                  if(agentInfo!['image'].length > 0)
                    Positioned(
                      bottom: 8,
                      right: 0,
                      left: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomDotsIndicator(
                            dotsCount: agentInfo!['image'].length,
                            position: currentIndex.toDouble(),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 15,),
                  // Container(
                  //   padding: EdgeInsets.only(
                  //       left: 10,
                  //       right: 10,
                  //       top: 3,
                  //       bottom: 3),
                  //   decoration: BoxDecoration(
                  //     color: Color(0xff7e71d8),
                  //     borderRadius:
                  //     BorderRadius.circular(5),
                  //   ),
                  //   child: Text(
                  //     'LOAN00${agentInfo!['id']}',
                  //     style: TextStyle(
                  //       fontSize: 10,
                  //       color: Colors.white,
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 5,)
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15,),
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
                              child: Image.network(agentInfo!['photo'],width: 70,height: 70,)),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('${agentInfo!['title']}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),),
                                    SizedBox(width: 2,),
                                    if(agentInfo!['status'] == 'Verified')
                                      Image.asset("assets/verified.png",width: 20,height: 20,),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  children: [
                                    Image.asset("assets/Loans/_-114.png",width: 15,height: 15,),
                                    SizedBox(width: 5,),
                                    Text('${UiUtils.trimNumberToOneDecimal(agentInfo!['reviews_avg_ratting'] ?? '0')}'
                                        ' (${agentInfo!['user_count']} Ratings)',style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xff7d7d7d)
                                    ),)
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text('Bank   :',style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xff7d7d7d)
                                          ),),
                                          SizedBox(width: 8,),
                                          Text('${agentInfo!['bank_name']}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 5,),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          // Text('Bank   :',style: TextStyle(
                                          //     fontSize: 11,
                                          //     color: Color(0xff7d7d7d)
                                          // ),),
                                          // SizedBox(width: 8,),
                                          Text('${agentInfo!['agent_type'] ?? 'DST & DSA'}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5,),
                                Row(
                                  children: [
                                    Text('Branch   :',style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xff7d7d7d)
                                    ),),
                                    SizedBox(width: 8,),
                                    Text('${agentInfo!['branch']}',style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black
                                    ),)
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
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
                                'Bank Info',
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
                                  '${agentInfo!['timing'] ?? '--'}',
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
                                  '+91 ${agentInfo!['phone'] ?? '--'}',
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
                                  '${agentInfo!['email'] ?? '--'}',
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
                                  '${agentInfo!['location'] ?? '--'}',
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
                                  '${agentInfo!['brokerage'] ?? '--'}',
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
                          Text('Loan Types',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),),
                            SizedBox(height: 10,),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for(var typ in agentInfo!['loan_type'])
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Container(
                                    padding: EdgeInsets.only(left: 15,right: 15,top: 6,bottom: 6),
                                    decoration: BoxDecoration(
                                      color: Color(0xfffffbf3),
                                      border: Border.all(
                                          color: Color(0xffffe8c2), width: 1
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),alignment: Alignment.center,
                                    child: Text('${typ}',style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff333333)
                                    ),),
                                                                  ),
                                  ),
                              ],
                            ),
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
                            '${agentInfo!['address'] ?? '--'}',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xff707070)),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text('Description',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),),
                          SizedBox(height: 10,),
                          Text('${agentInfo!['description']}',style: TextStyle(
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
                        final url = 'tel:${agentInfo!['phone']}'; // Create a tel URL with the phone number
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
                    // InkWell(
                    //   onTap: () async {
                    //     final url = 'sms:${agentInfo!['phone']}'; // Create a tel URL with the phone number
                    //     if (await canLaunchUrl(Uri.parse(url))) {
                    //     await launchUrl(Uri.parse(url));
                    //     } else {
                    //     throw 'Could not launch $url';
                    //     }
                    //   },
                    //   child: Container(
                    //     height: 40,
                    //     padding: EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 10),
                    //     decoration: BoxDecoration(
                    //         color: Color(0xff117af9),
                    //         borderRadius: BorderRadius.circular(7),
                    //     ),
                    //     child: Row(
                    //       children: [
                    //         Image.asset("assets/NewPropertydetailscreen/__chat.png",width: 18,height: 18,),
                    //         SizedBox(width: 10,),
                    //         Text('Message',
                    //              style: TextStyle(
                    //                color: Colors.white,
                    //                fontSize: 12,
                    //              ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    InkWell(
                      onTap: () async {
                        final url = 'whatsapp://send?phone=:+91${agentInfo!['whatsapp_number']}&text='; // Create a tel URL with the phone number
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
        ),
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
