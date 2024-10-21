import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';

import '../../../utils/api.dart';
import '../../../utils/ui_utils.dart';
import '../../Theme/theme.dart';
import '../widgets/Erros/no_data_found.dart';
import 'LoanDetail.dart';

class LoanList extends StatefulWidget {
  final List? agents;
  final String? name;
  final String? bank;
  final String? agentType;
  final String? loanType;
  const LoanList({super.key, this.agents,this.name, this.bank, this.agentType, this.loanType});

  @override
  State<LoanList> createState() => _LoanListState();
}

class _LoanListState extends State<LoanList> {

  List banners = [];
  List loanList = [];
  List agentList = [];
  int currentIndex = 0;
  TextEditingController locationControler = TextEditingController();
  String locationValue = '';
  String loanType = '';
  bool Loading = false;

  @override
  void initState() {
    getBanners();
    getLoanTypes();
    if(widget.agents != null && widget.agents!.length > 0) {
      agentList = widget.agents!;
    }
    if(widget.loanType != null && widget.loanType != '') {
      loanType = widget.loanType!;
    }
  }

  Future<void> getLoanTypes() async {
    var response = await Api.get(url: Api.loanTypes);
    if(!response['error']) {
      setState(() {
        loanList = response['data'];
      });
    }
  }

  void getBanners() async {
    var response = await Api.post(url: Api.apiGetSystemSettings, parameter: {
    });
    if(!response['error']) {
      setState(() {
        banners = [response['data']['advertisement_first_banner'], response['data']['advertisement_second_banner']];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true,
          title:'Loan',
          actions: [
          ]),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CarouselSlider(
            //   options: CarouselOptions(
            //     aspectRatio: 1.9,
            //     viewportFraction: 1.0,
            //     autoPlay: true,
            //     onPageChanged: (index, reason) {
            //       setState(() {
            //         currentIndex = index;
            //       });
            //     },
            //   ),
            //   items: [
            //     for (var img in banners)
            //       Container(
            //         child: ClipRRect(
            //           borderRadius: BorderRadius.circular(15.0),
            //           child: CachedNetworkImage(
            //             imageUrl: img,
            //             fit: BoxFit.cover,
            //             width: double.infinity,
            //             placeholder: (context, url) => Image.asset("assets/profile/noimg.png", fit: BoxFit.cover),
            //             errorWidget: (context, url, error) =>  Image.asset("assets/profile/noimg.png", fit: BoxFit.cover),
            //           ),
            //         ),
            //       )
            //   ],
            // ),
            // SizedBox(height: 20,),
            Container(
              padding: EdgeInsets.only(left: 8,top: 8,bottom: 8),
              decoration: BoxDecoration(
                //border: Border.all(  color: Color(0xffebebeb),),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 1),
                    blurRadius: 5,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    width: double.infinity,
                    // decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(10.0),
                    //     border: Border.all(
                    //         color: Color(0xffebebeb),
                    //         width: 1
                    //     )
                    // ),
                    child: Row(
                      children: [
                        Image.asset("assets/Home/__location.png",width: 17,height: 17,color:  const Color(0xff117af9),),
                        SizedBox(width: 10,),
                        Expanded(
                          child: GooglePlaceAutoCompleteTextField(
                            boxDecoration: BoxDecoration(
                                border: Border.all(color: Colors.transparent)
                            ),
                            textEditingController: locationControler,
                            textStyle: TextStyle(fontSize: 14),
                            inputDecoration:   const InputDecoration(
                              hintText: 'Enter City,Locality...',
                              hintStyle: TextStyle(
                                fontSize: 14.0,
                                color: Color(0xff9c9c9c),
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.none,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),

                            googleAPIKey: "AIzaSyDDJ17OjVJ0TS2qYt7GMOnrMjAu1CYZFg8",
                            debounceTime: 800,
                            countries: ["in"],
                            isLatLngRequired: true,
                            getPlaceDetailWithLatLng: (Prediction prediction) {
                              print("placeDetails" + prediction.lng.toString());
                              // lat = prediction.lat.toString();
                              // lng = prediction.lng.toString();
                              setState(() { });
                            },
                            itemClick: (Prediction prediction) {
                              locationControler.text = prediction.description!;
                              locationControler.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: prediction.description!.length));
                              List address = prediction.description!.split(',').reversed.toList();
                              if(address.length >= 3) {
                                locationValue = address[2];

                                setState(() { });
                              } else if(address.length == 2) {
                                locationValue = address[1];

                                setState(() { });
                              } else if(address.length == 1) {
                                locationValue = address[0];

                                setState(() { });
                              }
                            },
                            itemBuilder: (context, index, Prediction prediction) {
                              return Container(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Image.asset("assets/Home/__location.png",width: 17,height: 17,color:  const Color(0xff117af9),),
                                    const SizedBox(width: 7,),
                                    Expanded(
                                        child:
                                        Text("${prediction.description ?? ""}",style: TextStyle(fontSize: 14,color: Colors.black),))
                                  ],
                                ),
                              );
                            },
                            seperatedBuilder: Divider(),
                            isCrossBtnShown: true,
                            placeType: PlaceType.geocode,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 0,),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(thickness: 1.5,),
                  ),
                  SizedBox(height: 0,),
                  Container(
                    padding: EdgeInsets.only(left: 10,right: 10),
                    width: double.infinity,
                    // decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(10.0),
                    //     border: Border.all(
                    //         color: Color(0xffebebeb),
                    //         width: 1
                    //     )
                    // ),
                    child: Row(
                      children: [
                        Image.asset("assets/assets/Images/advertisement.png",height: 20,width: 20,),
                        SizedBox(width: 10,),
                        Expanded(
                          child: DropdownButton(
                            underline: const SizedBox(),
                            isExpanded: true,
                            borderRadius: BorderRadius.circular(8),
                            elevation: 1,
                            dropdownColor:Colors.white,
                            value: loanType,
                            style: TextStyle(
                              color: Color(0xff848484),
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.none,
                            ),
                            // icon: Icon(Icons.keyboard_arrow_down,color:Colors.black,size: 15,),
                            items: [DropdownMenuItem(
                              value: '',
                              child: Text('Loan Type', maxLines: 1,style: TextStyle(fontFamily: 'Manrope',fontSize: 12),),
                              enabled: true,
                            ), ...loanList.map((items) {
                              return DropdownMenuItem(
                                  value: items['id'].toString(),
                                  child: Text(items['name'], maxLines: 1,style: TextStyle(fontSize: 13, color: Colors.black87),)
                              );
                            }
                            ).toList()],
                            onChanged: (String? newValue){
                              setState(() {
                                loanType = newValue!;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),

                ],
              ),
            ),
            SizedBox(height: 10,),
            InkWell(
              onTap: () async {
                setState(() {
                  Loading = true;
                });
                var responseAgent = await Api.get(url: Api.agentsList, queryParameters: {
                  'bank_id': widget.bank,
                  'agent_type': widget.agentType,
                  'search': '',
                  'location': '${locationValue}',
                  'branch': '',
                  'loan': '${loanType}',
                });
                if(!responseAgent['error']) {
                  setState(() {
                    agentList = responseAgent['data'];
                    Loading = false;
                  });
                }
              },
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xff117af9),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/assets/Images/search.png",height: 30,width: 30,),
                  Text(Loading ? "Loading..." : "Search",style: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.w500),)
                ],
              ),
              ),
            ),
            SizedBox(height: 5,),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.agents != null ? widget.agents!.length : 0,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  var item = widget.agents![index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoanDetail(id: item['id'])),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                width: 1,
                                color: Color(0xffe5e5e5)
                            )
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(item['photo'], width: 90, height: 90,fit: BoxFit.cover,),
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('${item['title'] ?? '--'}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),),
                                      SizedBox(width: 2,),
                                      if(item!['status'] == 'Verified')
                                        Image.asset("assets/verified.png",width: 20,height: 20,),
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Row(
                                    children: [
                                      Image.asset("assets/Loans/_-114.png",width: 15,height: 15,),
                                      SizedBox(width: 5,),
                                      Text('${UiUtils.trimNumberToOneDecimal(item['reviews_avg_ratting'] ?? '0')} (${item['user_count']} Ratings)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xff7d7d7d)
                                      ),)
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Row(
                                    children: [
                                      Text('Bank   :',style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xff7d7d7d)
                                      ),),
                                      SizedBox(width: 8,),
                                      Text('${item['bank_name'] ?? '--'}',style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black
                                      ),),
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
                                      Text('${item['branch']}',style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black
                                      ),)
                                    ],
                                  ),
                                  SizedBox(height: 5,),
                                  Row(
                                    children: [
                                      Text('Designation   :',style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xff7d7d7d)
                                      ),),
                                      SizedBox(width: 8,),
                                      Text('${item['agent_type'] ?? 'DST & DSA'}',style: TextStyle(
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
                    ),
                  );
                },
              ),
            ),
            if(widget.agents!.length == 0)
              NoDataFound(),
          ],
        ),
      ),
    );
  }
}
