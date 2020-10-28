import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:toutiao_news/news_channel.dart';
import 'package:toutiao_news/news_json_resp.dart';
import 'package:toutiao_news/news_list.dart';

List<ChannelList> _channelList;
NewsData _newsData;
String defaultUrl="http://v.juhe.cn/toutiao/index?";
String key="key=a9499a6327919e760eedc75b8ef8433e";
String type="type=";
String url;
ChannelList currentChannel;
/**
 * 头条新闻
 */
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    _channelList=new List();
    _channelList.add(new ChannelList("top", "头条"));
    _channelList.add(new ChannelList("shehui", "社会"));
    _channelList.add(new ChannelList("guonei", "国内"));
    _channelList.add(new ChannelList("guoji", "国际"));
    _channelList.add(new ChannelList("yule", "娱乐"));
    _channelList.add(new ChannelList("tiyu", "体育"));
    _channelList.add(new ChannelList("junshi", "军事"));
    _channelList.add(new ChannelList("keji", "科技"));
    _channelList.add(new ChannelList("caijing", "财经"));
    _channelList.add(new ChannelList("shishang", "时尚"));
    currentChannel=_channelList[0];
    return MaterialApp(
      title: '头条新闻',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: NewList(title: '头条新闻'),
    );
  }
}
class NewList extends StatefulWidget{
  NewList({Key key,this.title}): super(key:key);
  final String title;
  @override
  _NewListState createState() => _NewListState();


}

class _NewListState extends State<NewList> with SingleTickerProviderStateMixin{
  bool isLoading= false;
  List<Widget>  listItems;
  //构建v耳边栏头部
  Widget buildDrawerHeader(){
    return Container(
      child: Text(
        "频道列表",
        style: TextStyle(color: Colors.white,fontSize: 30),
        textAlign: TextAlign.end,
      ),
      height: 100,
      color: Colors.blue,
      padding: EdgeInsets.all(5),
      alignment: Alignment.bottomRight,
    );
  }
  //构建侧边栏元素
  List<Widget> buildDrawerItems(List<ChannelList> _channelList){
    List<Widget> widgets=new List();
    widgets.add(buildDrawerHeader());
    for(int i=0;i<_channelList.length;i++){
      widgets.add(
        Container(
          child: InkWell(
            child: Text(_channelList[i].name,
              style: TextStyle(color: Colors.blue,fontSize: 25),
              textAlign: TextAlign.center,
            ),
           onTap: (){
              currentChannel=_channelList[i];
              refresh();
           },
          ),
          padding: EdgeInsets.all(10),

        )
      );
    }
    return widgets;
  }
  //刷新数据
  refresh() async{
    url="$defaultUrl$type${currentChannel.type}&$key";
    debugPrint("url:$url");
    if(!isLoading){
      isLoading = true;
      try{
        HttpClient httpClient=new HttpClient();
        HttpClientRequest request=await httpClient.getUrl(Uri.parse(url));
        HttpClientResponse response=await request.close();
        String responseContent=await response.transform(utf8.decoder).join();
        _newsData=NewsData.fromJson(json.decode(responseContent));
        listItems=ListBuilder.genWidgesFromJson(_newsData);
        int listItemsSize=listItems.length;
        debugPrint("listItemsSize:$listItemsSize");
        setState(() {});
        httpClient.close();
      } catch (e){
        debugPrint("请求失败：$e");
      }finally {
        setState(() {
          isLoading = false;
        });
      }
    }else{
      debugPrint("正在刷新");
    }
  }
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: buildDrawerItems(_channelList),
          ),
        ),
        body: Center(
          child: listItems !=null ? ListView(children: listItems,): Text("请点击刷新按钮"),
        ),
        floatingActionButton:FloatingActionButton(
          onPressed: refresh,
          tooltip: "刷新",
          child: Icon(Icons.refresh),
        ),
      );
  }

}