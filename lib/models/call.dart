class Call {
  String? callerId;
  String? token;
  String? callerName;
  String? callerPic;
  String? receiverId;
  String? receiverName;
  String? receiverPic;
  String? channelId;
  int? timeepoch;
  bool? hasDialled;
  bool? isvideocall;

  Call({
    this.callerId,
    this.callerName,
    this.token,
    this.callerPic,
    this.receiverId,
    this.receiverName,
    this.receiverPic,
    this.timeepoch,
    this.channelId,
    this.hasDialled,
    this.isvideocall,
  });

  // to map
  Map<String, dynamic> toMap(Call call) {
    Map<String, dynamic> callMap = {};
    callMap["token"] = call.token;
    callMap["caller_id"] = call.callerId;
    callMap["caller_name"] = call.callerName;
    callMap["caller_pic"] = call.callerPic;
    callMap["receiver_id"] = call.receiverId;
    callMap["receiver_name"] = call.receiverName;
    callMap["receiver_pic"] = call.receiverPic;
    callMap["channel_id"] = call.channelId;
    callMap["has_dialled"] = call.hasDialled;
    callMap["isvideocall"] = call.isvideocall;
    callMap["timeepoch"] = call.timeepoch;
    return callMap;
  }

  Call.fromMap(Map callMap) {
    token = callMap["token"];
    callerId = callMap["caller_id"];
    callerName = callMap["caller_name"];
    callerPic = callMap["caller_pic"];
    receiverId = callMap["receiver_id"];
    receiverName = callMap["receiver_name"];
    receiverPic = callMap["receiver_pic"];
    channelId = callMap["channel_id"];
    hasDialled = callMap["has_dialled"];
    isvideocall = callMap["isvideocall"];
    timeepoch = callMap["timeepoch"];
  }
}
