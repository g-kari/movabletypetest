<template>
  <div class="sv-deck-editor">
    <div class="sv-deck-builder-content">
      <!-- カード選択エリア -->
      <div class="sv-card-selector">
        <div class="sv-search-controls">
          <input 
            v-model="searchQuery" 
            type="text" 
            placeholder="カード名で検索..."
            class="sv-search-input"
          />
          <select v-model="selectedClass" class="sv-class-filter">
            <option value="">すべてのクラス</option>
            <option value="elf">エルフ</option>
            <option value="royal">ロイヤル</option>
            <option value="witch">ウィッチ</option>
            <option value="dragon">ドラゴン</option>
            <option value="necromancer">ネクロマンサー</option>
            <option value="vampire">ヴァンパイア</option>
            <option value="bishop">ビショップ</option>
            <option value="nemesis">ネメシス</option>
            <option value="neutral">ニュートラル</option>
          </select>
        </div>
        
        <div class="sv-card-grid">
          <div 
            v-for="card in filteredCards" 
            :key="card.card_id"
            class="sv-card-item"
            :class="getCardRarityClass(card.rarity)"
            @click="addCardToDeck(card)"
          >
            <div class="sv-card-cost">{{ card.cost }}</div>
            <div class="sv-card-info">
              <div class="sv-card-name">{{ card.name }}</div>
              <div class="sv-card-meta">
                {{ getTypeNameJp(card.type) }} | {{ getRarityNameJp(card.rarity) }}
              </div>
              <div v-if="card.attack !== null || card.life !== null" class="sv-card-stats">
                {{ card.attack || 0 }}/{{ card.life || 0 }}
              </div>
            </div>
            <div v-if="getCardCountInDeck(card.card_id) > 0" class="sv-card-count-badge">
              {{ getCardCountInDeck(card.card_id) }}
            </div>
          </div>
        </div>
      </div>

      <!-- デッキ構成エリア -->
      <div class="sv-deck-preview">
        <div class="sv-deck-header">
          <h3>デッキ構成</h3>
          <div class="sv-deck-count" :class="{ 'valid': totalCardCount === 40, 'invalid': totalCardCount !== 40 }">
            {{ totalCardCount }}/40枚
          </div>
        </div>

        <div class="sv-deck-cards">
          <div 
            v-for="cardInDeck in sortedDeckCards" 
            :key="cardInDeck.card.card_id"
            class="sv-deck-card-item"
            :class="getCardRarityClass(cardInDeck.card.rarity)"
          >
            <div class="sv-card-cost">{{ cardInDeck.card.cost }}</div>
            <div class="sv-card-info">
              <div class="sv-card-name">{{ cardInDeck.card.name }}</div>
              <div class="sv-card-meta">
                {{ getTypeNameJp(cardInDeck.card.type) }}
              </div>
            </div>
            <div class="sv-card-controls">
              <button @click="removeCardFromDeck(cardInDeck.card)" class="sv-btn-remove">-</button>
              <span class="sv-card-count">{{ cardInDeck.count }}</span>
              <button @click="addCardToDeck(cardInDeck.card)" class="sv-btn-add">+</button>
            </div>
          </div>
        </div>

        <!-- コスト分布チャート -->
        <div class="sv-cost-chart">
          <h4>コスト分布</h4>
          <div class="sv-cost-bars">
            <div 
              v-for="(count, cost) in costDistribution" 
              :key="cost"
              class="sv-cost-bar"
              :style="{ height: (count * 15) + 'px' }"
            >
              <div class="sv-cost-count">{{ count }}</div>
              <div class="sv-cost-label">{{ cost }}+</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DeckEditor',
  props: {
    initialDeck: {
      type: Object,
      default: null
    },
    allCards: {
      type: Array,
      default: () => []
    },
    savedCards: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      searchQuery: '',
      selectedClass: '',
      deckCards: []
    }
  },
  computed: {
    filteredCards() {
      let cards = this.allCards.filter(card => {
        // クラスフィルタ
        if (this.selectedClass && card.class !== this.selectedClass) {
          return false
        }
        
        // 検索クエリフィルタ
        if (this.searchQuery) {
          const query = this.searchQuery.toLowerCase()
          return card.name.toLowerCase().includes(query) ||
                 (card.name_en && card.name_en.toLowerCase().includes(query))
        }
        
        return true
      })
      
      // コスト順、名前順でソート
      return cards.sort((a, b) => {
        if (a.cost !== b.cost) return a.cost - b.cost
        return a.name.localeCompare(b.name)
      })
    },
    
    sortedDeckCards() {
      return this.deckCards
        .map(deckCard => ({
          card: this.allCards.find(c => c.card_id === deckCard.card_id),
          count: deckCard.count
        }))
        .filter(item => item.card && item.count > 0)
        .sort((a, b) => {
          if (a.card.cost !== b.card.cost) return a.card.cost - b.card.cost
          return a.card.name.localeCompare(b.card.name)
        })
    },
    
    totalCardCount() {
      return this.deckCards.reduce((total, card) => total + card.count, 0)
    },
    
    costDistribution() {
      const distribution = {}
      for (let i = 0; i <= 10; i++) {
        distribution[i === 10 ? '10+' : i] = 0
      }
      
      this.deckCards.forEach(deckCard => {
        const card = this.allCards.find(c => c.card_id === deckCard.card_id)
        if (card) {
          const cost = card.cost >= 10 ? '10+' : card.cost
          distribution[cost] += deckCard.count
        }
      })
      
      return distribution
    }
  },
  methods: {
    addCardToDeck(card) {
      const existingCard = this.deckCards.find(c => c.card_id === card.card_id)
      
      if (existingCard) {
        if (existingCard.count < 3) { // 最大3枚まで
          existingCard.count++
        }
      } else {
        this.deckCards.push({
          card_id: card.card_id,
          count: 1
        })
      }
      
      this.updateFormData()
    },
    
    removeCardFromDeck(card) {
      const existingCard = this.deckCards.find(c => c.card_id === card.card_id)
      
      if (existingCard) {
        existingCard.count--
        if (existingCard.count <= 0) {
          const index = this.deckCards.indexOf(existingCard)
          this.deckCards.splice(index, 1)
        }
      }
      
      this.updateFormData()
    },
    
    getCardCountInDeck(cardId) {
      const deckCard = this.deckCards.find(c => c.card_id === cardId)
      return deckCard ? deckCard.count : 0
    },
    
    getCardRarityClass(rarity) {
      return `sv-rarity-${rarity}`
    },
    
    getTypeNameJp(type) {
      const typeNames = {
        'follower': 'フォロワー',
        'spell': 'スペル',
        'amulet': 'アミュレット'
      }
      return typeNames[type] || type
    },
    
    getRarityNameJp(rarity) {
      const rarityNames = {
        'bronze': 'ブロンズ',
        'silver': 'シルバー',
        'gold': 'ゴールド',
        'legendary': 'レジェンド'
      }
      return rarityNames[rarity] || rarity
    },
    
    updateFormData() {
      // フォームの隠しフィールドを更新
      const cardsDataField = document.getElementById('cards_data')
      if (cardsDataField) {
        cardsDataField.value = JSON.stringify(this.deckCards)
      }
    }
  },
  
  mounted() {
    // 保存されたカードデータを読み込み
    if (this.savedCards && Array.isArray(this.savedCards)) {
      this.deckCards = [...this.savedCards]
    }
    
    // フォーム送信時にデータを更新
    const form = document.querySelector('form')
    if (form) {
      form.addEventListener('submit', () => {
        this.updateFormData()
      })
    }
  }
}
</script>

