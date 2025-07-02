import 'package:flutter/material.dart';
import 'package:good_dismissable/good_dismissable.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<EmailItem> emails = List.generate(
    10,
    (index) => EmailItem(
      id: 'email_$index',
      title: 'Email ${index + 1}',
      subtitle: 'This is a sample email content for item ${index + 1}...',
      isRead: index % 3 == 0,
    ),
  );

  void _removeEmail(String emailId) {
    setState(() {
      emails.removeWhere((email) => email.id == emailId);
    });
  }

  void _markAsRead(String emailId) {
    setState(() {
      final index = emails.indexWhere((email) => email.id == emailId);
      if (index != -1) {
        emails[index] = emails[index].copyWith(isRead: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: emails.length,
        itemBuilder: (context, index) {
          final email = emails[index];

          // Different card types based on index for demonstration
          if (index % 3 == 0) {
            // Delete variant
            return GoodDismissableVariants.delete(
              key: ValueKey(email.id),
              onDismissed: () => _removeEmail(email.id),
              child: _buildEmailTile(email, index),
            );
          } else if (index % 3 == 1) {
            // Archive variant
            return GoodDismissableVariants.archive(
              key: ValueKey(email.id),
              onDismissed: () => _removeEmail(email.id),
              child: _buildEmailTile(email, index),
            );
          } else {
            // Custom variant with progress callback
            return GoodDismissable(
              key: ValueKey(email.id),
              backgroundColor: Colors.orange,
              cardOffset: 12.0,
              initialScale: 0.92,
              onDismissed: () => _markAsRead(email.id),
              onSwipeProgress: (progress) {
                // You can use this for custom animations or haptic feedback
                if (progress > 0.5) {
                  // Trigger haptic feedback or other actions
                }
              },
              backgroundContent: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Text(
                        'Mark Important',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              child: _buildEmailTile(email, index),
            );
          }
        },
      ),
    );
  }

  Widget _buildEmailTile(EmailItem email, int index) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: email.isRead ? Colors.grey : Colors.blue,
        child: Text(
          '${index + 1}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        email.title,
        style: TextStyle(
          fontWeight: email.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Text(
        email.subtitle,
        style: TextStyle(color: email.isRead ? Colors.grey : Colors.black87),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!email.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}

class EmailItem {
  final String id;
  final String title;
  final String subtitle;
  final bool isRead;

  EmailItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isRead = false,
  });

  EmailItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    bool? isRead,
  }) {
    return EmailItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isRead: isRead ?? this.isRead,
    );
  }
}
