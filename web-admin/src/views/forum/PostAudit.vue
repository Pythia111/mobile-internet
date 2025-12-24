<template>
  <div class="post-audit-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>帖子审核管理</span>
          <el-button type="primary" @click="fetchPosts">刷新列表</el-button>
        </div>
      </template>

      <el-tabs v-model="activeTab" @tab-change="handleTabChange">
        <el-tab-pane label="待审核" name="1"></el-tab-pane>
        <el-tab-pane label="已发布" name="0"></el-tab-pane>
        <el-tab-pane label="违规/私密" name="2"></el-tab-pane>
        <el-tab-pane label="已删除" name="3"></el-tab-pane>
      </el-tabs>

      <el-table :data="postList" v-loading="loading" style="width: 100%">
        <el-table-column prop="title" label="标题" width="200" show-overflow-tooltip />
        <el-table-column prop="username" label="作者" width="100" />
        <el-table-column prop="createTime" label="发布时间" width="160">
           <template #default="scope">
             {{ formatDate(scope.row.createTime) }}
           </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="90">
          <template #default="scope">
            <el-tag :type="getStatusType(scope.row.status)">
              {{ getStatusText(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="240" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="handleView(scope.row)">查看详情</el-button>
            <el-button 
              v-if="scope.row.status === 1" 
              size="small" 
              type="success" 
              @click="handleAudit(scope.row, 'approve')"
            >通过</el-button>
            <el-button 
              v-if="scope.row.status === 1 || scope.row.status === 0" 
              size="small" 
              type="danger" 
              @click="handleAudit(scope.row, 'reject')"
            >违规</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          :current-page="currentPage"
          :page-size="pageSize"
          :total="total"
          layout="total, prev, pager, next"
          @update:current-page="val => currentPage = val"
          @update:page-size="val => pageSize = val"
          @current-change="handlePageChange"
        />
      </div>
    </el-card>

    <!-- 详情/审核弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      title="帖子详情"
      width="600px"
    >
      <div v-if="currentPost" class="post-detail">
        <h3>{{ currentPost.title }}</h3>
        <div class="post-meta">
          <el-avatar :size="24" :src="currentPost.avatar" />
          <span class="author">{{ currentPost.username }}</span>
          <span class="time">{{ formatDate(currentPost.createTime) }}</span>
        </div>
        <div class="post-content">{{ currentPost.content }}</div>
        <div class="post-images" v-if="currentPost.images && currentPost.images.length">
          <el-image 
            v-for="(img, index) in currentPost.images" 
            :key="index" 
            :src="getImageUrl(img)" 
            :preview-src-list="currentPost.images.map(getImageUrl)"
            fit="cover"
            class="post-image"
          />
        </div>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">关闭</el-button>
          <template v-if="currentPost && currentPost.status === 1">
            <el-button type="danger" @click="handleAudit(currentPost, 'reject')">驳回/违规</el-button>
            <el-button type="success" @click="handleAudit(currentPost, 'approve')">通过审核</el-button>
          </template>
           <template v-if="currentPost && currentPost.status === 0">
            <el-button type="danger" @click="handleAudit(currentPost, 'reject')">设为违规</el-button>
          </template>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { forumApi } from '@/api/forum'

const loading = ref(false)
const activeTab = ref('1') // 默认显示待审核
const postList = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

const dialogVisible = ref(false)
const currentPost = ref(null)

// 处理图片URL
const getImageUrl = (url) => {
  if (!url) return ''
  if (url.startsWith('http') || url.startsWith('blob:')) return url
  if (url.startsWith('/')) return url
  if (url.startsWith('uploads/')) return '/' + url
  return '/uploads/' + url
}

// 获取帖子列表
const fetchPosts = async () => {
  loading.value = true
  try {
    const params = {
      page: currentPage.value,
      status: parseInt(activeTab.value)
    }
    const res = await forumApi.getPosts(params)
    if (res.code === 200) {
      postList.value = res.data.posts || []
      // 假设后端返回了total，如果没有则需要后端支持分页元数据
      // 这里暂时假设后端只返回了list，如果需要分页总数，后端接口可能需要调整
      // 暂时模拟 total
      total.value = res.data.total || postList.value.length 
    }
  } catch (error) {
    console.error('获取帖子列表失败', error)
    ElMessage.error('获取帖子列表失败')
  } finally {
    loading.value = false
  }
}

// 切换Tab
const handleTabChange = () => {
  currentPage.value = 1
  fetchPosts()
}

// 翻页
const handlePageChange = (val) => {
  currentPage.value = val
  fetchPosts()
}

// 查看详情
const handleView = async (row) => {
  try {
    const res = await forumApi.getPostDetail(row.postId)
    if (res.code === 200) {
      currentPost.value = res.data
      dialogVisible.value = true
    }
  } catch (error) {
    ElMessage.error('获取详情失败')
  }
}

// 审核/更新状态
const handleAudit = (row, action) => {
  const actionText = action === 'approve' ? '通过' : '设为违规'
  
  ElMessageBox.prompt(`确认将该帖子${actionText}吗？请输入原因（可选）`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    inputPlaceholder: '请输入操作原因'
  }).then(async ({ value }) => {
    try {
      const data = {
        action: action,
        reason: value || ''
      }
      const res = await forumApi.updatePostStatus(row.postId, data)
      if (res.code === 200) {
        ElMessage.success('操作成功')
        dialogVisible.value = false
        fetchPosts()
      } else {
        ElMessage.error(res.message || '操作失败')
      }
    } catch (error) {
      console.error('操作失败', error)
      const msg = error.response?.data?.message || error.message || '操作失败'
      ElMessage.error(msg)
    }
  }).catch(() => {})
}

// 工具函数
const formatDate = (dateStr) => {
  if (!dateStr) return ''
  return new Date(dateStr).toLocaleString()
}

const getStatusType = (status) => {
  const map = {
    0: 'success',
    1: 'warning',
    2: 'danger',
    3: 'info'
  }
  return map[status] || 'info'
}

const getStatusText = (status) => {
  const map = {
    0: '已发布',
    1: '待审核',
    2: '违规/私密',
    3: '已删除'
  }
  return map[status] || '未知'
}

onMounted(() => {
  fetchPosts()
})
</script>

<style scoped>
.post-audit-container {
  padding: 8px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 4px 0;
  min-height: 32px;
}

.card-header span {
  font-size: 15px;
  font-weight: 500;
}

.pagination-container {
  margin-top: 12px;
  display: flex;
  justify-content: flex-end;
}

.post-detail {
  padding: 10px;
}

.post-meta {
  display: flex;
  align-items: center;
  margin: 10px 0;
  color: #909399;
  font-size: 13px;
}

.post-meta .author {
  margin: 0 10px;
  color: #303133;
  font-weight: 500;
}

.post-content {
  line-height: 1.6;
  margin-bottom: 20px;
  white-space: pre-wrap;
}

.post-images {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
}

.post-image {
  width: 100%;
  height: 100px;
  border-radius: 4px;
}
</style>
