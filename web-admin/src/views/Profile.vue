<template>
  <div class="profile-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>个人资料编辑</span>
        </div>
      </template>

      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="100px"
        style="max-width: 500px"
      >
        <el-form-item label="手机号">
          <el-input v-model="user.phone" disabled />
        </el-form-item>

        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" placeholder="请输入用户名" />
        </el-form-item>

        <el-form-item label="头像URL" prop="avatar">
          <el-input v-model="form.avatar" placeholder="请输入头像URL" />
        </el-form-item>

        <el-form-item label="新密码" prop="password">
          <el-input
            v-model="form.password"
            type="password"
            placeholder="不修改请留空（≥6位，含字母+数字）"
            show-password
          />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" :loading="loading" @click="handleUpdate">保存修改</el-button>
          <el-button @click="resetForm">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, computed, watch, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useAuthStore } from '@/stores/auth'
import { userApi } from '@/api/user'

const authStore = useAuthStore()
const user = computed(() => authStore.user || {})
const loading = ref(false)
const formRef = ref()

const form = reactive({
  username: '',
  avatar: '',
  password: ''
})

const validatePassword = (rule, value, callback) => {
  if (value === '') {
    callback()
  } else if (value.length < 6) {
    callback(new Error('密码长度不能少于6位'))
  } else if (!/[a-zA-Z]/.test(value) || !/[0-9]/.test(value)) {
    callback(new Error('密码必须包含字母和数字'))
  } else {
    callback()
  }
}

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  password: [
    { validator: validatePassword, trigger: 'blur' }
  ]
}

// 初始化表单
const initForm = () => {
  if (user.value) {
    form.username = user.value.username || ''
    form.avatar = user.value.avatar || ''
    form.password = ''
  }
}

watch(user, initForm, { immediate: true })

onMounted(() => {
  authStore.fetchUserInfo()
})

const resetForm = () => {
  initForm()
}

const handleUpdate = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (!valid) return

    loading.value = true
    try {
      const data = {
        username: form.username,
        avatar: form.avatar
      }
      if (form.password) {
        data.password = form.password
      }

      const res = await userApi.updateProfile(data)
      if (res.code === 200) {
        ElMessage.success('修改成功')
        await authStore.fetchUserInfo()
        form.password = '' // 清空密码框
      } else {
        ElMessage.error(res.message || '修改失败')
      }
    } catch (error) {
      ElMessage.error(error.message || '修改失败')
    } finally {
      loading.value = false
    }
  })
}
</script>

<style scoped>
.profile-container {
  padding: 20px;
}
</style>
