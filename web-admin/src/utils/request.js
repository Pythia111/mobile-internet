import axios from 'axios'
import { ElMessage } from 'element-plus'
import router from '@/router'

const request = axios.create({
  baseURL: '/api',
  timeout: 10000
})

// 请求拦截器
request.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// 响应拦截器
request.interceptors.response.use(
  response => {
    const res = response.data
    // 如果后端返回的 code 不是 200，则判断为业务错误
    if (res.code && res.code !== 200) {
      // 优先显示后端返回的 message，如果没有则显示默认提示
      const errorMessage = res.message || '操作失败'
      ElMessage.error(errorMessage)
      
      // 特殊状态码处理
      if (res.code === 401) {
        localStorage.removeItem('token')
        router.push('/login')
      }
      
      // 返回 Promise.reject 以便在组件中捕获错误
      return Promise.reject(new Error(errorMessage))
    }
    return res
  },
  error => {
    const { response } = error
    let message = '系统繁忙，请稍后重试'

    if (response) {
      // HTTP 状态码错误处理
      switch (response.status) {
        case 401:
          message = '登录已过期，请重新登录'
          localStorage.removeItem('token')
          router.push('/login')
          break
        case 403:
          message = '您没有权限执行此操作'
          break
        case 404:
          message = '请求的资源不存在'
          break
        case 400:
          // 尝试获取后端返回的具体错误信息
          message = response.data?.message || '请求参数有误'
          break
        case 500:
          message = '服务器内部错误'
          break
        default:
          message = response.data?.message || `请求失败 (${response.status})`
      }
    } else if (error.message.includes('timeout')) {
      message = '请求超时，请检查网络'
    } else if (error.message.includes('Network Error')) {
      message = '网络连接失败，请检查网络'
    }

    ElMessage.error(message)
    return Promise.reject(new Error(message))
  }
)

export default request
