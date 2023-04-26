import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key, required String cpsId});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text('Info'),
    );
  }
}
