import 'package:flutter/material.dart';

import '../../../utils/Extensions/extensions.dart';
import '../../../utils/responsiveSize.dart';
import '../../../utils/ui_utils.dart';
import 'video_view_screen.dart';

class AllGallaryImages extends StatelessWidget {
  final List images;
  final String? youtubeThumbnail;
  final bool? isProject;
  const AllGallaryImages(
      {super.key, required this.images, this.youtubeThumbnail, this.isProject = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
 backgroundColor: Colors.white,
      appBar: UiUtils.buildAppBar(
        context,
        title: "Images",
        showBackButton: true,
      ),
      body:images.length!=0? GridView.builder(
        itemCount: images.length,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
        itemBuilder: (context, index) {
          if(isProject!) {
            return ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: GestureDetector(
                  onTap: () {
                    // if (images[index].isVideo == true) {
                    //   Navigator.push(context, MaterialPageRoute(
                    //     builder: (context) {
                    //       return VideoViewScreen(videoUrl: images[index].image);
                    //     },
                    //   ));
                    // } else {
                      var stringImages = images.map((e) => e['name']).toList();
                      UiUtils.imageGallaryView(
                        context,
                        images: stringImages,
                        initalIndex: index,
                        then: () {},
                      );
                    // }
                  },
                  child: SizedBox(
                    width: 76.rw(context),
                    height: 76.rh(context),
                    child:
                    // images[index].isVideo == true
                    //     ? Stack(
                    //   fit: StackFit.expand,
                    //   children: [
                    //     UiUtils.getImage(youtubeThumbnail!,
                    //         fit: BoxFit.cover),
                    //     const Icon(
                    //       Icons.play_arrow,
                    //       size: 28,
                    //     )
                    //   ],
                    // ) :
                    UiUtils.getImage(images[index]['name'] ?? "",
                        fit: BoxFit.cover),
                  ),
                ));
          } else {
            return ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: GestureDetector(
                  onTap: () {
                    if (images[index].isVideo == true) {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return VideoViewScreen(videoUrl: images[index].image);
                        },
                      ));
                    } else {
                      var stringImages = images.map((e) => e.imageUrl).toList();
                      UiUtils.imageGallaryView(
                        context,
                        images: stringImages,
                        initalIndex: index,
                        then: () {},
                      );
                    }
                  },
                  child: SizedBox(
                    width: 76.rw(context),
                    height: 76.rh(context),
                    child: images[index].isVideo == true
                        ? Stack(
                      fit: StackFit.expand,
                      children: [
                        UiUtils.getImage(youtubeThumbnail!,
                            fit: BoxFit.cover),
                        const Icon(
                          Icons.play_arrow,
                          size: 28,
                        )
                      ],
                    )
                        : UiUtils.getImage(images[index].imageUrl ?? "",
                        fit: BoxFit.cover),
                  ),
                ));
          }
        },
      ):const Center(child: Text("Images Not Available"),),
    );
  }
}
