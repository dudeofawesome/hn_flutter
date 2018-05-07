import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

class IconButtonToggle extends StatefulWidget {
  /// Whether the toggle is on or off
  final bool value;

  /// Whether the toggle is disabled
  final bool disabled;

  /// The callback that is called when the button is toggled.
  ///
  /// If this is set to null, the button will be disabled.
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final Widget activeIcon;
  final Widget inactiveIcon;
  final String activeTooltip;
  final String inactiveTooltip;
  final double iconSize;

  IconButtonToggle({
    Key key,
    @required this.onChanged,
    @required this.value,
    this.disabled = false,
    @required this.activeColor,
    @required this.inactiveColor,
    @required this.activeIcon,
    this.inactiveIcon,
    this.activeTooltip,
    this.inactiveTooltip,
    this.iconSize,
  }) : super(key: key);

  @override
  _IconButtonToggleState createState() => new _IconButtonToggleState();
}

class _IconButtonToggleState extends State<IconButtonToggle>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  Tween<Color> _colorTween;

  @override
  void initState() {
    super.initState();
    this._controller = new AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: widget.value ? 1.0 : 0.0,
    );
    this._animation = new CurvedAnimation(
      parent: this._controller,
      curve: Curves.easeInOut,
    )..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      });
    this._colorTween =
        new ColorTween(begin: widget.inactiveColor, end: widget.activeColor);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      if (widget.value)
        this._controller.forward(from: this._controller.value);
      else
        this._controller.reverse(from: this._controller.value);
    }
  }

  @override
  Widget build(context) {
    Widget icon = widget.value ? widget.activeIcon : widget.inactiveIcon;
    if (icon == null) icon = widget.activeIcon;
    String tooltip =
        widget.value ? widget.activeTooltip : widget.inactiveTooltip;
    if (tooltip == null) tooltip = widget.activeTooltip;

    return new IconButton(
      icon: icon,
      color: this._colorTween.evaluate(this._animation),
      tooltip: tooltip,
      onPressed: !widget.disabled
          ? () {
              if (!widget.value)
                this._controller.forward(from: this._controller.value);
              else
                this._controller.reverse(from: this._controller.value);

              widget.onChanged(!widget.value);
            }
          : null,
      iconSize: widget.iconSize,
    );
  }
}
