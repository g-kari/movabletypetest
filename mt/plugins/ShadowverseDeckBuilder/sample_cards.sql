-- Sample card data for Shadowverse Deck Builder
-- Insert sample cards for testing and demonstration

INSERT INTO mt_svcard (card_id, name, name_en, cost, attack, life, type, class, rarity, set_name, description, image_url) VALUES

-- Elf cards
('SV_ELF_001', 'フェアリー', 'Fairy', 1, 1, 1, 'follower', 'elf', 'bronze', 'Basic', '基本的なフェアリー。', ''),
('SV_ELF_002', 'エルフの少女・リザ', 'Elf Girl Liza', 2, 1, 2, 'follower', 'elf', 'silver', 'Classic', 'ファンファーレ: フェアリー1体を手札に加える。', ''),
('SV_ELF_003', 'エンシェントエルフ', 'Ancient Elf', 3, 2, 3, 'follower', 'elf', 'gold', 'Classic', 'ファンファーレ: このターン中にカードを2枚以上プレイしていたなら、+2/+0する。', ''),
('SV_ELF_004', 'ティターニア', 'Titania', 8, 7, 8, 'follower', 'elf', 'legendary', 'Classic', 'ファンファーレ: フェアリー2体を出す。自分の場にフェアリーがいるなら、相手のフォロワー1体を破壊する。', ''),
('SV_ELF_005', '自然の導き', 'Nature''s Guidance', 1, NULL, NULL, 'spell', 'elf', 'bronze', 'Classic', 'フォロワー1体を手札に戻す。そのフォロワーのコストを-1する。', ''),

-- Royal cards  
('SV_ROYAL_001', '歴戦の兵士', 'Veteran Lancer', 2, 2, 2, 'follower', 'royal', 'bronze', 'Classic', '指揮官・兵士タイプのフォロワー。', ''),
('SV_ROYAL_002', 'ロイヤルセイバー・オーレリア', 'Royal Saber Aurelia', 4, 3, 4, 'follower', 'royal', 'silver', 'Classic', 'ファンファーレ: 兵士フォロワー1体を手札に加える。', ''),
('SV_ROYAL_003', 'セージコマンダー', 'Sage Commander', 3, 2, 3, 'follower', 'royal', 'gold', 'Classic', 'ファンファーレ: 他の指揮官フォロワー1体は+1/+1する。', ''),
('SV_ROYAL_004', 'アレクサンダー', 'Alexander', 9, 8, 8, 'follower', 'royal', 'legendary', 'Classic', '疾走。ファンファーレ: 兵士フォロワー3体を出す。', ''),
('SV_ROYAL_005', '渾身の一撃', 'Whole-Souled Swing', 4, NULL, NULL, 'spell', 'royal', 'bronze', 'Classic', 'フォロワー1体に4ダメージ。', ''),

-- Witch cards
('SV_WITCH_001', 'マジックミサイル', 'Magic Missile', 1, NULL, NULL, 'spell', 'witch', 'bronze', 'Classic', '相手のリーダーか相手のフォロワー1体に1ダメージ。', ''),
('SV_WITCH_002', 'ウィンドブラスト', 'Wind Blast', 2, NULL, NULL, 'spell', 'witch', 'bronze', 'Classic', '相手のフォロワー1体に2ダメージ。', ''),
('SV_WITCH_003', 'クラフトウォーロック', 'Craft Warlock', 2, 2, 2, 'follower', 'witch', 'silver', 'Classic', 'ファンファーレ: 土の印・アミュレット1つを出す。', ''),
('SV_WITCH_004', 'デモンフレイムメイジ', 'Demonflame Mage', 5, 5, 4, 'follower', 'witch', 'gold', 'Classic', 'ファンファーレ: 土の印が場にあるなら、相手のフォロワー1体に2ダメージ。', ''),
('SV_WITCH_005', 'フレイムデストロイヤー', 'Flame Destroyer', 7, 9, 9, 'follower', 'witch', 'legendary', 'Classic', 'ファンファーレ: 土の印・アミュレット1つにつき、相手のフォロワー1体を破壊する。', ''),

