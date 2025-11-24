<template>
  <router-view />
</template>

<script setup>
</script>

<style>
:root {
  --primary-color: #5e7ce2;
  --primary-light: #8fa4f1;
  --bg-color: #f4f7fc;
  --surface-color: #ffffff;
  --text-main: #2c3e50;
  --text-secondary: #606266;
  --sidebar-bg: #2b3649;
  --sidebar-text: #bfcbd9;
  --sidebar-active: #5e7ce2;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  background-color: var(--bg-color);
  color: var(--text-main);
}

#app {
  height: 100vh;
}

/* Element Plus 样式覆盖 */
.el-button--primary {
  --el-button-bg-color: var(--primary-color);
  --el-button-border-color: var(--primary-color);
  --el-button-hover-bg-color: var(--primary-light);
  --el-button-hover-border-color: var(--primary-light);
}

.el-input__wrapper.is-focus {
  box-shadow: 0 0 0 1px var(--primary-color) inset !important;
}
</style>
