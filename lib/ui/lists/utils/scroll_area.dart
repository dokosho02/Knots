import 'package:flutter/material.dart';

class ScrollArea extends StatelessWidget {
  final ScrollController scrollController;
  final double contentPadding;

  const ScrollArea({
    super.key,
    required this.scrollController,
    required this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height * 0.8;

    return Stack(
      children: [
        _buildGestureArea(
          context: context,
          top: 0,
          left: 0,
          right: screenWidth - contentPadding,
          height: screenHeight / 2,
          direction: ScrollDirection.up,
        ),
        _buildGestureArea(
          context: context,
          top: 0,
          left: screenWidth - contentPadding,
          right: 0,
          height: screenHeight / 2,
          direction: ScrollDirection.up,
        ),
        _buildGestureArea(
          context: context,
          bottom: 0,
          left: 0,
          right: screenWidth - contentPadding,
          height: screenHeight / 2,
          direction: ScrollDirection.down,
        ),
        _buildGestureArea(
          context: context,
          bottom: 0,
          left: screenWidth - contentPadding,
          right: 0,
          height: screenHeight / 2,
          direction: ScrollDirection.down,
        ),
      ],
    );
  }

  Widget _buildGestureArea({
    required BuildContext context,
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double height,
    required ScrollDirection direction,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      height: height,
      child: GestureDetector(
        onTap: () => scrollPage(context, direction),
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }

  void scrollPage(BuildContext context, ScrollDirection direction) {
    final double scrollHeight = MediaQuery.of(context).size.height * 0.8 * 0.95; // 确保不包括 AppBar 和 BottomNavigationBar 高度
    final double maxScrollExtent = scrollController.position.maxScrollExtent;
    final double minScrollExtent = scrollController.position.minScrollExtent;
    final double currentOffset = scrollController.offset;

    // 计算新的偏移量
    final double offsetChange = direction == ScrollDirection.down
        ? scrollHeight
        : -scrollHeight;
    final double newOffset = currentOffset + offsetChange;

    // 判断是否到底或到顶
    if (direction == ScrollDirection.down && newOffset > maxScrollExtent) {
      scrollController.jumpTo(maxScrollExtent); // 达到底部，滚动到最大偏移量
    } else if (direction == ScrollDirection.up && newOffset < minScrollExtent) {
      scrollController.jumpTo(minScrollExtent); // 达到顶部，滚动到最小偏移量
    } else {
      scrollController.jumpTo(newOffset); // 执行滚动
    }
  }
}

enum ScrollDirection { up, down }
