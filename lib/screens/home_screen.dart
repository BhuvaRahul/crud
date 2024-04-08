import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud/controller/home_provider.dart';
import 'package:crud/utils/colors_utils.dart';
import 'package:crud/utils/common_string.dart';
import 'package:crud/widgets/center_text_button_widget.dart';
import 'package:crud/utils/font_utils.dart';
import 'package:crud/widgets/logout.dart';
import 'package:crud/widgets/slideble_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const id = 'HomeScreen';

  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();

  void isActive() {
    if (titleFocusNode.hasFocus || descriptionFocusNode.hasFocus) {
      debugPrint("Keyboard is active");
    } else {
      debugPrint("Keyboard is not active");
    }
  }

  @override
  void initState() {
    titleFocusNode.addListener(isActive);
    descriptionFocusNode.addListener(isActive);
    super.initState();
  }

  @override
  void dispose() {
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer(builder: (context, HomeProvider provider, _) {
        return Scaffold(
          backgroundColor: ColorUtils.whiteColor,
          appBar: AppBar(
            title: Text(TextUtils.itemsTxt),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () {
                  showGeneralDialog(
                    context: context,
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return LogoutDialog(
                        onPressed: () {
                          setState(() {
                            provider.logOut(context);
                          });
                        },
                      );
                    },
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.logout),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                showRedeemCouponBottomSheet(context: context);
              });
            },
            tooltip: TextUtils.incrementTxt,
            child: const Icon(Icons.add),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('data_collection').snapshots(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error--------->>>>>: ${snapshot.error}'),
                );
              }
              if ((snapshot.connectionState == ConnectionState.waiting) || snapshot.data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final List<DocumentSnapshot> documents = snapshot.data!.docs;
              return ListView(
                  children: documents
                      .map((doc) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: Slidable(
                              direction: Axis.horizontal,
                              startActionPane: ActionPane(
                                motion: const StretchMotion(),
                                extentRatio: 0.30,
                                children: [
                                  SlidableAction(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                    onPressed: (context) {
                                      debugPrint(".......delete the slide......");
                                      doc.reference.delete();
                                    },
                                    backgroundColor:  ColorUtils.oXFFFF5E5E,
                                    foregroundColor: ColorUtils.whiteColor,
                                    icon: Icons.delete,
                                    label: TextUtils.deleteTxt,
                                  ),
                                ],
                              ),
                              child: SlidableCardWidget(
                                color: ColorUtils.whiteColor,
                                child: Container(
                                  decoration: BoxDecoration(boxShadow: [
                                    BoxShadow(
                                      color: ColorUtils.greyColor.withOpacity(0.2),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                            ),
                                            color: Colors.black26),
                                        child: CachedNetworkImage(
                                          imageUrl: doc['imageUrl'],
                                          imageBuilder: (context, imageProvider) => Container(
                                            decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))),
                                            child: Image(
                                              image: imageProvider,
                                              fit: BoxFit.contain,
                                              height: 80,
                                              width: 80,
                                            ),
                                          ),
                                          progressIndicatorBuilder: (context, url, progress) => const SizedBox(
                                            height: 40,
                                            width: 40,
                                            child: Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(doc['field1']),
                                            Text(doc['field2']),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            provider.titleController.text = doc['field1'];
                                            provider.descriptionController.text = doc['field2'];
                                            provider.updateImageUrl = doc['imageUrl'];
                                            showRedeemCouponBottomSheet(
                                              context: context,
                                              isUpdate: true,
                                              onTap: () async {
                                                provider.isLoading = true;
                                                String imageUrl = await provider.uploadImage(File(provider.imagePath));
                                                debugPrint("😃😃--😃😃->> $imageUrl");
                                                FocusScope.of(context).unfocus();
                                                doc.reference.update({
                                                  'field1': provider.titleController.text,
                                                  'field2': provider.descriptionController.text,
                                                  'imageUrl': provider.imagePath != '' ? imageUrl : doc['imageUrl'],
                                                }).then((value) {
                                                  provider.isLoading = false;
                                                  Navigator.pop(context);
                                                  provider.titleController.clear();
                                                  provider.descriptionController.clear();
                                                  provider.imagePath = '';
                                                });
                                              },
                                            );
                                          });
                                        },
                                        child: CircleAvatar(
                                          backgroundColor:  ColorUtils.oXFF6750A4.withOpacity(0.3),
                                          child: const Icon(Icons.edit, color: ColorUtils.blackColor),
                                        ),
                                      ),
                                      const SizedBox(width: 10)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList());
            },
          ),
        );
      }),
    );
  }

  void showRedeemCouponBottomSheet({
    required BuildContext context,
    bool isUpdate = false,
    void Function()? onTap,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorUtils.whiteColor,
      builder: (BuildContext context) {
        return Consumer(builder: (context, HomeProvider provider, _) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return DraggableScrollableSheet(
              initialChildSize: (titleFocusNode.hasFocus || descriptionFocusNode.hasFocus) ? 0.93 : 0.55, // Set initial size of the sheet
              minChildSize: 0.5, // Set minimum size of the sheet
              maxChildSize: 0.93, // Set maximum size of the sheet
              expand: false,
              builder: (BuildContext context, ScrollController scrollController) {
                return Form(
                  key: provider.formKey,
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                provider.imagePath = '';
                                setState(() {});
                              },
                              child: Text(
                                TextUtils.cancelTxt,
                                style: FontUtils.h18(
                                  fontWeight: FWT.semiBold,
                                  fontColor: ColorUtils.blackColor,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              provider.getImage();
                            });
                          },
                          child: Container(
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: ColorUtils.lightBlackColor,
                            ),
                            child: (provider.imagePath != '')
                                ? Image.file(
                                    File(provider.imagePath),
                                  )
                                : isUpdate == true
                                    ? CachedNetworkImage(
                                        imageUrl: provider.updateImageUrl,
                                        imageBuilder: (context, imageProvider) => Container(
                                          height: 90,
                                          width: 90,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: ColorUtils.lightBlackColor,
                                          ),
                                          child: Image(image: imageProvider),
                                        ),
                                      )
                                    : Image.asset(
                                        'assets/images/media.png',
                                        height: 90,
                                        width: 90,
                                        fit: BoxFit.contain,
                                      ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          focusNode: titleFocusNode,
                          controller: provider.titleController,
                          decoration: InputDecoration(
                            labelText: TextUtils.enterTitleTxt,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return TextUtils.titlerequiredTxt;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          focusNode: descriptionFocusNode,
                          controller: provider.descriptionController,
                          decoration: InputDecoration(
                            labelText: TextUtils.enterDescriptionTxt,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Description is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Stack(
                          children: [
                            provider.isLoading
                                ? Center(
                                    child: Container(
                                      decoration:  const BoxDecoration(
                                        color: ColorUtils.oXFF6750A4,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: const CircularProgressIndicator(color: ColorUtils.whiteColor),
                                    ),
                                  )
                                : CenterTextButtonWidget(
                                    title: isUpdate ? TextUtils.updateTxt : TextUtils.saveTxt,
                                    onTap: isUpdate
                                        ? onTap
                                        : () {
                                            setState(() {
                                              FocusScope.of(context).unfocus();
                                              provider.addData().then((value) {
                                                Navigator.pop(context);
                                              });
                                            });
                                          },
                                  ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          });
        });
      },
    );
  }
}
