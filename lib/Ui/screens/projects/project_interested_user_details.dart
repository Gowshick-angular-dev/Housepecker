import 'dart:convert';

import 'package:Housepecker/utils/Extensions/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../utils/api.dart';
import '../../../utils/constant.dart';
import '../../../utils/ui_utils.dart';

import 'package:http/http.dart' as http;

import '../widgets/Erros/no_data_found.dart';


class ProjectInterestedUsersDetails extends StatefulWidget {
  int? projectId;
  ProjectInterestedUsersDetails({super.key,this.projectId});

  @override
  State<ProjectInterestedUsersDetails> createState() => _InterestedUsersDetailsState();
}

class _InterestedUsersDetailsState extends State<ProjectInterestedUsersDetails> {

  List intersetedList = [];
  bool isLoading = false;

  int? statusLive;

  @override
  void initState() {
    super.initState();
    fetchInterestedUsers();
  }


  Future<void> fetchInterestedUsers() async {
    setState(() {
      isLoading = true;
    });
    var response = await Api.get(url: Api.getInterestedUserProjects+"?project_id=${widget.projectId}", );
    if(!response['error']) {
      setState(() {
        intersetedList = response['data'];
        isLoading = false;
      });
    }
  }

  Future<void> statusUpdate({required int status,required int intersetId}) async {
    var response = await Api.post(url: Api.postProjectInterstedStatus, parameter: {
      'interested_id': intersetId,
      'status': status,
    },);
    if(!response['error']) {
      setState(() {
        var userIndex = intersetedList.indexWhere((user) => user['id'] == intersetId);
        if (userIndex != -1) {
          intersetedList[userIndex]['status'] = status;
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Color(0xff117af9),
            content: Text("Status Update Successfully",style: TextStyle(color: Colors.white),)));
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: UiUtils.buildAppBar(context,
            showBackButton: true,
            title: UiUtils.getTranslatedLabel(context, "Interested Users Details")),
        body:isLoading
            ? Center(child: Center(
          child: UiUtils.progress(
            normalProgressColor: context.color.tertiaryColor,
          ),
        ),)
            :Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              const Text(
                "Interested Users Details",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 15),
              if(intersetedList.isNotEmpty)
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: ()=>fetchInterestedUsers(),
                    color: Color(0xff117af9),
                    child: ListView.separated(
                        separatorBuilder: (context,i)=>SizedBox(height: 15,),
                        scrollDirection: Axis.vertical,
                        itemCount: intersetedList.length,
                        itemBuilder: (context,index){
                          var user = intersetedList[index];
                          var statusLive = user['status'];
                          return  Stack(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        textBuilder1("Name"),
                                        textBuilder1("Email"),
                                        textBuilder1("Mobile No"),
                                        textBuilder1("Status"),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        textBuilder1(":"),
                                        textBuilder1(":"),
                                        textBuilder1(":"),
                                        textBuilder1(":"),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          textBuilder(user['customer']['name']??'-'),
                                          textBuilder(user['customer']['email']??'-'),
                                          textBuilder(user['customer']['mobile']??'-'),
                                          Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(statusLive==0?"Pending":"Contected",style: TextStyle(fontSize: 13,  color: statusLive == 0 ? Colors.red : Color(0xff117af9),fontWeight: FontWeight.w600),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                  top: 0,
                                  right: 0,
                                  child:  PopupMenuButton<int>(
                                    icon: const Icon(
                                      Icons.more_vert,
                                      size: 23,
                                      color: Colors.black,
                                    ),
                                    itemBuilder: (context) => [
                                      PopupMenuItem<int>(
                                        onTap: () async {
                                          await statusUpdate(status: 0, intersetId: user['id']??0);
                                        },
                                        value: 1,
                                        child:  Row(
                                          children: [
                                            Text("Pending", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500,fontSize: 12),),
                                            SizedBox(width: 10,),
                                            if (statusLive == 0)
                                              Image.asset("assets/assets/Images/_check.png", height: 16, width: 16),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<int>(
                                        onTap: () async {
                                          await statusUpdate(status: 1, intersetId: user['id']??0);
                                        },
                                        value: 2,
                                        child: Row(
                                          children: [
                                            Text("Contected", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500,fontSize: 12),),
                                            SizedBox(width: 10,),
                                            if (statusLive == 1)
                                              Image.asset("assets/assets/Images/_check.png", height: 16, width: 16),
                                          ],
                                        ),
                                      ),
                                    ],

                                    color: Color(0xFFFFFFFF),
                                  )
                              )
                            ],
                          );
                        }),
                  ),
                )
              else Expanded(child: Expanded(child: NoDataFound())),
            ],
          ),
        )
    );

  }
  Widget textBuilder1(String value) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Text(value,style: TextStyle(fontSize: 13,fontWeight: FontWeight.w600,color: Colors.black),maxLines: 1,overflow: TextOverflow.ellipsis,),
    );
  }
  Widget textBuilder(String value) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Text(value,style: TextStyle(fontSize: 13),maxLines: 1,overflow: TextOverflow.ellipsis,),
    );
  }
}