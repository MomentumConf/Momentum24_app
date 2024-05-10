import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      centerTitle: false,
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      bottom: bottom,
    );
  }

  Widget buildAppBarTitle(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/logo.svg',
    );
  }

  @override
  final Size preferredSize;
}
