import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import common from '@ohos.app.ability.common';
import bundleManager from '@ohos.bundle.bundleManager';
import router from '@ohos.router';

@Entry
@Component
struct Launch {
  permissions: Array<Permissions> = ['ohos.permission.READ_CALENDAR', 'ohos.permission.INTERNET',
    'ohos.permission.READ_MEDIA', 'ohos.permission.MEDIA_LOCATION', 'ohos.permission.WRITE_MEDIA'];
  @State locationText: string = '';

  aboutToAppear(){

  }

  onPageShow(){
    this.checkPermissions(this.permissions);
  }

  build() {

  }

  async checkPermissions(permissions: Array<Permissions>): Promise<void> {
    var successPermissionArray: Array<Permissions> = []
    var needPermissionArray: Array<Permissions> = []
    for (let it of permissions) {
      let grantStatus: abilityAccessCtrl.GrantStatus = await this.checkAccessToken(it);
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        successPermissionArray.push(it)
      } else {
        needPermissionArray.push(it)
      }
    }

    if (needPermissionArray.length != 0) {
      this.reqPermissionsFromUser(needPermissionArray)
    } else {
      this.routeSuccess()
    }
  }

  async checkAccessToken(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    let atManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus;

    let tokenId: number;
    try {
      let bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (err) {
      console.error(`getBundleInfoForSelf failed, code is ${err.code}, message is ${err.message}`);
    }

    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (err) {
      console.error(`checkAccessToken failed, code is ${err.code}, message is ${err.message}`);
    }

    return grantStatus;
  }

  /**
   * 向用户申请权限
   * @param permissions
   */
  reqPermissionsFromUser(permissions: Array<Permissions>): void {
    let context = getContext(this) as common.UIAbilityContext;
    let atManager = abilityAccessCtrl.createAtManager();
    // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
    atManager.requestPermissionsFromUser(context, permissions).then((data) => {
      let grantStatus: Array<number> = data.authResults;
      let length: number = grantStatus.length;
      for (let i = 0; i < length; i++) {
        if (grantStatus[i] === 0) {
          // 用户授权，可以继续访问目标操作
        } else {
          // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
          this.openPermissionsInSystemSettings();
        }
      }
      // 授权成功
    }).catch((err) => {
      console.error(`requestPermissionsFromUser failed, code is ${err.code}, message is ${err.message}`);
    })
    this.checkPermissions(this.permissions);
  }

  /**
   * 打开系统权限页面
   */
  openPermissionsInSystemSettings(): void {
    let context = getContext(this) as common.UIAbilityContext;
    let wantInfo = {
      action: 'action.settings.app.info',
      parameters: {
        settingsParamBundleName: 'com.example.testapplication' // 打开指定应用的详情页面
      }
    }
    context.startAbility(wantInfo).then(() => {

    }).catch((err) => {
      // ...
    })
  }

  /**
   * 路由跳转
   */
  routeSuccess(): void {
    router.pushUrl({ url: 'pages/Login' })
  }
}