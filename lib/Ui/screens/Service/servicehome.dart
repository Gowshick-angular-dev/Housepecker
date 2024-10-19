// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:Housepecker/Ui/screens/Service/servicelist.dart';
//
// import '../../../utils/api.dart';
// import '../../Theme/theme.dart';
// import '../widgets/shimmerLoadingContainer.dart';
//
//
// class ServiceHome extends StatefulWidget {
//   const ServiceHome({super.key});
//
//   @override
//   State<ServiceHome> createState() => _ServiceHomeState();
// }
//
// class _ServiceHomeState extends State<ServiceHome> {
//
//   bool Loading = false;
//   List servicesList = [];
//   Map<String, List>? servicesCatList;
//
//   @override
//   void initState() {
//     getServices();
//     super.initState();
//   }
//
//   Future<void> getServices() async {
//     setState(() {
//       Loading = true;
//     });
//     var response = await Api.get(url: Api.services);
//     if(!response['error']) {
//       Map<String, List> groupedByCity = {};
//
//       for (var person in response['data']) {
//         if (groupedByCity.containsKey(person['service_label']['name'])) {
//           groupedByCity[person['service_label']['name']]!.add(person);
//         } else {
//           groupedByCity[person['service_label']['name']] = [person];
//         }
//       }
//       setState(() {
//         servicesList = response['data'];
//         servicesCatList = groupedByCity;
//         Loading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: tertiaryColor_,
//         title: Text('Services',
//           style: TextStyle(
//               fontSize: 14,color: Colors.white
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(15),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if(Loading)
//                 GridView.builder(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     childAspectRatio:2/1.9,
//                     crossAxisSpacing: 10.0,
//                     mainAxisSpacing: 10.0,
//                   ),
//                   itemCount: 18,
//                   itemBuilder: (context, index) {
//                     return ClipRRect(
//                       clipBehavior: Clip.antiAliasWithSaveLayer,
//                       borderRadius: BorderRadius.all(Radius.circular(15)),
//                       child: CustomShimmer(height: 90, width: 90),
//                     );
//                   },
//                 ),
//               if(!Loading)
//                 for (var key in servicesCatList!.keys)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: 10,),
//                       Text(key,
//                         style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.black38,
//                             fontWeight: FontWeight.w600
//                         ),),
//                       SizedBox(height: 5,),
//                       GridView.builder(
//                       shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 3,
//                         childAspectRatio:2/1.9,
//                         crossAxisSpacing: 10.0,
//                         mainAxisSpacing: 10.0,
//                       ),
//                       itemCount: servicesCatList![key]!.length,
//                       itemBuilder: (context, index) {
//                         final item = servicesCatList![key]![index];
//                         return InkWell(
//                           onTap: (){
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(builder: (context) => ServiceList(id: item['id'], name: item['name'])),
//                             );
//                           },
//                           child: Container(
//                             padding: EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: Color(0xfff9f9f9),
//                               border: Border.all(
//                                   color: Color(0xffe5e5e5),
//                                   width: 1
//                               ),
//                               borderRadius: BorderRadius.circular(15),
//                             ),alignment: Alignment.center,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(15),
//                                   child: Image.network(
//                                     item['icon']!,
//                                     height: 30,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                                 SizedBox(height: 5,),
//                                 Text(item['name']!,
//                                   style: TextStyle(
//                                       fontSize: 11,
//                                       color: Color(0xff646464)
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 )
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//
//                                       ),
//                     ],
//                   ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Housepecker/Ui/screens/Service/servicelist.dart';
import '../../../utils/api.dart';
import '../../../utils/ui_utils.dart';
import '../../Theme/theme.dart';
import '../widgets/shimmerLoadingContainer.dart';

class ServiceHome extends StatefulWidget {
  const ServiceHome({super.key});

  @override
  State<ServiceHome> createState() => _ServiceHomeState();
}

