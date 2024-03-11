@Entry
@Component
struct Setting {
  build() {
    Column() {
      Row({ space: 10 }) {
        Column() {
          Text('ip地址')
          TextInput()
        }.layoutWeight(1)
        .alignItems(HorizontalAlign.Start)


        Column() {
          Text('Host端口')
          TextInput()
        }.layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column() {
          Button('保存')
        }.layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .margin(10)

      Row() {
        Button('高级设置')
          .layoutWeight(1)

        Button('保存并退出')
          .layoutWeight(1)
      }

      Row() {
        Button('测试')
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin(10)
    }
  }
}