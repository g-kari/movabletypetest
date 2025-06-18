# Shadowverse Deck Builder Plugin for MovableType

A comprehensive deck building system for Shadowverse card game, built with Vue.js and MovableType CMS.

## 🎯 Features

### ✅ For End Users (Public Features)
- **Public Deck Builder**: Create and build decks without logging in
- **Deck Sharing**: View and share public decks with unique URLs
- **Rich OGP Support**: Social media cards for Twitter, Facebook sharing
- **Mobile Responsive**: Works on all devices
- **Interactive UI**: Vue.js-powered real-time deck building experience

### ✅ For Registered Users
- **Save Decks**: Persistent deck storage with user authentication
- **Deck Management**: Edit, delete, and organize personal decks
- **Public/Private**: Choose deck visibility settings
- **Share URLs**: Generate shareable links for public decks
- **View Statistics**: Track deck popularity and views

### ✅ For Administrators
- **Card Management**: Add and manage Shadowverse cards
- **User Deck Limits**: Configure maximum decks per user
- **Plugin Settings**: Enable/disable public access
- **Database Management**: Full CRUD operations

## 🏗️ Technical Stack

- **Backend**: Perl/MovableType plugin system
- **Frontend**: Vue.js 3 with modern components
- **Database**: MySQL with normalized schema
- **Styling**: Modern CSS with responsive design
- **Assets**: Built with Vite for production optimization

## 📦 Installation

### 1. Plugin Installation
```bash
# Copy plugin files to MovableType
cp -r mt/plugins/ShadowverseDeckBuilder /path/to/movabletype/plugins/

# Copy theme files  
cp -r themes/vue-template /path/to/movabletype/themes/
```

### 2. MovableType Configuration
1. Login to MovableType admin panel
2. Go to "System" → "Plugins"
3. Enable "Shadowverse Deck Builder" plugin
4. Run database upgrade when prompted

### 3. Database Setup
```bash
# Import sample card data
mysql -u mt_user -p mt_database < mt/plugins/ShadowverseDeckBuilder/sample_cards.sql
```

### 4. Vue.js Assets Build
```bash
cd themes/vue-template
npm install
npm run build
```

### 5. Configure Plugin Settings
1. Go to "System" → "Plugin Settings" → "Shadowverse Deck Builder"
2. Enable public access if desired
3. Set maximum decks per user limit
4. Save configuration

## 🎮 Usage

### For End Users

#### Creating Decks
1. Visit `/deck-builder` on your MovableType site
2. Use the interactive deck editor to build your deck
3. Select cards from the comprehensive card database
4. See real-time deck statistics and cost distribution
5. Export deck list or save if logged in

#### Viewing Public Decks
1. Visit `/deck-collection` to browse public decks
2. Click on any deck to view detailed breakdown
3. Share decks on social media with rich OGP previews
4. Copy deck URLs for easy sharing

### For Registered Users

#### Managing Your Decks
1. Login to MovableType
2. Go to "Tools" → "Shadowverse Deck Builder"
3. Create, edit, or delete your personal decks
4. Toggle public/private visibility
5. View deck statistics and share URLs

#### Deck Editor Features
- **Card Search**: Find cards by name, class, or type
- **Real-time Validation**: Automatic 40-card deck validation
- **Cost Distribution**: Visual chart of mana curve
- **Drag & Drop**: Intuitive card selection interface
- **Auto-save**: Persistent deck state during editing

### For Administrators

#### Card Management
1. Go to "Tools" → "Shadowverse Deck Builder" → "Card Management"
2. Add new cards with complete metadata
3. Edit existing card information
4. Import bulk card data via SQL

#### Plugin Configuration
- **Public Access**: Allow anonymous deck creation
- **User Limits**: Set maximum decks per user
- **Features**: Enable/disable specific functionality

## 🔧 Template Tags

### Display Public Decks
```html
<mt:SVDeckList public_only="1" limit="10">
    <h3><mt:var name="svdeck_title"></h3>
    <p>Class: <mt:var name="svdeck_class_jp"></p>
    <p>Author: <mt:var name="svdeck_author_name"></p>
    <a href="<mt:var name="svdeck_share_url">">View Deck</a>
</mt:SVDeckList>
```

