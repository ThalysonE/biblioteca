import 'package:biblioteca/data/providers/menu_provider.dart';
import 'package:flutter/material.dart';
import 'package:biblioteca/utils/theme.dart';
import 'package:provider/provider.dart';


class BreadCrumb extends StatelessWidget {
  final List<String> breadcrumb;
  final IconData icon;
  const BreadCrumb({super.key, required this.breadcrumb, required this.icon});
  

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14.0),
      height: 43.0,
      width: double.infinity,
      color: const Color.fromRGBO(38, 42, 79, 1),
      child: Row(
        children: breadcrumb
            .asMap()
            .entries
            .map(
              (entry) => BreadCrumbItem(
                name: entry.value,
                isFirst: entry.key == 0,
                breadcrumb: breadcrumb,
                icon: icon,
              ),
            )
            .toList(),
      ),
    );
  }
}
class BreadCrumbItem extends  StatefulWidget  {
  final String name;
  final bool isFirst;
  final List<String>breadcrumb;
  final IconData icon;

  const BreadCrumbItem({super.key, required this.name, required this.isFirst, required this.breadcrumb, required this.icon});

  @override
  State<BreadCrumbItem> createState() => _BreadCrumbItemState();
}

class _BreadCrumbItemState extends State<BreadCrumbItem> {
  bool onIt = false;
  Color color = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        widget.isFirst
            ? Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(widget.icon, color: Colors.white,),
              )
              : const Icon(Icons.chevron_right, color: Colors.white,),
        InkWell(
          mouseCursor: !(widget.name == widget.breadcrumb.last)?SystemMouseCursors.click:SystemMouseCursors.basic,
           onTap: () {
              if (widget.isFirst) {
                context.read<MenuState>().expandedIndex = 0;
              }

              final routeName = widget.name;
              print(widget.breadcrumb);
              final List<String> breadcrumbModificavel = List.from(widget.breadcrumb);
              if(widget.isFirst){
                Navigator.of(context).popUntil((route) => route.isFirst);
              }else{
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).popUntil((route) {
                      final shouldStop = breadcrumbModificavel.last == routeName;
                      if (!shouldStop) breadcrumbModificavel.removeLast();
                      return shouldStop;
                    });
                  }
                });
              }
          },
          onHover: (hovering) {
            setState(() {
              onIt = hovering && widget.name != widget.breadcrumb.last;
              color = onIt
                  ? AppTheme.selectedColor(context)
                  : Colors.white;
            });
          },
            child: Text(
              widget.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    letterSpacing: 0.3,
                    color:(widget.name == widget.breadcrumb.last) 
                        ? Colors.white 
                        : color,
                    decorationColor: onIt && widget.name != widget.breadcrumb.last
                      ? AppTheme.selectedColor(context)
                      :Colors.white,
                    decoration: onIt && widget.name != widget.breadcrumb.last
                    ? TextDecoration.underline
                    : TextDecoration.none,
                  ),
            ),
          ),
      ],
    );
  }
}