class _ServiceHomeState extends State<ServiceHome> {
  bool Loading = false;
  List servicesList = [];
  Map<String, List>? servicesCatList;
  Map<String, List>? filteredServicesCatList;
  TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    _searchController.addListener(_onSearchChanged);
    getServices();
    super.initState();
  }


  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text.toLowerCase();
      filterServices();
    });
  }

  Future<void> getServices() async {
    setState(() {
      Loading = true;
    });
    var response = await Api.get(url: Api.services);
    if (!response['error']) {
      Map<String, List> groupedByCity = {};

      for (var person in response['data']) {
        if (groupedByCity.containsKey(person['service_label']['name'])) {
          groupedByCity[person['service_label']['name']]!.add(person);
        } else {
          groupedByCity[person['service_label']['name']] = [person];
        }
      }
      setState(() {
        servicesList = response['data'];
        servicesCatList = groupedByCity;
        filteredServicesCatList = groupedByCity;
        Loading = false;
      });
    }
  }

  void filterServices() {
    if (_searchText.isEmpty) {
      filteredServicesCatList = servicesCatList;
    } else {
      Map<String, List> filteredMap = {};

      servicesCatList!.forEach((key, value) {
        if (key.toLowerCase().contains(_searchText)) {
          // Add the whole category if the key matches
          filteredMap[key] = value;
        } else {
          // Add items that match the search text in their name
          List filteredItems = value
              .where((item) =>
              item['name'].toLowerCase().contains(_searchText))
              .toList();
          if (filteredItems.isNotEmpty) {
            filteredMap[key] = filteredItems;
          }
        }
      });

      setState(() {
        filteredServicesCatList = filteredMap;
      });
    }
  }
  String? selectedSubcategory;

  // Example data structure
  final Map<String, List<String>> categories = {
    'Fruits': ['Apple', 'Banana', 'Orange'],
    'Vegetables': ['Carrot', 'Broccoli', 'Spinach'],
    'Dairy': ['Milk', 'Cheese', 'Yogurt'],
  };

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> items = [];

    categories.forEach((category, subcategories) {
      // Add the category as a non-selectable item
      items.add(
        DropdownMenuItem<String>(
          value: null, // Null value indicates non-selectable
          enabled: false, // Make this item non-selectable
          child: Text(
            category,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );

      // Add each subcategory as a selectable item
      for (String subcategory in subcategories) {
        items.add(
          DropdownMenuItem<String>(
            value: subcategory,
            child: Text(subcategory),
          ),
        );
      }
    });

    return items;
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: UiUtils.buildAppBar(context,
          showBackButton: true,
          title:'Services',
          actions: [
          ]),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
           /*   DropdownButton<String>(
                hint: Text('Select Subcategory'),
                value: selectedSubcategory,
                items: dropdownItems,
                onChanged: (value) {
                  setState(() {
                    selectedSubcategory = value;
                  });
                },
              ),*/
              // SizedBox(height: 20),
              // if (selectedSubcategory != null) ...[
              //   Text('Selected: $selectedSubcategory'),
              // ],
              // Search Input
              Container(
                height: size.height * 0.06,
                width: size.width,
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 0), // Padding for left and right spacing
                child: Center(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 0), // Align text vertically in center
                      hintText: "Search Services...",
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
              SizedBox(height: 20),
              if (Loading)
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2 / 1.9,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: 18,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      child: CustomShimmer(height: 90, width: 90),
                    );
                  },
                ),
              if (!Loading && filteredServicesCatList != null)
                for (var key in filteredServicesCatList!.keys)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        key,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black38,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 5),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2 / 1.9,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                        ),
                        itemCount: filteredServicesCatList![key]!.length,
                        itemBuilder: (context, index) {
                          final item = filteredServicesCatList![key]![index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServiceList(
                                      id: item['id'], name: item['name']),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(0xfff9f9f9),
                                border: Border.all(
                                    color: Color(0xffe5e5e5), width: 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      item['icon']!,
                                      height: 30,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    item['name']!,
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xff646464)),
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
