<template>
  <nav class="navigation">
    <div class="nav-container">
      <div class="nav-brand">
        <a href="/" class="brand-link">{{ brandName }}</a>
      </div>
      
      <button 
        class="nav-toggle" 
        :class="{ active: isMenuOpen }"
        @click="toggleMenu"
        aria-label="メニューを開く"
      >
        <span></span>
        <span></span>
        <span></span>
      </button>
      
      <ul class="nav-menu" :class="{ active: isMenuOpen }">
        <li v-for="item in menuItems" :key="item.id" class="nav-item">
          <a 
            :href="item.url" 
            class="nav-link"
            :class="{ active: item.current }"
            @click="closeMenu"
          >
            {{ item.label }}
          </a>
        </li>
      </ul>
    </div>
  </nav>
</template>

<script>
export default {
  name: 'Navigation',
  props: {
    menuItems: {
      type: Array,
      default: () => [
        { id: 1, label: 'ホーム', url: '/', current: true },
        { id: 2, label: 'ブログ', url: '/blog/', current: false },
        { id: 3, label: 'について', url: '/about/', current: false },
        { id: 4, label: 'お問い合わせ', url: '/contact/', current: false }
      ]
    },
    brandName: {
      type: String,
      default: 'My Site'
    }
  },
  data() {
    return {
      isMenuOpen: false
    }
  },
  methods: {
    toggleMenu() {
      this.isMenuOpen = !this.isMenuOpen
    },
    closeMenu() {
      this.isMenuOpen = false
    }
  },
  mounted() {
    // ウィンドウリサイズ時にメニューを閉じる
    window.addEventListener('resize', () => {
      if (window.innerWidth > 768) {
        this.isMenuOpen = false
      }
    })
  }
}
</script>

<style scoped>
.navigation {
  background: #fff;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  position: sticky;
  top: 0;
  z-index: 1000;
}

.nav-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  min-height: 60px;
}

.nav-brand {
  font-size: 1.5em;
  font-weight: bold;
}

.brand-link {
  color: #2c3e50;
  text-decoration: none;
  transition: color 0.3s ease;
}

.brand-link:hover {
  color: #3498db;
}

.nav-toggle {
  display: none;
  flex-direction: column;
  cursor: pointer;
  background: none;
  border: none;
  padding: 10px;
  position: relative;
  z-index: 1001;
}

.nav-toggle span {
  width: 25px;
  height: 3px;
  background: #2c3e50;
  margin: 3px 0;
  transition: 0.3s;
  display: block;
}

.nav-toggle.active span:nth-child(1) {
  transform: rotate(-45deg) translate(-5px, 6px);
}

.nav-toggle.active span:nth-child(2) {
  opacity: 0;
}

.nav-toggle.active span:nth-child(3) {
  transform: rotate(45deg) translate(-5px, -6px);
}

.nav-menu {
  display: flex;
  list-style: none;
  margin: 0;
  padding: 0;
  gap: 30px;
}

.nav-item {
  position: relative;
}

.nav-link {
  color: #555;
  text-decoration: none;
  font-weight: 500;
  padding: 10px 0;
  transition: color 0.3s ease;
  position: relative;
}

.nav-link:hover,
.nav-link.active {
  color: #3498db;
}

.nav-link.active:after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  right: 0;
  height: 2px;
  background: #3498db;
}

/* レスポンシブデザイン */
@media (max-width: 768px) {
  .nav-toggle {
    display: flex;
  }
  
  .nav-menu {
    position: fixed;
    top: 60px;
    left: -100%;
    width: 100%;
    height: calc(100vh - 60px);
    background: white;
    flex-direction: column;
    justify-content: flex-start;
    align-items: center;
    padding-top: 50px;
    gap: 20px;
    transition: left 0.3s ease;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  }
  
  .nav-menu.active {
    left: 0;
  }
  
  .nav-link {
    font-size: 1.2em;
    padding: 15px 20px;
  }
}
</style>