import request from '@/utils/request'

export const authApi = {
  // 发送验证码
  sendCode(data) {
    return request.post('/auth/send-code', data)
  },

  // 短信登录
  loginSms(data) {
    return request.post('/auth/login-sms', data)
  },

  // 获取当前用户信息
  getMe() {
    return request.get('/auth/me')
  }
}
