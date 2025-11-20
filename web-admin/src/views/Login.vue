<template>
  <div class="login-container">
    <el-card class="login-card">
      <template #header>
        <div class="card-header">
          <h2>营养管理后台</h2>
          <p>管理员登录</p>
        </div>
      </template>

      <el-form ref="formRef" :model="form" :rules="rules" label-width="0">
        <el-form-item prop="phone">
          <el-input
            v-model="form.phone"
            placeholder="请输入手机号"
            size="large"
            :prefix-icon="Phone"
          />
        </el-form-item>

        <el-form-item prop="code">
          <el-input
            v-model="form.code"
            placeholder="请输入验证码"
            size="large"
            :prefix-icon="Lock"
          >
            <template #append>
              <el-button :disabled="countdown > 0" @click="handleSendCode">
                {{ countdown > 0 ? `${countdown}秒后重试` : "获取验证码" }}
              </el-button>
            </template>
          </el-input>
        </el-form-item>

        <el-form-item>
          <el-button
            type="primary"
            size="large"
            :loading="loading"
            style="width: 100%"
            @click="handleLogin"
          >
            登录
          </el-button>
        </el-form-item>
      </el-form>

      <div class="tips">
        <el-alert
          title="提示：开发环境下验证码为 123456"
          type="info"
          :closable="false"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive } from "vue";
import { useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { Phone, Lock } from "@element-plus/icons-vue";
import { useAuthStore } from "@/stores/auth";
import { authApi } from "@/api/auth";

const router = useRouter();
const authStore = useAuthStore();

const formRef = ref();
const loading = ref(false);
const countdown = ref(0);

const form = reactive({
  phone: "",
  code: "",
});

const rules = {
  phone: [
    { required: true, message: "请输入手机号", trigger: "blur" },
    {
      pattern: /^1[3-9]\d{9}$/,
      message: "请输入正确的手机号",
      trigger: "blur",
    },
  ],
  code: [
    { required: true, message: "请输入验证码", trigger: "blur" },
    { min: 6, max: 6, message: "验证码为6位数字", trigger: "blur" },
  ],
};

// 发送验证码
const handleSendCode = async () => {
  if (!form.phone) {
    ElMessage.warning("请先输入手机号");
    return;
  }

  if (!/^1[3-9]\d{9}$/.test(form.phone)) {
    ElMessage.warning("请输入正确的手机号");
    return;
  }

  try {
    await authApi.sendCode({ phone: form.phone });
    ElMessage.success("验证码已发送，开发环境请使用 123456");

    // 倒计时
    countdown.value = 60;
    const timer = setInterval(() => {
      countdown.value--;
      if (countdown.value <= 0) {
        clearInterval(timer);
      }
    }, 1000);
  } catch (error) {
    console.error("发送验证码失败:", error);
  }
};

// 登录
const handleLogin = async () => {
  if (!formRef.value) return;

  await formRef.value.validate(async (valid) => {
    if (!valid) return;

    loading.value = true;
    try {
      const result = await authStore.login(form.phone, form.code);

      if (result.success) {
        ElMessage.success("登录成功");
        router.push("/");
      } else {
        ElMessage.error(result.message);
      }
    } finally {
      loading.value = false;
    }
  });
};
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.login-card {
  width: 450px;
  border-radius: 10px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.card-header {
  text-align: center;
}

.card-header h2 {
  margin: 0 0 8px 0;
  color: #303133;
  font-size: 24px;
}

.card-header p {
  margin: 0;
  color: #909399;
  font-size: 14px;
}

.tips {
  margin-top: 20px;
}

:deep(.el-input-group__append) {
  padding: 0;
}

:deep(.el-input-group__append .el-button) {
  margin: 0;
  border: none;
  border-radius: 0;
}
</style>
