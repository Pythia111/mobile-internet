在鸿蒙应用中设置图标未显示的问题，通常涉及以下几个关键检查点，请按照以下步骤排查：

一、图标资源类型确认

图标字体(iconFont)使用场景：
若采用图标字体方案，需在font.json中正确注册字体文件（参考以下配置）：
{
  "font": [
    {
      "name": "iconfont",
      "src": "/common/fonts/iconfont.ttf"
    }
  ]
}
在Text组件中使用时应采用\uXXXX格式的Unicode码，并指定fontFamily属性：
Text('\ue001') // 假设\ue001是图标对应编码
  .fontFamily('iconfont')
  .fontSize(24)
  .fontColor(Color.Blue)
图片资源使用场景：
若使用系统预置图标资源，需通过$r('app.media.ic_public_like')方式引用
图片资源应存放在resources/base/media/目录下，并确认文件名拼写准确性
二、布局与样式排查

可见性检查：

确保父容器（如Flex/Stack）未设置clip属性导致内容裁剪
检查visibility属性是否为Visibility.Visible
确认opacity值未设置为0导致完全透明
尺寸与间距设置：

至少设置一个维度尺寸（如.width(24).height(24)）
父容器需提供足够的布局空间，可通过设置背景色辅助调试
三、常见问题排查

字体兼容性问题：

确认ttf文件包含目标图标且编码正确（可用字体查看工具验证）
检查鸿蒙API版本是否支持当前字体特性（如API12+支持更多文本特性）
资源加载问题：

查看DevEco Studio控制台是否有字体加载失败警告
对图片资源尝试添加错误回调：
Image($r('app.media.ic_public_like'))
  .onError(() => {
    console.error('图片加载失败');
  })
四、调试建议

基础测试：

在Text组件中临时添加普通文本，确认组件基础渲染功能正常
尝试单独渲染图标组件，排除其他布局干扰
日志分析：

添加位置标记日志，确认代码执行路径：
Text('\ue001')
  .onAppear(() => {
    console.info('图标组件已渲染');
  })
若以上步骤仍未解决问题，建议提供以下信息以便进一步分析：

图标资源类型（字体/图片）
相关代码片段（包含资源声明与组件使用）
DevEco Studio控制台错误日志
预览器/真机运行效果对比