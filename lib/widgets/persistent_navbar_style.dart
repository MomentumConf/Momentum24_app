import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class PersistentNavBarStyle extends StatelessWidget {
  const PersistentNavBarStyle({
    required this.navBarConfig,
    this.navBarDecoration = const NavBarDecoration(),
    this.itemAnimationProperties = const ItemAnimation(),
    super.key,
  });

  final NavBarConfig navBarConfig;
  final NavBarDecoration navBarDecoration;

  /// This controls the animation properties of the items of the NavBar.
  final ItemAnimation itemAnimationProperties;

  Widget _buildItem(ItemConfig item, bool isSelected) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: IconTheme(
              data: IconThemeData(
                size: item.iconSize,
                color: isSelected
                    ? item.activeForegroundColor
                    : item.inactiveForegroundColor,
              ),
              child: isSelected ? item.icon : item.inactiveIcon,
            ),
          ),
          if (item.title != null)
            FittedBox(
              child: Text(
                item.title!,
                style: item.textStyle.apply(
                  color: isSelected
                      ? item.activeForegroundColor
                      : item.inactiveForegroundColor,
                ),
              ),
            ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final double itemWidth = (MediaQuery.sizeOf(context).width -
            navBarDecoration.padding.horizontal) /
        navBarConfig.items.length;

    final boxColor = Theme.of(context).colorScheme.onTertiary;
    return DecoratedNavBar(
      decoration: navBarDecoration,
      filter: navBarDecoration.filter,
      opacity: navBarDecoration.color?.a ?? 1.0,
      height: navBarConfig.navBarHeight,
      child: Stack(
        children: <Widget>[
          Row(
            children: <Widget>[
              AnimatedContainer(
                duration: itemAnimationProperties.duration,
                curve: itemAnimationProperties.curve,
                width: itemWidth * navBarConfig.selectedIndex,
                height: navBarConfig.navBarHeight * 96 / 100,
              ),
              AnimatedContainer(
                duration: itemAnimationProperties.duration,
                curve: itemAnimationProperties.curve,
                width: itemWidth,
                height: navBarConfig.navBarHeight * 96 / 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: const BorderRadius.all(Radius.circular(12))),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navBarConfig.items.map((item) {
              final int index = navBarConfig.items.indexOf(item);
              return Flexible(
                child: InkWell(
                  onTap: () {
                    navBarConfig.onItemSelected(index);
                  },
                  child: Center(
                    child: _buildItem(
                      item,
                      navBarConfig.selectedIndex == index,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
