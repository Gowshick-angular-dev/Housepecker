import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Housepecker/Ui/screens/main_activity.dart';
import 'package:Housepecker/Ui/screens/projects/projectAdd1.dart';
import 'package:Housepecker/utils/Extensions/extensions.dart';

import '../../../utils/api.dart';
import '../widgets/shimmerLoadingContainer.dart';


class ProjectFormOne extends StatefulWidget {
  final Map? data;
  final bool isEdit;
  const ProjectFormOne({super.key, this.data, this.isEdit = false});

  @override
  State<ProjectFormOne> createState() => _ProjectFormOneState();
}

class _ProjectFormOneState extends State<ProjectFormOne> {

  bool loading = false;
  List categoryList = [];
  int? selectedCategory;

  @override
  void initState() {
    getProjectCategories();
    super.initState();
  }

  Future<void> getProjectCategories() async {
    setState(() {
      loading = true;
    });
    var catResponse = await Api.get(url: Api.apiGetCategories);
    if(!catResponse['error']) {
      setState(() {
        categoryList = catResponse['data'].where((item) => item['id'] == 2 || item['id'] == 4).toList();
        loading = false;
      });
    }
    if(widget.isEdit) {
      setState(() {
        selectedCategory = widget.data!['category_id'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff117af9),
        title: Text('Project Categories',
          style: TextStyle(
              fontSize: 14,color: Colors.white
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio:2/1.9,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: loading ? 2 : categoryList.length,
                itemBuilder: (context, index) {
                  final item = loading ? null : categoryList[index];
                  return loading ? ClipRRect(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    child: CustomShimmer(height: 90, width: 90),
                  ) : InkWell(
                    onTap: () {
                      setState(() {
                        selectedCategory = item['id'];
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selectedCategory != item['id'] ? Color(0xfff9f9f9) : Color(0xfffffbf3),
                        border: Border.all(
                            color: selectedCategory != item['id'] ? Color(0xffe5e5e5) : Color(0xffffa920),
                            width: 1
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.network(
                            item['image'],
                            color: context.color.textColorDark,
                            width: 70,
                            height: 70,
                          ),
                          SizedBox(height: 15,),
                          Text(item['category']!,
                            style: TextStyle(
                                fontSize: 14,
                                color: Color(0xff646464),
                                fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  );
                },

              ),
            ),
          ),
          if(selectedCategory != null)
            InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectFormSecond(
                    data: widget.data, isEdit: widget.isEdit, body: {'category_id': selectedCategory,})),
              );
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
                'Next',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
