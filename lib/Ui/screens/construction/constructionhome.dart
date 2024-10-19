import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Housepecker/Ui/screens/Service/servicelist.dart';

import '../../../utils/api.dart';
import '../../../utils/ui_utils.dart';
import '../../Theme/theme.dart';
import '../widgets/shimmerLoadingContainer.dart';
import 'constructionlist.dart';

class ConstructionHome extends StatefulWidget {
  const ConstructionHome({super.key});

  @override
  State<ConstructionHome> createState() => _ConstructionHomeState();
}

class _ConstructionHomeState extends State<ConstructionHome> {
  bool loading = false;
  List constructionsList = [];
  List filteredList = [];
  String searchQuery = '';

  @override
  void initState() {
    getConstructionCategories();
    super.initState();
  }

  Future<void> getConstructionCategories() async {
    setState(() {
      loading = true;
    });
    var response = await Api.get(url: Api.constructionTypes);
    if (!response['error']) {
      setState(() {
        constructionsList = response['data'];
        filteredList = constructionsList; // Initialize filtered list with all items
        loading = false;
      });
    }
  }

  // Method to filter the construction categories based on search input
  void filterCategories(String query) {
    setState(() {
      searchQuery = query;
      if (query.isNotEmpty) {
        filteredList = constructionsList
            .where((item) => item['name']
            .toLowerCase()
            .contains(query.toLowerCase())) // You can add more fields if needed
            .toList();
      } else {
        filteredList = constructionsList; // Reset to full list if search is cleared
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true,
          title:'Constructions',
          actions: [
          ]),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Container(
                height: size.height * 0.06,
                width: size.width,
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 0), // Padding for left and right spacing
                child: Center(
                  child: TextField(
                    onChanged: filterCategories,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 0), // Align text vertically in center
                      hintText: "Search constructions...",
                      hintStyle: TextStyle(fontSize: 14),
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25), // Circular border
                        borderSide: BorderSide.none, // Remove the visible border line
                      ),
                      filled: true,
                      fillColor: Color(0xFFF2F2F2), // Slightly different fill color for better contrast
                    ),
                  ),
                ),
              ),

              SizedBox(height: 15),

              // Grid View for construction categories
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2 / 1.9,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: loading ? 14 : filteredList.length,
                itemBuilder: (context, index) {
                  final item = loading ? null : filteredList[index];
                  return loading
                      ? ClipRRect(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    child: CustomShimmer(height: 90, width: 90),
                  )
                      : InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ConstructionList(id: item['id'], name: item['name']),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xfff9f9f9),
                        border: Border.all(
                          color: Color(0xffe5e5e5),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: UiUtils.networkSvg(
                              item['icon'],
                              width: 25,
                              height: 25,
                              color: Color(0xff6b6b6b),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            item['name'],
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xff646464),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
