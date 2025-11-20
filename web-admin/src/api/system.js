import request from '@/utils/request'

export const systemApi = {
  // 获取系统配置列表
  getConfigs() {
    return request.get('/system/configs')
  },

  // 新增/更新配置
  saveConfig(data) {
    return request.post('/system/configs', data)
  },

  // 删除配置
  deleteConfig(key) {
    return request.delete(`/system/configs/${key}`)
  },

  // 导出备份
  exportBackup() {
    return request.post('/system/backup/export', {}, {
      responseType: 'blob'
    })
  },

  // 导入备份
  importBackup(file) {
    return request.post(`/system/backup/import?file=${file}`)
  },

  // 查看日志
  getLogs(lines = 200) {
    return request.get(`/system/logs/tail?lines=${lines}`)
  }
}
