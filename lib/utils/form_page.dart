import 'package:flutter/material.dart';
import 'package:oph_core/models/oph.dart';
import 'package:oph_core/oph_core.dart';
import 'package:oph_core/models/preset.dart';
import 'package:intl/intl.dart';
import 'package:oph_elements/utils/form_detail.dart';
import 'package:oph_core/utils/form_service.dart';
//import 'package:oph_core/models/preset.dart';
//import '../models/browse.dart';

class FormPage extends StatefulWidget {
  FormPage(
      {Key key,
      this.title,
      @required this.code,
      @required this.caption,
      @required this.frmList,
      @required this.msgKey,
      @required this.fn,
      this.refreshNumber,
      @required this.preset,
      this.parentguid,
      this.bottomWidget})
      : super(key: key);

  final String title;
  final String code;
  final String caption;
  final BrowseHead frmList;
  final Function fn;
  final int refreshNumber;
  final GlobalKey<ScaffoldMessengerState> msgKey;
  final Preset preset;
  final Widget bottomWidget;
  final String parentguid;
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  _FormPageState();
  //final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final formatter = new NumberFormat("#,##0");
  //FormService frm = new FormService();
  //Frm curForm = Frm(code: '', guid: '00000000-0000-0000-0000-000000000000');

  @override
  void initState() {
    //curForm.code = widget.code;
    super.initState();
  }

  Future<void> goFormDetail(
      {@required String title, //@required String guid
      FormService frm}) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return FormDetail(
          alias: widget.code,
          title: title,
          frm: frm,
          ratio: 1,
          parentguid: widget.parentguid,
          preset: widget.preset);
    }));
    await _refresh();
    setState(() {});
  }

  Future<bool> delItem(String guid) async {
    //curForm = await frm.init(widget.code, guid, curForm, () {
    //  setState(() {});
    //}, () {
    //_showSnackBar(frm.error());
    //});
    bool b = false;
    FormService frm = await BrowseList.getList(
            Oph.curPreset.accountId, widget.code, Oph.curPreset.dataList)
        .getForm(guid, reload: false);

    //await frm.loadForm();
    b = await frm.function(action: 'delete');
    await _refresh();

    if (!b) _showSnackBar(frm.error());
    return b;
  }

  _showSnackBar(String message, {int duration = 3}) {
    final snackBar = new SnackBar(
        duration: Duration(seconds: duration), content: new Text(message));
    widget.msgKey.currentState.showSnackBar(snackBar);
  }

  PreferredSizeWidget appBarWidget() {
    return PreferredSize(
        preferredSize: Size.fromHeight(36.0),
        child: AppBar(
            elevation: 0,
            backgroundColor: Oph.curPreset.color2,
            title: Text('Manage ' + widget.title,
                style: TextStyle(fontSize: 16))));
  }

  Widget bodyWidget() {
    List<MapEntry<String, BrowseRow>> items =
        widget.frmList.rows.entries.toList();
    return items.length == 0
        ? Center(child: Text('No Data Available.'))
        : ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemBuilder: (context, i) {
              String itemName = items[i].value.fields[widget.caption].val ?? '';
              return InkWell(
                child: ListTile(
                    title: Text(itemName,
                        maxLines: 2,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: TextButton(
                      //color: preset.color3,
                      style: TextButton.styleFrom(
                        backgroundColor: Oph.curPreset.color3,
                      ),

                      child: Text('Delete',
                          style: TextStyle(color: Oph.curPreset.color4)),
                      onPressed: () async {
                        bool r = await delItem(items[i].key);
                        if (r)
                          setState(() async {
                            widget.fn(i: widget.refreshNumber);
                          });
                        //else
                        //_showSnackBar(frm.error());
                      },
                    )),
                onTap: () {
                  String itemName =
                      items[i].value.fields[widget.caption].val ?? '';
                  goFormDetail(title: itemName, frm: items[i].value.frmSvc);
                },
              );
            },
            itemCount: items.length);
  }

  Widget addItem() {
    return FloatingActionButton(
      backgroundColor: Oph.curPreset.color1,
      child: Icon(
        Icons.add,
      ),
      onPressed: () async {
        FormService frm = BrowseList.getList(
                Oph.curPreset.accountId, widget.code, Oph.curPreset.dataList)
            .getHead()
            .newSvc;
        await frm.newForm();
        goFormDetail(title: 'New ' + widget.title, frm: frm);
      },
    );
  }

  Future<void> _refresh({bool isForce: false}) async {
    await widget.fn(i: widget.refreshNumber);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarWidget(),
        body: RefreshIndicator(onRefresh: _refresh, child: bodyWidget()),
        floatingActionButton: addItem(),
        bottomSheet: widget.bottomWidget);
  }
}
