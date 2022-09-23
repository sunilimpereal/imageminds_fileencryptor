import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class DropImage extends StatefulWidget {
  const DropImage({Key? key}) : super(key: key);

  @override
  _DropImageState createState() => _DropImageState();
}

class _DropImageState extends State<DropImage> {
  bool _dragging = false;
  final List<File> _list = [];
  bool loading = false;

  Offset? offset;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: DropTarget(
        onDragDone: (detail) {
          setState(() {
            _list.addAll(detail.urls
                .map((e) => File(detail.urls.lastWhere((element) => true).toFilePath()))
                .toList());
          });
        },
        onDragUpdated: (details) {
          setState(() {
            offset = details.localPosition;
          });
        },
        onDragEntered: (detail) {
          setState(() {
            _dragging = true;
          });
        },
        onDragExited: (detail) {
          setState(() {
            _dragging = false;
            offset = null;
          });
        },
        child: Center(
          child: Container(
            padding: EdgeInsets.all(0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _dragging ? Colors.grey.withOpacity(0) : Colors.transparent.withOpacity(0.0),
            ),
            child: Column(
              children: [
                Center(
                  child: gridDisplay(),
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(),
                  onPressed: () async {
                    convertToString(_list);
                    // if (_list.isEmpty) {
                    //   return;
                    // }
                    // setState(() {
                    //   loading = true;
                    // });
                    // File e = _list[0];
                    // var crypt = AesCrypt();
                    // crypt.setPassword('password');
                    // final directory = await getApplicationDocumentsDirectory();
                    // await Directory('${directory.path}\\encryptedFiles').create(recursive: true);

                    // log('${directory.path}\\encryptedFiles\\${e.toString().substring((e.toString().lastIndexOf('\\') + 1), (e.toString().lastIndexOf('.')))}.mp4');
                    // String filePath =
                    //     '${directory.path}\\encryptedFiles\\${e.toString().substring((e.toString().lastIndexOf('\\') + 1), (e.toString().lastIndexOf('.')))}.mp4'
                    //         .replaceAll(" ", "_");

                    // crypt.encryptFileSync(e.path, filePath);

                    // log("done");
                    // setState(() {
                    //   _list.clear();
                    //   loading = false;
                    // });
                  },
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: loading ? Text("Loading..") : Text("Encrypt File"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  convertToString(List<File> fileList) async {
    setState(() {
      loading = true;
    });
    File e = _list[0];
    final directory = await getApplicationDocumentsDirectory();
    log('${directory.path}\\encryptedFiles\\${e.toString().substring((e.toString().lastIndexOf('\\') + 1), (e.toString().lastIndexOf('.')))}.mp4');
    String filePath =
        '${directory.path}\\encryptedFiles\\${e.toString().substring((e.toString().lastIndexOf('\\') + 1), (e.toString().lastIndexOf('.')))}.mp4'
            .replaceAll(" ", "_");
    final File file = File(filePath);
    var bytes = await e.readAsBytes();
    await file.writeAsString(bytes.toString());

    setState(() {
      _list.clear();
      loading = false;
    });
  }

  Widget gridDisplay() {
    List<Widget> listWidget = _list.map((e) => imageTile(e)).toList();
    listWidget.add(isemptydrop());
    double height = 400 * (((_list.length / 3).ceilToDouble()) + ((_list.length % 3) == 0 ? 1 : 0));
    return Container(
        height: 300,
        width: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _list.isEmpty ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        ),

        //height: height == 0 ? 150 : height,
        child: _list.isEmpty ? Container() : Center(child: imageTile(_list[0])));
  }

  Widget isemptydrop() {
    return Container(
      child: Center(
        child: Container(
          height: 110,
          width: 120,
          child: GestureDetector(
            onTap: () {
              //selectLogo();
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(5)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 40,
                    width: 50,
                    decoration: BoxDecoration(
                        image: DecorationImage(image: AssetImage("assets/images/vedioicon.png"))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Drag Images or click to upload',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline5!.copyWith(
                              color: Colors.grey,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            )),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

//  void selectLogo() async {
//    final file = OpenFilePicker()
//      ..filterSpecification = {
//        'Images (*.jpeg, *.png, *.svg, *.gif)': '*jpeg;*.png;*svg;*gif',
//        'All Files': '*.*'
//      }
//      ..defaultFilterIndex = 0
//      ..defaultExtension = 'jpeg'
//      ..title = 'Select Prodcut image';
//    final result = file.getFile();
//
//    if (result != null) {
//      setState(() {
//        _list.add(result);
//      });
//
//      print(result.path);
//    }
//  }

  Widget imageTile(File e) {
    Future<Uint8List?> getImage() async {
      return await VideoThumbnail.thumbnailData(
        video: e.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth:
            128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
        quality: 25,
      );
    }

    return GestureDetector(
      onTap: () async {},
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(children: [
          Container(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder<Uint8List?>(
                    future: getImage(),
                    builder: (context, snapshot) {
                      final uint8list = snapshot.data;
                      log(uint8list.toString());
                      return Container(
                        height: 50,
                        width: 80,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/images/vedioicon.png"), fit: BoxFit.cover),
                        ),
                        // child: Image.memory(uint8list),
                      );
                    }),
                Container(
                  width: 110,
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    e
                        .toString()
                        .substring((e.toString().lastIndexOf('\\') + 1), e.toString().length - 1),
                    maxLines: 2,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 5,
            child: Container(
              width: 20,
              child: MaterialButton(
                padding: EdgeInsets.all(0),
                onPressed: () {
                  setState(() {
                    _list.remove(e);
                  });
                },
                elevation: 0,
                color: Colors.red,
                textColor: Colors.red,
                child: Icon(
                  Icons.close,
                  size: 15,
                  color: Colors.white,
                ),
                shape: CircleBorder(),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
