import http from '@ohos.net.http'

var name = ''
var password = ''
var tenantCode = ''


@Entry
@Component
struct Login {
  build() {
    Row() {
      Column() {
        Text('用户登陆').fontSize(30)
        TextInput({ placeholder: '账号' }).width('30%').type(InputType.Normal).onChange((value) => {
          name = value
        })
        TextInput({ placeholder: '密码' }).width('30%').type(InputType.Password).onChange((value) => {
          password = value
        })
        TextInput({ placeholder: '租户编码' }).width('30%').type(InputType.Normal).onChange((value) => {
          tenantCode = value
        })
        Row() {
          Toggle({ type: ToggleType.Checkbox, isOn: true })
          Text('记住用户名密码')
        }

        Button('登陆').onClick(() => {
          this.login()
          //console.log(`用户名${name}密码${password}租户编码${tenantCode}`)
        })
      }
    }
    .justifyContent(FlexAlign.End)
    .backgroundImage($r('app.media.ic_pad_login_bg_79'), ImageRepeat.NoRepeat)
    .width('100%')
    .height('100%')
  }

  login() {
    let content = {
      "force": true,
      "Issuer": "PAD",
      "password": "BTsQq/Ff5Y7iNccYtNZ7RW6xfIfpFLh62PBEtA0n888=",
      "tenantCode": "www",
      "userName": "hs"
    }
    // 每一个httpRequest对应一个HTTP请求任务，不可复用
    let httpRequest = http.createHttp();
    // 用于订阅HTTP响应头，此接口会比request请求先返回。可以根据业务需要订阅此消息
    // 从API 8开始，使用on('headersReceive', Callback)替代on('headerReceive', AsyncCallback)。 8+
    httpRequest.on('headersReceive', (header) => {
      console.info('header: ' + JSON.stringify(header));
    });
    httpRequest.request(
      // 填写HTTP请求的URL地址，可以带参数也可以不带参数。URL地址需要开发者自定义。请求的参数可以在extraData中指定
      "http://192.168.8.129:63000/api/Authorize/Login",
      {
        method: http.RequestMethod.POST, // 可选，默认为http.RequestMethod.GET
        // 开发者根据自身业务需要添加header字段
        header: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        // 当使用POST请求时此字段用于传递内容
        extraData: {
          "force": true,
          "Issuer": "PAD",
          "password": "BTsQq/Ff5Y7iNccYtNZ7RW6xfIfpFLh62PBEtA0n888=",
          "tenantCode": "www",
          "userName": "hs"
        },
        expectDataType: http.HttpDataType.STRING, // 可选，指定返回数据的类型
        usingCache: true, // 可选，默认为true
        priority: 1, // 可选，默认为1
        connectTimeout: 60000, // 可选，默认为60000ms
        readTimeout: 60000, // 可选，默认为60000ms
        usingProtocol: http.HttpProtocol.HTTP1_1, // 可选，协议类型默认值由系统自动指定
      }, (err, data) => {
      if (!err) {
        // data.result为HTTP响应内容，可根据业务需要进行解析
        console.info('Result:' + JSON.stringify(data.result));
        console.info('code:' + JSON.stringify(data.responseCode));
        // data.header为HTTP响应头，可根据业务需要进行解析
        console.info('header:' + JSON.stringify(data.header));
        console.info('cookies:' + JSON.stringify(data.cookies)); // 8+
      } else {
        console.info('error:' + JSON.stringify(err));
        // 取消订阅HTTP响应头事件
        httpRequest.off('headersReceive');
        // 当该请求使用完毕时，调用destroy方法主动销毁
        httpRequest.destroy();
      }
    }
    );
  }
}