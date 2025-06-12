<template>
  <div class="mt-vue-app">
    <header class="mt-header">
      <h1>{{ title }}</h1>
      <p>{{ subtitle }}</p>
    </header>
    
    <main class="mt-main">
      <div class="welcome-message">
        <h2>MovableType + Vue.js Template</h2>
        <p>このテンプレートはVue.jsとMovableTypeを組み合わせた現代的なWebサイト開発を可能にします。</p>
        
        <div class="features">
          <h3>主な機能:</h3>
          <ul>
            <li>Vue.js 3の最新機能を活用</li>
            <li>MovableTypeのCMS機能との統合</li>
            <li>レスポンシブデザイン対応</li>
            <li>コンポーネントベースの開発</li>
          </ul>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
export default {
  name: 'App',
  data() {
    return {
      title: 'MovableType Vue Template',
      subtitle: 'Modern web development with Vue.js and MovableType'
    }
  }
}
</script>

<style>
.mt-vue-app {
  font-family: 'Helvetica Neue', Arial, sans-serif;
  line-height: 1.6;
  color: #333;
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.mt-header {
  text-align: center;
  margin-bottom: 40px;
  padding: 40px 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 8px;
}

.mt-header h1 {
  margin: 0 0 10px 0;
  font-size: 2.5em;
  font-weight: 300;
}

.mt-header p {
  margin: 0;
  font-size: 1.2em;
  opacity: 0.9;
}

.mt-main {
  padding: 20px 0;
}

.welcome-message {
  background: #f8f9fa;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.welcome-message h2 {
  color: #2c3e50;
  margin-top: 0;
}

.features {
  margin-top: 30px;
}

.features h3 {
  color: #34495e;
}

.features ul {
  list-style-type: none;
  padding: 0;
}

.features li {
  padding: 8px 0;
  padding-left: 20px;
  position: relative;
}

.features li:before {
  content: '✓';
  position: absolute;
  left: 0;
  color: #27ae60;
  font-weight: bold;
}
</style>