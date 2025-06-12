import { createApp } from 'vue'
import App from './App.vue'
import BlogPosts from './components/BlogPosts.vue'
import Navigation from './components/Navigation.vue'

// MovableType Vue Template システム
class MTVueTemplate {
  constructor() {
    this.apps = {}
  }

  // 特定の要素にVueアプリをマウント
  mount(selector, component, props = {}) {
    const element = document.querySelector(selector)
    if (element) {
      const app = createApp(component, props)
      app.mount(element)
      this.apps[selector] = app
      return app
    }
    return null
  }

  // ブログ投稿一覧コンポーネントのマウント
  mountBlogPosts(selector, posts = []) {
    return this.mount(selector, BlogPosts, { posts })
  }

  // ナビゲーションコンポーネントのマウント
  mountNavigation(selector, menuItems = []) {
    return this.mount(selector, Navigation, { menuItems })
  }

  // メインアプリのマウント
  mountMainApp(selector) {
    return this.mount(selector, App)
  }
}

// グローバルに公開
window.MTVueTemplate = new MTVueTemplate()

// DOM読み込み完了時の自動初期化
document.addEventListener('DOMContentLoaded', () => {
  // デフォルトのVueアプリをマウント
  const vueAppElement = document.querySelector('#vue-app')
  if (vueAppElement) {
    window.MTVueTemplate.mountMainApp('#vue-app')
  }

  // ブログ投稿一覧の自動マウント
  const blogPostsElement = document.querySelector('#vue-blog-posts')
  if (blogPostsElement) {
    // MovableTypeから渡されたデータを取得
    const postsData = blogPostsElement.dataset.posts ? JSON.parse(blogPostsElement.dataset.posts) : []
    window.MTVueTemplate.mountBlogPosts('#vue-blog-posts', postsData)
  }

  // ナビゲーションの自動マウント
  const navigationElement = document.querySelector('#vue-navigation')
  if (navigationElement) {
    const menuData = navigationElement.dataset.menu ? JSON.parse(navigationElement.dataset.menu) : []
    window.MTVueTemplate.mountNavigation('#vue-navigation', menuData)
  }
})