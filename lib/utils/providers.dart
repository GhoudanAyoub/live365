import 'package:LIVE365/Inbox/components/conversation_view_model.dart';
import 'package:LIVE365/Upload/composents/posts_view_model.dart';
import 'package:LIVE365/profile/components/edit_profile__model_view.dart';
import 'package:LIVE365/profile/components/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
  ChangeNotifierProvider(create: (_) => PostsViewModel()),
  ChangeNotifierProvider(create: (_) => UserViewModel()),
  ChangeNotifierProvider(create: (_) => ConversationViewModel()),
];
