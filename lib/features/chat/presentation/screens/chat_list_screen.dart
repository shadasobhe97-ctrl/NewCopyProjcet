import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/enums/user_role.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/auth/login/data/repositories/session_repository.dart';
import 'package:kids_transport/features/chat/data/repositories/chat_repository.dart';
import '../cubit/chat_list_cubit.dart';
import '../cubit/chat_list_state.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatefulWidget {
  final UserRole userRole;

  const ChatListScreen({super.key, required this.userRole});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider<ChatListCubit>(
      create: (context) =>
          getIt<ChatListCubit>()..getConversations(widget.userRole),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text(
              'المحادثات المباشرة',
              style: AppTextStyles.style(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
            foregroundColor: isDark ? AppColors.white : AppColors.textDark,
            surfaceTintColor: Colors.transparent,
          ),
          body: BlocBuilder<ChatListCubit, ChatListState>(
            builder: (context, state) {
              if (state is ChatListLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                );
              }

              if (state is ChatListError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 48.r,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.style(
                            fontSize: 14.sp,
                            color: isDark
                                ? AppColors.grey300
                                : AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<ChatListCubit>().getConversations(
                              widget.userRole,
                            );
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(
                            'إعادة المحاولة',
                            style: AppTextStyles.style(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 12.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is ChatListLoaded) {
                final list = state.conversations;
                final session = getIt<SessionRepository>();
                final currentUserId = session.getUserId() ?? '';

                if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: isDark
                                  ? AppColors.grey600
                                  : AppColors.grey400,
                              size: 64.r,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'لا توجد محادثات نشطة حالياً',
                              style: AppTextStyles.style(
                                fontSize: 14.sp,
                                color: isDark
                                    ? AppColors.grey400
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        final currentUserRole = session.getRoleName() ?? '';
                        final isSubActive =
                            item.subscriptionStatus.toLowerCase() == 'active';

                        Future<bool?> showDeleteDialog() async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (ctx) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: AlertDialog(
                                backgroundColor: isDark
                                    ? AppColors.surfaceDark
                                    : AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                title: Text(
                                  'حذف المحادثة',
                                  style: AppTextStyles.style(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.white
                                        : AppColors.textDark,
                                  ),
                                ),
                                content: Text(
                                  'هل أنت أثق من حذف هذه المحادثة؟ ستختفي من قائمتك حتى يتم إرسال رسالة جديدة.',
                                  style: AppTextStyles.style(
                                    fontSize: 13.5.sp,
                                    color: isDark
                                        ? AppColors.grey300
                                        : AppColors.textDark,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(
                                      'إلغاء',
                                      style: AppTextStyles.style(
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                    ),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text(
                                      'حذف',
                                      style: AppTextStyles.style(
                                        fontSize: 13.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Dismissible(
                          key: Key(item.chatRoomId),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) => showDeleteDialog(),
                          onDismissed: (direction) {
                            getIt<ChatRepository>().deleteConversationForMe(
                              chatRoomId: item.chatRoomId,
                              currentUserId: currentUserId,
                            );
                          },
                          background: Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                              size: 28.r,
                            ),
                          ),
                          child: Card(
                            margin: EdgeInsets.only(bottom: 12.h),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              side: BorderSide(
                                color: isDark
                                    ? AppColors.surfaceDark.withValues(
                                        alpha: 0.5,
                                      )
                                    : AppColors.grey200,
                                width: 1,
                              ),
                            ),
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.white,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatRoomScreen(
                                      chatRoomId: item.chatRoomId,
                                      otherUserName: item.otherUserName,
                                      otherUserPhoto: item.otherUserPhoto,
                                      canChat: item.canChat,
                                      currentUserId: currentUserId,
                                      currentUserRole: currentUserRole,
                                    ),
                                  ),
                                );
                              },
                              onLongPress: () async {
                                final confirmed = await showDeleteDialog();
                                if (confirmed == true) {
                                  await getIt<ChatRepository>()
                                      .deleteConversationForMe(
                                        chatRoomId: item.chatRoomId,
                                        currentUserId: currentUserId,
                                      );
                                }
                              },
                              borderRadius: BorderRadius.circular(16.r),
                              child: Padding(
                                padding: EdgeInsets.all(12.w),
                                child: Row(
                                  children: [
                                    // Avatar Image & Real-time Unread Badge
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            24.r,
                                          ),
                                          child: Container(
                                            width: 48.w,
                                            height: 48.w,
                                            color: isDark
                                                ? AppColors.grey800
                                                : AppColors.grey100,
                                            child:
                                                item.otherUserPhoto != null &&
                                                    item
                                                        .otherUserPhoto!
                                                        .isNotEmpty
                                                ? CachedNetworkImage(
                                                    imageUrl:
                                                        item.otherUserPhoto!,
                                                    fit: BoxFit.cover,
                                                    placeholder:
                                                        (
                                                          context,
                                                          url,
                                                        ) => const Center(
                                                          child: SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                          ),
                                                        ),
                                                    errorWidget:
                                                        (
                                                          context,
                                                          url,
                                                          error,
                                                        ) => Icon(
                                                          Icons.person_rounded,
                                                          color: isDark
                                                              ? AppColors
                                                                    .grey400
                                                              : AppColors
                                                                    .grey600,
                                                          size: 24.r,
                                                        ),
                                                  )
                                                : Icon(
                                                    Icons.person_rounded,
                                                    color: isDark
                                                        ? AppColors.grey400
                                                        : AppColors.grey600,
                                                    size: 24.r,
                                                  ),
                                          ),
                                        ),

                                        // Real-time Unread Badge
                                        StreamBuilder<int>(
                                          stream: getIt<ChatRepository>()
                                              .getUnreadCountStream(
                                                item.chatRoomId,
                                                currentUserId,
                                              ),
                                          builder: (context, snapshot) {
                                            final count = snapshot.data ?? 0;
                                            if (count == 0) {
                                              return const SizedBox();
                                            }

                                            return Positioned(
                                              top: -3.h,
                                              right: -3.w,
                                              child: Container(
                                                padding: EdgeInsets.all(4.r),
                                                decoration: const BoxDecoration(
                                                  color: AppColors.error,
                                                  shape: BoxShape.circle,
                                                ),
                                                constraints: BoxConstraints(
                                                  minWidth: 18.r,
                                                  minHeight: 18.r,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    count > 99
                                                        ? '99+'
                                                        : '$count',
                                                    style: AppTextStyles.style(
                                                      fontSize: 9.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 12.w),
                                    // Info Columns
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.otherUserName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.style(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? AppColors.white
                                                  : AppColors.textDark,
                                            ),
                                          ),
                                          if (item.otherUserPhone != null &&
                                              item
                                                  .otherUserPhone!
                                                  .isNotEmpty) ...[
                                            SizedBox(height: 4.h),
                                            Text(
                                              item.otherUserPhone!,
                                              style: AppTextStyles.style(
                                                fontSize: 11.5.sp,
                                                color: isDark
                                                    ? AppColors.grey400
                                                    : AppColors.textMuted,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    // Subscription Status Badge
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSubActive
                                            ? AppColors.success.withValues(
                                                alpha: 0.12,
                                              )
                                            : AppColors.error.withValues(
                                                alpha: 0.12,
                                              ),
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                        border: Border.all(
                                          color: isSubActive
                                              ? AppColors.success.withValues(
                                                  alpha: 0.25,
                                                )
                                              : AppColors.error.withValues(
                                                  alpha: 0.25,
                                                ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        isSubActive
                                            ? 'اشتراك نشط'
                                            : 'اشتراك منتهي',
                                        style: AppTextStyles.style(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: isSubActive
                                              ? AppColors.success
                                              : AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
