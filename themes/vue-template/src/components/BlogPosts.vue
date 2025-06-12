<template>
  <div class="blog-posts">
    <h2>ブログ記事</h2>
    <div v-if="posts.length === 0" class="no-posts">
      記事がありません。
    </div>
    <article v-for="post in posts" :key="post.id" class="blog-post">
      <header class="post-header">
        <h3 class="post-title">
          <a :href="post.permalink">{{ post.title }}</a>
        </h3>
        <div class="post-meta">
          <time :datetime="post.created_on">{{ formatDate(post.created_on) }}</time>
          <span v-if="post.author" class="author">by {{ post.author }}</span>
          <span v-if="post.category" class="category">in {{ post.category }}</span>
        </div>
      </header>
      
      <div class="post-content">
        <div v-if="post.excerpt" class="post-excerpt">
          {{ post.excerpt }}
        </div>
        <div v-else-if="post.text" class="post-text">
          {{ truncateText(post.text, 200) }}
        </div>
      </div>
      
      <footer class="post-footer">
        <a :href="post.permalink" class="read-more">続きを読む</a>
        <div v-if="post.tags && post.tags.length > 0" class="tags">
          <span v-for="tag in post.tags" :key="tag" class="tag">#{{ tag }}</span>
        </div>
      </footer>
    </article>
  </div>
</template>

<script>
export default {
  name: 'BlogPosts',
  props: {
    posts: {
      type: Array,
      default: () => []
    }
  },
  methods: {
    formatDate(dateString) {
      if (!dateString) return ''
      const date = new Date(dateString)
      return date.toLocaleDateString('ja-JP', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      })
    },
    truncateText(text, length = 200) {
      if (!text) return ''
      if (text.length <= length) return text
      return text.substring(0, length) + '...'
    }
  }
}
</script>

<style scoped>
.blog-posts {
  margin: 20px 0;
}

.blog-posts h2 {
  color: #2c3e50;
  border-bottom: 2px solid #3498db;
  padding-bottom: 10px;
  margin-bottom: 30px;
}

.no-posts {
  text-align: center;
  color: #7f8c8d;
  font-style: italic;
  padding: 40px;
  background: #f8f9fa;
  border-radius: 8px;
}

.blog-post {
  background: white;
  border: 1px solid #e1e8ed;
  border-radius: 8px;
  padding: 25px;
  margin-bottom: 25px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  transition: box-shadow 0.3s ease;
}

.blog-post:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}

.post-header {
  margin-bottom: 15px;
}

.post-title {
  margin: 0 0 10px 0;
  font-size: 1.4em;
}

.post-title a {
  color: #2c3e50;
  text-decoration: none;
  transition: color 0.3s ease;
}

.post-title a:hover {
  color: #3498db;
}

.post-meta {
  color: #7f8c8d;
  font-size: 0.9em;
}

.post-meta time,
.post-meta .author,
.post-meta .category {
  margin-right: 15px;
}

.post-content {
  margin: 15px 0;
  line-height: 1.6;
}

.post-excerpt,
.post-text {
  color: #555;
}

.post-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 20px;
  padding-top: 15px;
  border-top: 1px solid #eee;
}

.read-more {
  color: #3498db;
  text-decoration: none;
  font-weight: 500;
  transition: color 0.3s ease;
}

.read-more:hover {
  color: #2980b9;
}

.tags {
  display: flex;
  gap: 8px;
}

.tag {
  background: #ecf0f1;
  color: #34495e;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 0.8em;
  font-weight: 500;
}
</style>