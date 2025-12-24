import request from '@/utils/request'

export const forumApi = {
  // 获取帖子列表
  getPosts(params) {
    return request({
      url: '/forum/posts',
      method: 'get',
      params
    })
  },

  // 获取帖子详情
  getPostDetail(postId) {
    return request({
      url: `/forum/posts/${postId}`,
      method: 'get'
    })
  },

  // 更新帖子状态 (管理员)
  updatePostStatus(postId, data) {
    return request({
      url: `/forum/posts/${postId}/status`,
      method: 'put',
      data
    })
  }
}
