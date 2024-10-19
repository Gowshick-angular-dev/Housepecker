import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../utils/api.dart';
import '../../../utils/ui_utils.dart';
import '../../Theme/theme.dart';
import '../widgets/Erros/no_data_found.dart';
import 'LoanDetail.dart';

class LoanList extends StatefulWidget {
  final List? agents;
  final String? name;
  const LoanList({super.key, this.agents,this.name});

  @override
  State<LoanList> createState() => _LoanListState();
}

class _LoanListState extends State<LoanList> {

  List banners = [];
  int currentIndex = 0;

  @override
  void initState() {
    getBanners();
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
            CarouselSlider(
              options: CarouselOptions(
                aspectRatio: 1.9,
                viewportFraction: 1.0,
                autoPlay: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
              items: [
                for (var img in banners)
                  Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: CachedNetworkImage(
                        imageUrl: img,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Image.asset("assets/profile/noimg.png", fit: BoxFit.cover),
                        errorWidget: (context, url, error) =>  Image.asset("assets/profile/noimg.png", fit: BoxFit.cover),
                      ),
                    ),
                  )
              ],
            ),
            SizedBox(height: 20,),
            ListView.builder(
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
                              child: Image.network(item['photo'], width: 90, height: 90,),
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
            if(widget.agents!.length == 0)
              NoDataFound(),
          ],
        ),
      ),
    );
  }
}