<style scoped>
.sv-deck-editor {
  width: 100%;
}

.sv-deck-builder-content {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  height: 600px;
}

.sv-card-selector, .sv-deck-preview {
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 15px;
  overflow-y: auto;
  background: white;
}

.sv-search-controls {
  display: grid;
  grid-template-columns: 1fr 200px;
  gap: 10px;
  margin-bottom: 15px;
}

.sv-search-input, .sv-class-filter {
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.sv-card-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 8px;
}

.sv-card-item, .sv-deck-card-item {
  display: flex;
  align-items: center;
  padding: 8px;
  border: 1px solid #eee;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s;
  position: relative;
}

.sv-card-item:hover {
  background: #f8f9fa;
  transform: translateX(2px);
}

.sv-deck-card-item {
  cursor: default;
}

.sv-card-cost {
  width: 30px;
  height: 30px;
  background: #007bff;
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  margin-right: 10px;
  font-size: 14px;
}

.sv-card-info {
  flex: 1;
}

.sv-card-name {
  font-weight: 500;
  margin-bottom: 2px;
}

.sv-card-meta {
  font-size: 12px;
  color: #666;
}

.sv-card-stats {
  font-size: 12px;
  color: #333;
  font-weight: bold;
}

.sv-card-count-badge {
  position: absolute;
  top: -5px;
  right: -5px;
  background: #dc3545;
  color: white;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: bold;
}

.sv-card-controls {
  display: flex;
  align-items: center;
  gap: 8px;
}

.sv-btn-remove, .sv-btn-add {
  width: 24px;
  height: 24px;
  border: none;
  border-radius: 50%;
  font-weight: bold;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.sv-btn-remove {
  background: #dc3545;
  color: white;
}

.sv-btn-add {
  background: #28a745;
  color: white;
}

.sv-card-count {
  min-width: 20px;
  text-align: center;
  font-weight: bold;
}

.sv-deck-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
  padding-bottom: 10px;
  border-bottom: 1px solid #ddd;
}

.sv-deck-count {
  font-weight: bold;
  padding: 4px 8px;
  border-radius: 4px;
}

.sv-deck-count.valid {
  background: #d4edda;
  color: #155724;
}

.sv-deck-count.invalid {
  background: #f8d7da;
  color: #721c24;
}

.sv-deck-cards {
  margin-bottom: 20px;
}

.sv-cost-chart h4 {
  margin-bottom: 10px;
}

.sv-cost-bars {
  display: flex;
  align-items: end;
  height: 100px;
  gap: 4px;
}

.sv-cost-bar {
  flex: 1;
  background: linear-gradient(180deg, #007bff, #0056b3);
  border-radius: 2px 2px 0 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: end;
  color: white;
  font-size: 10px;
  font-weight: bold;
  padding: 2px;
  min-height: 20px;
}

.sv-cost-count {
  margin-bottom: 2px;
}

.sv-cost-label {
  background: rgba(0,0,0,0.3);
  padding: 1px 3px;
  border-radius: 2px;
}

/* レアリティ別スタイル */
.sv-rarity-bronze {
  border-left: 4px solid #8d6e63;
}

.sv-rarity-silver {
  border-left: 4px solid #9e9e9e;
}

.sv-rarity-gold {
  border-left: 4px solid #ffc107;
}

.sv-rarity-legendary {
  border-left: 4px solid #ff9800;
  background: linear-gradient(90deg, #fff8e1, #ffffff);
}

@media (max-width: 768px) {
  .sv-deck-builder-content {
    grid-template-columns: 1fr;
    height: auto;
  }
  
  .sv-search-controls {
    grid-template-columns: 1fr;
  }
}
</style>