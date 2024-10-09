import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../utils/api.dart';
import '../../Theme/theme.dart';
import '../Advertisement/loanAdForm.dart';
import '../widgets/shimmerLoadingContainer.dart';
import 'LoanList.dart';

class LoanHome extends StatefulWidget {
  const LoanHome({super.key});

  @override
  State<LoanHome> createState() => _LoanHomeState();
}

class _LoanHomeState extends State<LoanHome> {

  TextEditingController searchControler = TextEditingController();
  TextEditingController locationControler = TextEditingController();
  TextEditingController branchControler = TextEditingController();
  List bankList = [];
  List loanList = [];
  List agentList = [];
  bool bankLoading = true;
  bool tapped = false;
  String agentType = '';
  String selectedBank = '';

  String dropdownvalue6 = 'Chennai';
  var items6 = ['Chennai','Madurai'];
  String dropdownvalue5 = 'Select Locality';
  var items5 = ['Select Locality','Tamil'];
  String loanType = '';
  var items4 = ['Loan Type','Gold Loan'];
  final serviceIncludeList = [
    { 'image': 'assets/Loans/1.png', },
    {'image': 'assets/Loans/2.png',},
    {'image': 'assets/Loans/3.png',},
    {'image': 'assets/Loans/4.png',},
    {'image': 'assets/Loans/5.png', },
    {'image': 'assets/Loans/6.png', }
  ];

  @override
  void initState() {
    getBanks(loanType, searchControler.text, locationControler.text, branchControler.text);
    getLoanTypes();

    super.initState();
  }

