<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { apiService } from '@/services/api'

interface HealthResponse {
  status: string
  service?: string
}

interface HelloResponse {
  message: string
  status: string
}

const backendStatus = ref<string>('Checking...')
const backendMessage = ref<string>('')
const isConnected = ref<boolean>(false)
const loading = ref<boolean>(false)

const checkBackendHealth = async () => {
  loading.value = true
  try {
    const response = await apiService.checkHealth()
    if (response.data) {
      const healthData = response.data as HealthResponse
      backendStatus.value = healthData.status || 'UP'
      isConnected.value = true
    } else {
      backendStatus.value = 'DOWN'
      isConnected.value = false
    }
  } catch {
    backendStatus.value = 'Error'
    isConnected.value = false
  } finally {
    loading.value = false
  }
}

const getBackendMessage = async () => {
  loading.value = true
  try {
    const response = await apiService.sayHello()
    if (response.data) {
      const helloData = response.data as HelloResponse
      backendMessage.value = helloData.message || 'No message'
    } else {
      backendMessage.value = 'Failed to get message'
    }
  } catch {
    backendMessage.value = 'Error getting message'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  checkBackendHealth()
  getBackendMessage()
})
</script>

<template>
  <main class="home">
    <div class="container">
      <h1 class="title">Mobile Internet</h1>
      <p class="subtitle">Full-stack application with Vue.js, Spring Boot, and HarmonyOS</p>

      <div class="status-card">
        <h2>Backend Status</h2>
        <div class="status-indicator">
          <span
            class="status-dot"
            :class="{ connected: isConnected, disconnected: !isConnected }"
          ></span>
          <span class="status-text">{{ backendStatus }}</span>
        </div>
        <button @click="checkBackendHealth" :disabled="loading" class="btn">
          {{ loading ? 'Checking...' : 'Refresh Status' }}
        </button>
      </div>

      <div class="message-card" v-if="backendMessage">
        <h3>Message from Backend:</h3>
        <p class="message">{{ backendMessage }}</p>
      </div>

      <div class="features">
        <h2>Project Components</h2>
        <div class="feature-grid">
          <div class="feature-card">
            <div class="feature-icon">🌐</div>
            <h3>Web Frontend</h3>
            <p>Built with Vue.js 3, TypeScript, and Vite</p>
            <ul>
              <li>Vue Router for navigation</li>
              <li>Pinia for state management</li>
              <li>Modern development experience</li>
            </ul>
          </div>

          <div class="feature-card">
            <div class="feature-icon">⚙️</div>
            <h3>Backend API</h3>
            <p>Spring Boot REST API with Java 17</p>
            <ul>
              <li>RESTful endpoints</li>
              <li>Spring Data JPA</li>
              <li>H2 in-memory database</li>
            </ul>
          </div>

          <div class="feature-card">
            <div class="feature-icon">📱</div>
            <h3>HarmonyOS Client</h3>
            <p>Native HarmonyOS application</p>
            <ul>
              <li>Built with ArkTS</li>
              <li>Declarative UI with ArkUI</li>
              <li>Backend integration</li>
            </ul>
          </div>
        </div>
      </div>

      <div class="info-section">
        <h2>Getting Started</h2>
        <div class="steps">
          <div class="step">
            <span class="step-number">1</span>
            <div class="step-content">
              <h4>Start the Backend</h4>
              <code>cd backend && mvn spring-boot:run</code>
            </div>
          </div>
          <div class="step">
            <span class="step-number">2</span>
            <div class="step-content">
              <h4>Start the Frontend</h4>
              <code>cd web-frontend && npm run dev</code>
            </div>
          </div>
          <div class="step">
            <span class="step-number">3</span>
            <div class="step-content">
              <h4>Build HarmonyOS App</h4>
              <code>Open harmony-client in DevEco Studio</code>
            </div>
          </div>
        </div>
      </div>
    </div>
  </main>
</template>

<style scoped>
.home {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

.container {
  width: 100%;
}

.title {
  font-size: 3rem;
  font-weight: 700;
  color: #2c3e50;
  margin-bottom: 0.5rem;
  text-align: center;
}

.subtitle {
  font-size: 1.2rem;
  color: #666;
  text-align: center;
  margin-bottom: 3rem;
}

.status-card {
  background: white;
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  margin-bottom: 2rem;
  text-align: center;
}

.status-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 1.5rem 0;
  gap: 1rem;
}

.status-dot {
  width: 16px;
  height: 16px;
  border-radius: 50%;
  animation: pulse 2s infinite;
}

.status-dot.connected {
  background: #42b883;
}

.status-dot.disconnected {
  background: #e74c3c;
}

.status-text {
  font-size: 1.2rem;
  font-weight: 600;
}

@keyframes pulse {
  0%,
  100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

.btn {
  background: #42b883;
  color: white;
  border: none;
  padding: 0.75rem 2rem;
  border-radius: 8px;
  font-size: 1rem;
  cursor: pointer;
  transition: background 0.3s;
}

.btn:hover:not(:disabled) {
  background: #35a372;
}

.btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.message-card {
  background: #f8f9fa;
  border-left: 4px solid #42b883;
  padding: 1.5rem;
  border-radius: 8px;
  margin-bottom: 2rem;
}

.message {
  font-size: 1.1rem;
  color: #2c3e50;
  margin: 0.5rem 0 0;
}

.features {
  margin: 3rem 0;
}

.features h2 {
  text-align: center;
  margin-bottom: 2rem;
  color: #2c3e50;
}

.feature-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2rem;
  margin-bottom: 3rem;
}

.feature-card {
  background: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transition: transform 0.3s, box-shadow 0.3s;
}

.feature-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
}

.feature-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.feature-card h3 {
  color: #2c3e50;
  margin-bottom: 0.5rem;
}

.feature-card p {
  color: #666;
  margin-bottom: 1rem;
}

.feature-card ul {
  list-style: none;
  padding: 0;
}

.feature-card li {
  color: #555;
  padding: 0.3rem 0;
  padding-left: 1.5rem;
  position: relative;
}

.feature-card li::before {
  content: '✓';
  position: absolute;
  left: 0;
  color: #42b883;
  font-weight: bold;
}

.info-section {
  background: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.info-section h2 {
  color: #2c3e50;
  margin-bottom: 1.5rem;
  text-align: center;
}

.steps {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.step {
  display: flex;
  gap: 1rem;
  align-items: flex-start;
}

.step-number {
  background: #42b883;
  color: white;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  flex-shrink: 0;
}

.step-content {
  flex: 1;
}

.step-content h4 {
  margin: 0 0 0.5rem;
  color: #2c3e50;
}

.step-content code {
  display: block;
  background: #f5f5f5;
  padding: 0.75rem 1rem;
  border-radius: 6px;
  font-family: 'Courier New', monospace;
  color: #2c3e50;
  overflow-x: auto;
}

@media (max-width: 768px) {
  .title {
    font-size: 2rem;
  }

  .subtitle {
    font-size: 1rem;
  }

  .feature-grid {
    grid-template-columns: 1fr;
  }
}
</style>
