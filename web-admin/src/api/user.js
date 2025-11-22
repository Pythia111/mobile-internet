import request from '@/utils/request'

export const userApi = {
  // 获取个人信息
  getProfile() {
    return request.get('/user/profile')
  },

  // 个人资料修改
  updateProfile(data) {
    return request.put('/user/profile', data)
  }
}