  Future<void> getBanks(String? loanType, String? search, String? location, String? branch) async {
    setState(() {
      bankLoading = true;
    });
    var response = await Api.get(url: Api.banksList, queryParameters: {
      'loan': loanType,
      'search': search,
      'location': location,
      'branch': branch,
    });
    if(!response['error']) {
      setState(() {
        bankList = response['data'];
        bankLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: tertiaryColor_,
        title: Text('Loan',
          style: TextStyle(
            fontSize: 14,color: Colors.white
          ),
        ),
        // actions: [
        //   InkWell(
        //     onTap: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => LoanAdForm()),
        //       );
        //     },
        //     child: Center(
        //       child: Padding(
        //         padding: const EdgeInsets.all(15),
        //         child: Container(
        //           child: Text('Add',
        //             style: TextStyle(
        //                 fontSize: 14,color: Colors.white
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   )
        // ]
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Container(
                    //   width: double.infinity,
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(30.0),
                    //     border: Border.all(
                    //       color: Color(0xffebebeb),
                    //       width: 1
                    //     )
                    //   ),
                    //   padding: EdgeInsets.fromLTRB(15, 0, 6, 0),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: [
                    //
                    //       Expanded(
                    //         child: TextFormField(
                    //           controller: searchControler,
                    //           onChanged: (String? val) {
                    //             getBanks(loanType, searchControler.text, val!, branchControler.text);
                    //           },
                    //           decoration: const InputDecoration(
                    //               hintText: 'Search...',
                    //               hintStyle: TextStyle(
                    //                 fontFamily: 'Poppins',
                    //                 fontSize: 14.0,
                    //                 color: Color(0xff9c9c9c),
                    //                 fontWeight: FontWeight.w500,
                    //                 decoration: TextDecoration.none,
                    //               ),
                    //               enabledBorder: UnderlineInputBorder(
                    //                 borderSide: BorderSide(
                    //                   color: Colors.transparent,
                    //                 ),
                    //               ),
                    //               focusedBorder: UnderlineInputBorder(
                    //                   borderSide: BorderSide(
                    //                     color: Colors.transparent,
                    //                   ))
                    //           ),
                    //         ),
                    //       ),
                    //
                    //       Container(
                    //         width: 35,
                    //         height: 35,
                    //         decoration: BoxDecoration(
                    //             borderRadius: BorderRadius.circular(50),
                    //           color: Color(0xff117af9),
                    //         ),
                    //         child: Center(
                    //           child: Image.asset(
                    //             'assets/Home/__Search.png',
                    //             width: 20,
                    //             height: 20.0,
                    //             fit: BoxFit.cover,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(height: 15,),
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
                                controller: locationControler,
                                onChanged: (String? val) {
                                  getBanks(loanType, searchControler.text, val!, branchControler.text);
                                },
                                decoration: const InputDecoration(
                                    hintText: 'Location..',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12.0,
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
                        SizedBox(width: 5,),
                        // Expanded(
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       border: Border.all(
                        //           width: 1,
                        //           color: Color(0xffe1e1e1)
                        //       ),
                        //       color: Color(0xfff5f5f5),
                        //       borderRadius: BorderRadius.circular(10.0), // Optional: Add border radius
                        //     ),
                        //     child: Padding(
                        //       padding: const EdgeInsets.only(left: 8.0,right: 5),
                        //       child: TextFormField(
                        //         controller: branchControler,
                        //         onChanged: (String? val) {
                        //           getBanks(loanType, searchControler.text, locationControler.text, val!);
                        //         },
                        //         decoration: const InputDecoration(
                        //             hintText: 'Branch..',
                        //             hintStyle: TextStyle(
                        //               fontFamily: 'Poppins',
                        //               fontSize: 14.0,
                        //               color: Color(0xff9c9c9c),
                        //               fontWeight: FontWeight.w500,
                        //               decoration: TextDecoration.none,
                        //             ),
                        //             enabledBorder: UnderlineInputBorder(
                        //               borderSide: BorderSide(
                        //                 color: Colors.transparent,
                        //               ),
                        //             ),
                        //             focusedBorder: UnderlineInputBorder(
                        //                 borderSide: BorderSide(
                        //                   color: Colors.transparent,
                        //                 ))
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(width: 5,),
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
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
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
                                    child: Text('Loan Type', maxLines: 1,),
                                    enabled: false,
                                ), ...loanList.map((items) {
                                  return DropdownMenuItem(
                                      value: items['id'].toString(),
                                      child: Text(items['name'], maxLines: 1,)
                                  );
                                }
                                ).toList()],
                                onChanged: (String? newValue){
                                  setState(() {
                                    loanType = newValue!;
                                  });
                                  getBanks(newValue!, searchControler.text, locationControler.text, branchControler.text);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25,),
                    Text('Select Bank',style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600
                    ),),
                    SizedBox(height: 25,),
                    if(!bankLoading)
                      GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio:2/1.3,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                      ),
                      itemCount: bankList.length,
                      itemBuilder: (context, index) {
                        final item = bankList[index];
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedBank = item['id'].toString();
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: item['id'].toString() == selectedBank ? Color(0xffffb239) : Color(0xffe5e5e5),
                                width: item['id'].toString() == selectedBank ? 3 : 1
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),alignment: Alignment.center,
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  item['image']!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
            
                    ),
                    if(bankLoading)
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  child: CustomShimmer(height: 90, width: 90),
                                ),
                              ),
                              SizedBox(width: 5,),
                              Expanded(
                                child: ClipRRect(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  child: CustomShimmer(height: 90, width: 90),
                                ),
                              ),
                              SizedBox(width: 5,),
                              Expanded(
                                child: ClipRRect(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  child: CustomShimmer(height: 90, width: 90),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  child: CustomShimmer(height: 90, width: 90),
                                ),
                              ),
                              SizedBox(width: 5,),
                              Expanded(
                                child: ClipRRect(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  child: CustomShimmer(height: 90, width: 90),
                                ),
                              ),
                              SizedBox(width: 5,),
                              Expanded(
                                child: ClipRRect(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  child: CustomShimmer(height: 90, width: 90),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    SizedBox(height: 25,),
                    Text('Select Type',style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600
                    ),),
                    SizedBox(height: 25,),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              agentType = 'DST';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 20,right: 10,top: 10,bottom: 10),
                            decoration: BoxDecoration(
                              color: agentType == 'DST' ? Color(0xfffffbf3) : Color(0xfff2f2f2),
                              border: Border.all(
                                 color: agentType == 'DST' ? Color(0xffffb239) : Color(0xffdcdcdc), width: 1
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),alignment: Alignment.center,
                            child: Row(
                              children: [
                                Text('DST',style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff333333)
                                ),),
                                SizedBox(width: 10,),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.asset(
                                    'assets/Loans/_-113.png',
                                    width: 18.0,
                                    height: 18.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        InkWell(
                          onTap: () {
                            setState(() {
                              agentType = 'DSA';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 20,right: 10,top: 10,bottom: 10),
                            decoration: BoxDecoration(
                              color: agentType == 'DSA' ? Color(0xfffffbf3) : Color(0xfff2f2f2),
                              border: Border.all(
                                  color: agentType == 'DSA' ? Color(0xffffb239) : Color(0xffdcdcdc), width: 1
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),alignment: Alignment.center,
                            child: Row(
                              children: [
                                Text('DSA',style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xff333333)
                                ),),
                                SizedBox(width: 10,),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.asset(
                                    'assets/Loans/_-113.png',
                                    width: 18.0,
                                    height: 18.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        InkWell(
                          onTap: () {
                            setState(() {
                              agentType = '';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(left: 20,right: 20,top: 10,bottom: 10),
                            decoration: BoxDecoration(
                              color: agentType == '' ? Color(0xfffffbf3) : Color(0xfff2f2f2),
                              border: Border.all(
                                  color: agentType == '' ? Color(0xffffb239) : Color(0xffdcdcdc), width: 1
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),alignment: Alignment.center,
                            child: Center(
                              child: Text('Both', style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xff333333)
                              ),),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if(!bankLoading && !tapped && selectedBank != '')
            InkWell(
            onTap: () async {
              setState(() {
                tapped = true;
              });
              var responseAgent = await Api.get(url: Api.agentsList, queryParameters: {
                'bank_id': selectedBank,
                'agent_type': agentType,
                'search': '',
                'location': '',
                'branch': '',
                'loan': '',
              });
              if(!responseAgent['error']) {
                setState(() {
                  // agentList = responseAgent['data'];
                  tapped = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoanList(agents: responseAgent['data'])),
                );
              }
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 10,left: 15,right: 15),
              width: double.infinity,
              height: 48.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xff117af9),
              ),
              child: Text(
                'Search',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
          ),
          if(tapped)
            Container(
            margin: EdgeInsets.only(bottom: 10,left: 15,right: 15),
            width: double.infinity,
            height: 48.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color(0xff117af9),
            ),
            child: Text(
              'Please wait...',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500
              ),
            ),
          )
        ],
      ),
    );
  }
}
