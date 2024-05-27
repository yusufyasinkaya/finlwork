import 'package:flutter/material.dart';
import 'package:tiyatrokulubu/screens/chat/service/chat_service.dart';

class ChattedUsersListPage extends StatelessWidget {
  final String userId;

  const ChattedUsersListPage({Key? key, required this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sohbet Ettiğiniz Kişiler'),
      ),
      body: StreamBuilder<List<String>>(
        stream: ChatService().getChattedUsers(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Sohbet edilen kullanıcı bulunamadı.'),
            );
          }
          List<String> chattedUsers = snapshot.data!;
          return ListView.builder(
            itemCount: chattedUsers.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(chattedUsers[index]),
                onTap: () {
                  // Burada tıklanan kullanıcı ile ilgili ek işlemleri yapabilirsiniz.
                },
              );
            },
          );
        },
      ),
    );
  }
}
