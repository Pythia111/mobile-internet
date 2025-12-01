

修改内容总结：

后端 (Java Spring Boot):

在 PostRepository 中添加了 findByUserIdOrderByCreatedAtDesc 方法，用于查询指定用户的帖子。
在 ForumService 中添加了 getMyPosts 业务逻辑。
在 ForumController 中新增了 /api/forum/my-posts 接口，用于获取当前登录用户的帖子列表。
前端 (HarmonyOS ArkTS):

API 层 (ForumApi.ets): 新增了 getMyPosts() 方法对接后端新接口。
发布页面 (CreatePost.ets): 修改了发布成功的逻辑，现在会显示“发布成功，待审核”提示，并在停留 2500ms 后自动返回上一页。
个人主页 (Profile.ets):
实现了真实数据的加载：自动获取用户信息和“我的帖子”列表。
新增了帖子网格展示：显示帖子封面图和标题。
状态同步：对于 status === 1 (待审核) 的帖子，会在封面图左上角显示橙色的“待审核”标签。