### Show Deck Details
```html
<mt:SVDeckDetail token="SHARE_TOKEN">
    <h1><mt:var name="svdeck_title"></h1>
    <p><mt:var name="svdeck_description"></p>
    <p>Cards: <mt:var name="svdeck_card_count"></p>
    <p>Views: <mt:var name="svdeck_view_count"></p>
</mt:SVDeckDetail>
```

### Embed Deck Builder
```html
<mt:SVDeckBuilder public_access="1" />
```

### List Cards
```html
<mt:SVCardList class="elf" limit="20">
    <div class="card">
        <h4><mt:var name="svcard_name"></h4>
        <p>Cost: <mt:var name="svcard_cost"></p>
        <p>Type: <mt:var name="svcard_type_jp"></p>
    </div>
</mt:SVCardList>
```

## 🎨 Customization

### Vue.js Components
Edit components in `themes/vue-template/src/components/`:
- `DeckEditor.vue`: Main deck building interface
- `BlogPosts.vue`: Blog integration
- `Navigation.vue`: Site navigation

After editing, rebuild assets:
```bash
cd themes/vue-template
npm run build
```

### Styling
Customize CSS in component `<style>` sections or add global styles to the theme.

### Card Data
Add new cards via admin interface or bulk import:
```sql
INSERT INTO mt_svcard (card_id, name, cost, type, class, rarity, description) 
VALUES ('NEW_001', 'New Card', 3, 'follower', 'elf', 'silver', 'Description');
```

## 🌐 API Endpoints

### Public Routes
- `/deck/{token}` - View public deck by share token
- `/deck-builder` - Public deck creation interface
- `/deck-collection` - Browse public decks
- `/api/cards` - JSON API for card data

### Admin Routes
- `mt.cgi?__mode=sv_deck_list` - User deck management
- `mt.cgi?__mode=sv_deck_edit` - Deck editor
- `mt.cgi?__mode=sv_card_list` - Card management

## 🔒 Security Features

- **User Authentication**: Deck ownership validation
- **CSRF Protection**: Form token validation
- **Input Sanitization**: XSS prevention
- **Rate Limiting**: Configurable user limits
- **Public/Private**: Granular visibility controls

## 📱 Mobile Support

- Responsive design for all screen sizes
- Touch-friendly interface
- Optimized card selection for mobile
- Swipe gestures and touch interactions

## 🔧 Troubleshooting

### Common Issues

#### Vue.js Components Not Loading
1. Check if Vue.js assets are built: `npm run build`
2. Verify theme path in MovableType
3. Check browser console for JavaScript errors

#### Cards Not Displaying
1. Ensure sample data is imported
2. Check database connection
3. Verify plugin is enabled and upgraded

#### Deck Saving Fails
1. Check user authentication
2. Verify database permissions
3. Check plugin configuration settings

#### Share URLs Not Working
1. Ensure public access is enabled
2. Check share token generation
3. Verify route configuration

### Performance Optimization

#### Database
- Card and deck tables are indexed for fast queries
- JSON card data for flexible deck storage
- View count caching

#### Frontend
- Vue.js components are built for production
- CSS is minified and optimized
- Images and assets are compressed

## 📈 Analytics & Monitoring

### Deck Statistics
- View counts per deck
- User engagement metrics
- Popular card usage
- Class distribution

### User Metrics
- Deck creation rates
- Public vs private deck ratios
- User retention

## 🤝 Contributing

### Adding New Features
1. Extend Perl modules in `lib/ShadowverseDeckBuilder/`
2. Add Vue.js components in `themes/vue-template/src/`
3. Update database schema if needed
4. Add template tags for MovableType integration

### Card Data
Contributions of new card data are welcome! Follow the existing schema in `sample_cards.sql`.

## 📄 License

MIT License - Free for commercial and personal use.

## 🎉 Credits

Built with ❤️ for the Shadowverse community using MovableType CMS and Vue.js.

---

For support and updates, visit the [project repository](https://github.com/g-kari/movabletypetest).