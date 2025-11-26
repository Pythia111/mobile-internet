// 路由常量定义
export const Routes = {
  // 认证相关页面
  LOGIN: 'pages/auth/Login',
  REGISTER: 'pages/auth/Register',
  
  // 主页面
  INDEX: 'pages/Index',
  
  // 用户相关页面
  PROFILE: 'pages/user/Profile',
  EDIT_PROFILE: 'pages/user/EditProfile',
  
  // 饮食相关页面
  DIET_HOME: 'pages/diet/DietHome',
  FOOD_SEARCH: 'pages/diet/FoodSearch',
  FOOD_RECOGNITION: 'pages/diet/FoodRecognition',
  ADD_RECORD: 'pages/diet/AddRecord',
  DIET_HISTORY: 'pages/diet/DietHistory',
  
  // 论坛相关页面
  FORUM_HOME: 'pages/forum/ForumHome',
  POST_DETAIL: 'pages/forum/PostDetail',
  CREATE_POST: 'pages/forum/CreatePost',
  USER_PROFILE: 'pages/forum/UserProfile'
};

// 路由管理类
export class RouterManager {
  // 跳转到登录页面
  static goToLogin() {
    router.replaceUrl({
      url: Routes.LOGIN
    });
  }
  
  // 跳转到注册页面
  static goToRegister() {
    router.pushUrl({
      url: Routes.REGISTER
    });
  }
  
  // 跳转到主页面
  static goToIndex() {
    router.replaceUrl({
      url: Routes.INDEX
    });
  }
  
  // 返回上一页
  static goBack() {
    router.back();
  }
  
  // 跳转到指定页面
  static navigateTo(url: string, params?: object) {
    router.pushUrl({
      url: url,
      params: params
    });
  }
  
  // 替换当前页面
  static replaceTo(url: string, params?: object) {
    router.replaceUrl({
      url: url,
      params: params
    });
  }
}
