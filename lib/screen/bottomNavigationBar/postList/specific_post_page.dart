import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

// 게시한 글과 댓글을 보여주는 Page 입니다.
class SpecificPostPage extends StatelessWidget {
  const SpecificPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('specific Post Page 입니다.'),
      ),
    );
  }
}
