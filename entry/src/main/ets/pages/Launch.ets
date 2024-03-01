import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import common from '@ohos.app.ability.common';
import bundleManager from '@ohos.bundle.bundleManager';
import geoLocationManager from '@ohos.geoLocationManager';
import router from '@ohos.router';

@Entry
@Component
struct Launch {
  permissions: Array<Permissions> = ['ohos.permission.READ_CALENDAR', 'ohos.permission.INTERNET',
  'ohos.permission.READ_MEDIA', 'ohos.permission.MEDIA_LOCATION', 'ohos.permission.WRITE_MEDIA'];
  @State hasAccess: boolean = false;
  @State locationText: string = '';
  @State accessText: string = '设备获取粗略位置权限: 未授权';

  aboutToAppear() {
    this.checkPermissions(this.permissions);
  }


  build() {


  }

  async checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    let atManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus;

    // 获取应用程序的accessTokenID
    let tokenId: number;
    try {
      let bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (err) {
      console.error(`getBundleInfoForSelf failed, code is ${err.code}, message is ${err.message}`);
    }


    // 校验应用是否被授予权限
    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (err) {
      console.error(`checkAccessToken failed, code is ${err.code}, message is ${err.message}`);
    }


    return grantStatus;
  }

  async checkPermissions(permissions: Array<Permissions>): Promise<void> {
    permissions.forEach((it)=>{
      let grantStatus: abilityAccessCtrl.GrantStatus =  this.checkAccessToken(it);
    })
    let grantStatus: abilityAccessCtrl.GrantStatus = await this.checkAccessToken(permissions[0]);


    if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      // 已经授权，可以继续访问目标操作
      this.hasAccess = true;
      this.accessText = '设备获取粗略位置权限: 已授权';
    } else {
      // 申请权限
      this.hasAccess = false;
      this.accessText = '设备获取粗略位置权限: 未授权';
    }
  }


  reqPermissionsFromUser(permissions: Array<Permissions>): void {
    let context = getContext(this) as common.UIAbilityContext;
    let atManager = abilityAccessCtrl.createAtManager();
    // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
    atManager.requestPermissionsFromUser(context, permissions).then((data) => {
      this.hasAccess = true;
      this.accessText = '设备获取粗略位置权限: 已授权';
      let grantStatus: Array<number> = data.authResults;
      let length: number = grantStatus.length;
      for (let i = 0; i < length; i++) {
        if (grantStatus[i] === 0) {
          let requestInfo = {'priority': 0x203, 'scenario': 0x300, 'timeInterval': 0, 'distanceInterval': 0, 'maxAccuracy': 0};
          let locationChange = (location) => {
            console.log('locationChanger: data: ' + JSON.stringify(location));
          };
          try {
            geoLocationManager.on('locationChange', requestInfo, locationChange);
          } catch (err) {
            console.error("errCode:" + err.code + ",errMessage:" + err.message);
          }
          try {
            let location = geoLocationManager.getLastLocation();
            this.locationText = 'latitude:' + location.latitude + '\n'
            + 'longitude:' + location.longitude + '\n'
            + 'altitude:' + location.altitude + '\n'
            + 'accuracy:'  + location.accuracy + '\n'
            + 'speed:' + location.speed + '\n'
            + 'direction:' + location.direction;
          } catch (err) {
            console.error("errCode:" + err.code + ",errMessage:" + err.message);
          }
        } else {
          this.hasAccess = false;
          this.accessText = '设备获取粗略位置权限: 未授权';
          // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
          return;
        }
      }
      router.pushUrl({ url: 'pages/Index' })
    }).catch((err) => {
      console.error(`requestPermissionsFromUser failed, code is ${err.code}, message is ${err.message}`);
    })
  }


}