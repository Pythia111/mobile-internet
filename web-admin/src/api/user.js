import request from '@/utils/request'

export const userApi = {
  // 获取我的资料
  getProfile() {
    return request.get('/users/me')
  },

  // 更新我的资料
  updateProfile(data) {
    return request.put('/users/me', data)
  },

  // 修改密码
  changePassword(data) {
    return request.post('/users/change-password', data)
  },

  // 获取所有用户列表（这个接口需要后端实现，暂时模拟）
  getUserList(params) {
    // 实际应该调用后端接口，这里先返回示例数据
    return Promise.resolve({
      data: [],
      total: 0
    })
  }
}