-- Dragon cards
('SV_DRAGON_001', 'ドラゴンライダー', 'Dragon Rider', 2, 2, 1, 'follower', 'dragon', 'bronze', 'Classic', 'ファンファーレ: 覚醒状態なら+1/+1する。', ''),
('SV_DRAGON_002', 'サラマンダーブレス', 'Salamander Breath', 3, NULL, NULL, 'spell', 'dragon', 'bronze', 'Classic', '相手のフォロワー1体に3ダメージ。覚醒状態なら5ダメージ。', ''),
('SV_DRAGON_003', 'ドラゴニュートの威圧', 'Dragonewt''s Force', 4, 3, 4, 'follower', 'dragon', 'silver', 'Classic', 'ファンファーレ: 覚醒状態なら相手のフォロワー1体に2ダメージ。', ''),
('SV_DRAGON_004', 'ドラゴンガード', 'Dragon Guard', 5, 4, 6, 'follower', 'dragon', 'gold', 'Classic', '守護。ファンファーレ: 覚醒状態なら+2/+2する。', ''),
('SV_DRAGON_005', 'ジェネシスドラゴン', 'Genesis Dragon', 10, 10, 10, 'follower', 'dragon', 'legendary', 'Classic', '疾走。自分のターン終了時、他のフォロワーすべてを破壊する。', ''),

-- Necromancer cards
('SV_NECRO_001', 'スケルトン', 'Skeleton', 1, 1, 1, 'follower', 'necromancer', 'bronze', 'Classic', 'ラストワード: スケルトン1体を出す。', ''),
('SV_NECRO_002', 'ボーンキマイラ', 'Bone Chimera', 2, 1, 3, 'follower', 'necromancer', 'bronze', 'Classic', 'ファンファーレ: ネクロマンス2; +1/+0する。', ''),
('SV_NECRO_003', 'ソウルコンバージョン', 'Soul Conversion', 1, NULL, NULL, 'spell', 'necromancer', 'bronze', 'Classic', '自分のフォロワー1体を破壊する。カードを2枚引く。', ''),
('SV_NECRO_004', 'リッチ', 'Lich', 4, 3, 4, 'follower', 'necromancer', 'silver', 'Classic', 'ファンファーレ: ネクロマンス4; ゾンビ1体を出す。', ''),
('SV_NECRO_005', 'ケルベロス', 'Cerberus', 6, 4, 5, 'follower', 'necromancer', 'legendary', 'Classic', 'ファンファーレ: ミミ&ココ1体を手札に加える。', ''),

-- Vampire cards
('SV_VAMP_001', 'フォレストバット', 'Forest Bat', 1, 1, 1, 'follower', 'vampire', 'bronze', 'Classic', '疾走。', ''),
('SV_VAMP_002', 'ブラッドウルフ', 'Blood Wolf', 2, 2, 1, 'follower', 'vampire', 'bronze', 'Classic', '疾走。ファンファーレ: 自分のリーダーに1ダメージ。', ''),
('SV_VAMP_003', 'ヴァンピィ', 'Vampy', 2, 2, 2, 'follower', 'vampire', 'silver', 'Classic', 'ファンファーレ: 相手のフォロワー1体に1ダメージ。復讐状態なら3ダメージ。', ''),
('SV_VAMP_004', '鮮血の口付け', 'Bloody Mary', 4, NULL, NULL, 'spell', 'vampire', 'gold', 'Classic', '相手のリーダーに3ダメージ。自分のリーダーを3回復。', ''),
('SV_VAMP_005', 'アルカード', 'Alucard', 7, 7, 7, 'follower', 'vampire', 'legendary', 'Classic', '疾走。復讐状態でないなら、このフォロワーは攻撃できない。', ''),

