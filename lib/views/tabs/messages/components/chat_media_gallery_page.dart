import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/models/chat_item_model.dart';
import 'package:lamatdating/providers/chat_provider.dart';
import 'package:lamatdating/views/loading_error/error_page.dart';
import 'package:lamatdating/views/loading_error/loading_page.dart';
import 'package:lamatdating/views/others/video_player_page.dart';

class ChatMediaGalleryConsumerPage extends ConsumerWidget {
  final String matchId;
  const ChatMediaGalleryConsumerPage({
    super.key,
    required this.matchId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatStreams = ref.watch(chatStreamProviderProvider(matchId));

    return chatStreams.when(
        data: (data) {
          final List<ChatItemModel> chatsWithImagesOrVideos = [];
          for (var chat in data) {
            if (chat.image != null || chat.video != null) {
              chatsWithImagesOrVideos.add(chat);
            }
          }
          return ChatMediaGalleryPage(chats: chatsWithImagesOrVideos);
        },
        error: (_, __) => const ErrorPage(),
        loading: () => const LoadingPage());
  }
}

class ChatMediaGalleryPage extends StatefulWidget {
  final List<ChatItemModel> chats;
  const ChatMediaGalleryPage({
    super.key,
    required this.chats,
  });

  @override
  State<ChatMediaGalleryPage> createState() => _ChatMediaGalleryPageState();
}

class _ChatMediaGalleryPageState extends State<ChatMediaGalleryPage> {
  @override
  Widget build(BuildContext context) {
    widget.chats.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    List<ChatItemModel> chatsWithImages =
        widget.chats.where((chat) => chat.image != null).toList();
    List<ChatItemModel> chatsWithVideos =
        widget.chats.where((chat) => chat.video != null).toList();

    //Tab View with images and videos
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.mediaGallery.tr()),
          bottom: TabBar(
            dividerColor: Colors.transparent,
            indicatorColor: Colors.transparent,
            tabs: [
              Tab(text: LocaleKeys.images.tr()),
              Tab(text: LocaleKeys.videos.tr()),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            chatsWithImages.isEmpty
                ? Center(child: Text(LocaleKeys.noimages.tr()))
                : GridView.builder(
                    itemCount: chatsWithImages.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    content: CachedNetworkImage(
                                        imageUrl:
                                            chatsWithImages[index].image!),
                                  ));
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => PhotoViewPage(
                          //             images: chatsWithImages
                          //                 .map((e) => e.image!)
                          //                 .toList(),
                          //             index: index,
                          //           )),
                          // );
                        },
                        child: CachedNetworkImage(
                            imageUrl: chatsWithImages[index].image!),
                      );
                    },
                  ),
            chatsWithVideos.isEmpty
                ? Center(child: Text(LocaleKeys.novideos.tr()))
                : GridView.builder(
                    itemCount: chatsWithVideos.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: VideoPlayerThumbNail(onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerPage(
                                  videoUrl: chatsWithVideos[index].video!,
                                  isNetwork: true),
                            ),
                          );
                        }),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
