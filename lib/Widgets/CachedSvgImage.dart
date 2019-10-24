import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'dart:developer';

class CachedSvgImage extends StatefulWidget {
  final Color color;
  final String url;
  const CachedSvgImage({
    Key key,
    this.color,
    this.url,
  }) : super(key: key);

  @override
  _CachedSvgImageState createState() => _CachedSvgImageState();
}

class _CachedSvgImageState extends State<CachedSvgImage> {
  bool busy = false;
  File svgImageFile;
  bool disposed = false;

  @override
  void initState() {
    super.initState();
    _getSvgImage();
  }

  @override
  Widget build(BuildContext context) {
    return svgImageFile == null
        ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(widget.color),
          )
        : SvgPicture.file(
            svgImageFile,
            color: widget.color,
            fit: BoxFit.contain,
          );
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  Future _getSvgImage() async {
    try {
      log('widget ' + (widget == null ? 'is null' : (widget.url == null ? 'url = null' : 'url = ' + widget.url)));
      var imageFile = await DefaultCacheManager().getSingleFile(widget.url);
      log('   imageFile ' + (imageFile == null ? 'is null' : 'found'));

      if (!disposed) {
        setState(() {
          svgImageFile = imageFile;
        });
      }
    } catch (e) {
      print(
          'CachedSvgImage: Error occured fetching image for ${widget.url}.\n$e');
    }
  }
}
