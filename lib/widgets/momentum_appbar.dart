import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class MomentumAppBar extends StatelessWidget implements PreferredSizeWidget {
  PreferredSizeWidget? bottom;
  MomentumAppBar({super.key, this.bottom})
      : preferredSize = bottom == null
            ? const Size.fromHeight(kToolbarHeight)
            : const Size.fromHeight(100);

  @override
  PreferredSizeWidget build(BuildContext context) {
    return AppBar(
      title: buildAppBarTitle(context),
      centerTitle: true,
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      bottom: bottom,
    );
  }

  Widget buildAppBarTitle(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/logo.svg',
      fit: BoxFit.contain,
      height: 40,
    );
  }

  @override
  final Size preferredSize;
}