-- Bishop cards
('SV_BISHOP_001', '治癒の祈り', 'Healing Prayer', 1, NULL, NULL, 'spell', 'bishop', 'bronze', 'Classic', '自分のリーダーを3回復。', ''),
('SV_BISHOP_002', 'プリズムプリースト', 'Prism Priest', 2, 1, 3, 'follower', 'bishop', 'bronze', 'Classic', 'ファンファーレ: カードを1枚引く。', ''),
('SV_BISHOP_003', 'ヒーリングエンジェル', 'Healing Angel', 3, 2, 3, 'follower', 'bishop', 'silver', 'Classic', 'ファンファーレ: 自分のリーダーを3回復。', ''),
('SV_BISHOP_004', 'テミスの審判', 'Themis''s Decree', 6, NULL, NULL, 'spell', 'bishop', 'gold', 'Classic', 'すべてのフォロワーを破壊する。', ''),
('SV_BISHOP_005', 'サタン', 'Satan', 10, 10, 10, 'follower', 'bishop', 'legendary', 'Classic', 'ファンファーレ: 手札をすべて「アポカリプスデッキ」のカードに変える。', ''),

-- Nemesis cards
('SV_NEMESIS_001', 'マシンエンジェル', 'Machina Angel', 2, 2, 2, 'follower', 'nemesis', 'bronze', 'Machina', '機械・フォロワー。', ''),
('SV_NEMESIS_002', 'アナライズアーティファクト', 'Analyzing Artifact', 1, 1, 1, 'follower', 'nemesis', 'bronze', 'Machina', 'アーティファクト・フォロワー。ファンファーレ: カードを1枚引く。', ''),
('SV_NEMESIS_003', 'ロココ', 'Rococo', 3, 2, 3, 'follower', 'nemesis', 'silver', 'Machina', 'ファンファーレ: アーティファクト・カード1枚を手札に加える。', ''),
('SV_NEMESIS_004', 'ハクラビ', 'Hakrabi', 4, 3, 4, 'follower', 'nemesis', 'gold', 'Machina', 'ファンファーレ: 共鳴状態なら、アーティファクト・カード2枚を手札に加える。', ''),
('SV_NEMESIS_005', 'ノア', 'Noah', 8, 6, 8, 'follower', 'nemesis', 'legendary', 'Machina', 'ファンファーレ: 手札のアーティファクト・カードすべてのコストを0にする。', ''),

-- Neutral cards
('SV_NEUTRAL_001', 'ゴブリン', 'Goblin', 1, 1, 1, 'follower', 'neutral', 'bronze', 'Classic', '基本的なフォロワー。', ''),
('SV_NEUTRAL_002', 'フェンサー', 'Fencer', 2, 2, 1, 'follower', 'neutral', 'bronze', 'Classic', '疾走。', ''),
('SV_NEUTRAL_003', 'エンジェルナイト', 'Angel Knight', 3, 2, 3, 'follower', 'neutral', 'silver', 'Classic', '守護。', ''),
('SV_NEUTRAL_004', 'ルシフェル', 'Lucifer', 8, 6, 8, 'follower', 'neutral', 'legendary', 'Classic', 'ファンファーレ: 自分のリーダーの体力の上限を10にして、体力を10回復。', ''),
('SV_NEUTRAL_005', 'バハムート', 'Bahamut', 10, 13, 13, 'follower', 'neutral', 'legendary', 'Classic', 'ファンファーレ: 他のフォロワーすべてとアミュレットすべてを破壊する。', '');

-- Add indexes for better performance
CREATE INDEX idx_svcard_class ON mt_svcard(class);
CREATE INDEX idx_svcard_cost ON mt_svcard(cost);
CREATE INDEX idx_svcard_type ON mt_svcard(type);
CREATE INDEX idx_svcard_rarity ON mt_svcard(rarity);
CREATE INDEX idx_svcard_card_id ON mt_svcard(card_id);

CREATE INDEX idx_svdeck_author ON mt_svdeck(author_id);
CREATE INDEX idx_svdeck_public ON mt_svdeck(is_public);
CREATE INDEX idx_svdeck_token ON mt_svdeck(share_token);
CREATE INDEX idx_svdeck_class ON mt_svdeck(class);
CREATE INDEX idx_svdeck_created ON mt_svdeck(created_on);