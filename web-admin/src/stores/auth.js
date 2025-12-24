import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authApi } from '@/api/auth'
import { userApi } from '@/api/user'

export const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem('token') || '')
  const user = ref(null)

  const isAuthenticated = computed(() => !!token.value)

  // 登录
  async function login(phone, password) {
    try {
      const res = await authApi.login({ phone, password })
      // request.js 拦截器已经处理了非 200 的情况并抛出错误
      // 所以这里能走到 res.code === 200 的逻辑，或者直接被 catch 捕获
      if (res.code === 200) {
        const { token: accessToken } = res.data
        token.value = accessToken
        localStorage.setItem('token', accessToken)
        await fetchUserInfo()
        return { success: true }
      }
      // 理论上拦截器会拦截非200，但为了保险起见保留此分支
      return { success: false, message: res.message || '登录失败' }
    } catch (error) {
      // 这里的 error.message 已经是拦截器处理过的友好提示
      return { success: false, message: error.message }
    }
  }

  // 注册
  async function register(data) {
    try {
      const res = await authApi.register(data)
      if (res.code === 200) {
        return { success: true }
      }
      return { success: false, message: res.message || '注册失败' }
    } catch (error) {
      return { success: false, message: error.message }
    }
  }

  // 获取用户信息
  async function fetchUserInfo() {
    try {
      const res = await userApi.getProfile()
      if (res.code === 200) {
        user.value = res.data
      }
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
    register,
    logout,
    fetchUserInfo
  }
})

