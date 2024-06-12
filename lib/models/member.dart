class Member {
  Member({
    required this.adminid,
    required this.cid,
    required this.cname,
    required this.cimage,
    required this.cgoal,
    required this.members,
  });
  late String adminid;
  late String cid;
  late String cname;
  late String cimage;
  late String cgoal;
  late List<String> members;

  Member.fromJson(Map<String, dynamic> json) {
    adminid = json['adminid'].toString() ?? '';
    cid = json['cid'].toString() ?? '';
    cname = json['cname'].toString() ?? '';
    cimage = json['cimage'].toString() ?? '';
    cgoal = json['cgoal'].toString() ?? '';
    members = List<String>.from(json['members'] ?? []);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['adminid'] = adminid;
    data['cid'] = cid;
    data['cname'] = cname;
    data['cimage'] = cimage;
    data['cgoal'] = cgoal;
    data['members'] = members;
    return data;
  }
}
