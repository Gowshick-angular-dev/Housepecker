part of '../personalized_property_screen.dart';

class NearbyInterest extends StatefulWidget {
  final PageController controller;
  final PersonalizedVisitType type;
  final Function(List<int> selectedNearbyPlacesIds) onInteraction;
  const NearbyInterest({
    super.key,
    required this.controller,
    required this.onInteraction,
    required this.type,
  });

  @override
  State<NearbyInterest> createState() => _NearbyInterestState();
}

class _NearbyInterestState extends State<NearbyInterest>
    with AutomaticKeepAliveClientMixin {
  List<int> selectedIds = personalizedInterestSettings.outdoorFacilityIds;
  @override
  void initState() {
    context.read<FetchOutdoorFacilityListCubit>().fetchIfFailed();
    Future.delayed(
      Duration(seconds: 1),
      () {
        setState(() {});
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool isFirstTime = widget.type == PersonalizedVisitType.FirstTime;
    var facilityList = context.watch<FetchOutdoorFacilityListCubit>().getList();
    int facilityLength = facilityList.length;
    FetchOutdoorFacilityListState state =
        context.watch<FetchOutdoorFacilityListCubit>().state;
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xfff6faff),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("Choose Nearby".translate(context))
                          .color(context.color.textColorDark)
                          .size(17)
                          .centerAlign(),
                      Text("Places".translate(context))
                          .color(context.color.textColorDark)
                          .size(17),
                      const SizedBox(
                        height: 20,
                      ),

                      Text("Get recommendations for properties that are close to these locations".translate(context))
                          .color(context.color.textColorDark.withOpacity(0.6))
                          .size(context.font.small),
                    ],
                  ),
                ),
                if (isFirstTime)
                  GestureDetector(
                      onTap: () {
                        HelperUtils.killPreviousPages(
                          context,
                          Routes.main,
                          {"from": "login"},
                        );
                      },
                      child: Chip(
                          label: Text("skip".translate(context))
                              .color(context.color.buttonColor))),
                // const Chip(label: Text("Skip")),

              ],
            ),
          ),



          const SizedBox(
            height: 15,
          ),
          if (state is FetchOutdoorFacilityListInProgress) ...{
            UiUtils.progress()
          },
          Wrap(
            children: List.generate((facilityLength), (index) {
              OutdoorFacility facility = facilityList[index];
              return Padding(
                padding: const EdgeInsets.only(right : 6, bottom : 6),
                child: GestureDetector(
                  onTap: () {
                    selectedIds.addOrRemove(facility.id!);
                    widget.onInteraction.call(selectedIds);
                    setState(() {});
                  },
                  child: Chip(
                      shape: StadiumBorder(
                          side: BorderSide(color: selectedIds.contains(facility.id!)
                              ? Color(0xffffa920)
                              : Color(0xffd9d9d9))),
                      backgroundColor: selectedIds.contains(facility.id!)
                          ? Color(0xfffffbf3)
                          : Color(0xfff2f2f2),
                      padding: const EdgeInsets.all(5),
                      label: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(facility.name.toString(),style: TextStyle(
                          color: Color(0xff333333),
                          fontSize: 13,
                        ),)
                      )),
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
