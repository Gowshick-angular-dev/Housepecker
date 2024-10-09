// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Housepecker/utils/Extensions/lib/adaptive_type.dart';

class UserModel {
  String? address;
  String? createdAt;
  int? customertotalpost;
  String? email;
  String? fcmId;
  String? firebaseId;
  int? id;
  String? role;
  int? isActive;
  bool? isProfileCompleted;
  String? logintype;
  String? mobile;
  String? name;
  int? notification;
  String? profile;
  String? token;
  String? updatedAt;
  String? aboutMe;
  String? facebookId;
  String? twitterId;
  String? instagramId;
  String? pintrestId;
  String? companyName;
  String? rera;
  String? completedProject;
  String? currentProject;
  String? officeTiming;
  String? webLink;
  String? gstNo;
  String? experience;
  String? rentNumber;
  String? saleNumber;
  String? residentType;
  List? gallery;
  int? verified;

  UserModel(
      {this.address,
      this.createdAt,
      this.customertotalpost,
      this.email,
      this.fcmId,
      this.firebaseId,
      this.id,
      this.role,
      this.isActive,
      this.isProfileCompleted,
      this.logintype,
      this.mobile,
      this.name,
      this.notification,
      this.profile,
      this.token,
      this.aboutMe,
      this.facebookId,
      this.twitterId,
      this.instagramId,
      this.pintrestId,
      this.companyName,
      this.rera,
      this.completedProject,
      this.currentProject,
      this.officeTiming,
      this.webLink,
      this.gstNo,
      this.experience,
      this.rentNumber,
      this.saleNumber,
      this.residentType,
      this.verified,
      this.gallery,
      this.updatedAt
      });

  UserModel.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    createdAt = json['created_at'];
    customertotalpost = Adapter.forceInt(json['customertotalpost']);
    email = json['email'];
    fcmId = json['fcm_id'];
    firebaseId = json['firebase_id'];
    id = json['id'];
    isActive = Adapter.forceInt(json['isActive']);
    isProfileCompleted = json['isProfileCompleted'];
    logintype = json['logintype'];
    mobile = json['mobile'];
    name = json['name'];
    role = json['role_id'].toString();
    notification = (json['notification'] is int)
        ? json['notification']
        : int.parse((json['notification'] ?? '0'));
    profile = json['profile'];
    token = json['token'];
    aboutMe = json['about_me'];
    facebookId = json['facebook_id'];
    twitterId = json['twiiter_id'];
    instagramId = json['instagram_id'];
    pintrestId = json['pintrest_id'];
    companyName = json['company_name'];
    rera = json['rera'];
    completedProject = json['completed_project'];
    currentProject = json['current_project'];
    officeTiming = json['office_timing'];
    webLink = json['web_link'];
    gstNo = json['gst_no'];
    experience = json['experience'];
    rentNumber = json['rent_no'];
    saleNumber = json['sale_no'];
    residentType = json['resident_type'];
    verified = json['verified'];
    gallery = json['gallery'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['created_at'] = createdAt;
    data['customertotalpost'] = customertotalpost;
    data['email'] = email;
    data['fcm_id'] = fcmId;
    data['firebase_id'] = firebaseId;
    data['id'] = id;
    data['role_id'] = role;
    data['isActive'] = isActive;
    data['isProfileCompleted'] = isProfileCompleted;
    data['logintype'] = logintype;
    data['mobile'] = mobile;
    data['name'] = name;
    data['notification'] = notification;
    data['profile'] = profile;
    data['token'] = token;
    data['updated_at'] = updatedAt;
    data['about_me'] = aboutMe;
    data['facebook_id'] = facebookId;
    data['twiiter_id'] = twitterId;
    data['instagram_id'] = instagramId;
    data['pintrest_id'] = pintrestId;
    data['company_name'] = companyName;
    data['rera'] = rera;
    data['completed_project'] = completedProject;
    data['current_project'] = currentProject;
    data['office_timing'] = officeTiming;
    data['web_link'] = webLink;
    data['gst_no'] = gstNo;
    data['experience'] = experience;
    data['rent_no'] = rentNumber;
    data['sale_no'] = saleNumber;
    data['resident_type'] = residentType;
    data['verified'] = verified;
    data['gallary'] = gallery;
    return data;
  }

  @override
  String toString() {
    return 'UserModel(address: $address, createdAt: $createdAt, customertotalpost: $customertotalpost, email: $email, fcmId: $fcmId, firebaseId: $firebaseId, id: $id, role_id: $role, isActive: $isActive, isProfileCompleted: $isProfileCompleted, logintype: $logintype, mobile: $mobile, name: $name, notification: $notification, profile: $profile, residentType: $residentType, token: $token, updatedAt: $updatedAt)';
  }
}
