import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authApi } from '@/api/auth'

export const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem('token') || '')
  const user = ref(null)

  const isAuthenticated = computed(() => !!token.value)

  // 登录
  async function login(phone, code) {
    try {
      const res = await authApi.loginSms({ phone, code })
      token.value = res.token
      localStorage.setItem('token', res.token)
      await fetchUserInfo()
      return { success: true }
    } catch (error) {
      return { success: false, message: error.message || '登录失败' }
    }
  }

  // 获取用户信息
  async function fetchUserInfo() {
    try {
      const res = await authApi.getMe()
      user.value = res
    } catch (error) {
      console.error('获取用户信息失败:', error)
    }
  }

  // 登出
  function logout() {
    token.value = ''
    user.value = null
    localStorage.removeItem('token')
  }

  // 初始化时获取用户信息
  if (token.value) {
    fetchUserInfo()
  }

  return {
    token,
    user,
    isAuthenticated,
    login,
    logout,
    fetchUserInfo
  }
})
