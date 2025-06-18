package ShadowverseDeckBuilder::CMS;

use strict;
use warnings;
use JSON;

sub deck_list_mode {
    my $app = shift;
    my $param = {};
    
    # Get current user
    my $user = $app->user;
    return $app->error("Permission denied") unless $user;
    
    # Load user's decks
    require ShadowverseDeckBuilder::SVDeck;
    my @decks = ShadowverseDeckBuilder::SVDeck->load(
        { author_id => $user->id },
        { sort => 'modified_on', direction => 'descend' }
    );
    
    my @deck_data = ();
    foreach my $deck (@decks) {
        push @deck_data, $deck->as_hash;
    }
    
    $param->{decks} = \@deck_data;
    $param->{deck_count} = scalar @decks;
    
    return $app->load_tmpl('deck_list.tmpl', $param);
}

sub deck_edit_mode {
    my $app = shift;
    my $param = {};
    
    my $user = $app->user;
    return $app->error("Permission denied") unless $user;
    
    my $deck_id = $app->param('id');
    my $deck;
    
    if ($deck_id) {
        # Edit existing deck
        require ShadowverseDeckBuilder::SVDeck;
        $deck = ShadowverseDeckBuilder::SVDeck->load($deck_id);
        return $app->error("Deck not found") unless $deck;
        return $app->error("Permission denied") unless $deck->author_id == $user->id;
        
        $param->{deck} = $deck->as_hash;
        $param->{editing} = 1;
    } else {
        # Create new deck
        $param->{editing} = 0;
    }
    
    # Load all cards
    require ShadowverseDeckBuilder::SVCard;
    my @cards = ShadowverseDeckBuilder::SVCard->load(
        {},
        { sort => [{ column => 'cost' }, { column => 'name' }] }
    );
    
    my @card_data = ();
    foreach my $card (@cards) {
        push @card_data, $card->as_hash;
    }
    
    $param->{all_cards} = encode_json(\@card_data);
    $param->{saved_cards} = $deck ? $deck->cards_data : '[]';
    
    return $app->load_tmpl('deck_edit.tmpl', $param);
}

sub deck_save_mode {
    my $app = shift;
    
    my $user = $app->user;
    return $app->error("Permission denied") unless $user;
    
    my $deck_id = $app->param('id');
    my $title = $app->param('title') || '';
    my $description = $app->param('description') || '';
    my $class = $app->param('class') || '';
    my $cards_data = $app->param('cards_data') || '[]';
    my $is_public = $app->param('is_public') ? 1 : 0;
    
    return $app->error("Title is required") unless $title;
    return $app->error("Class is required") unless $class;
    
    # Validate cards data
    my $cards;
    eval {
        $cards = decode_json($cards_data);
    };
    return $app->error("Invalid cards data") if $@;
    
    # Validate deck (should have 40 cards)
    my $total_cards = 0;
    foreach my $card (@$cards) {
        $total_cards += $card->{count} if $card->{count};
    }
    return $app->error("Deck must have exactly 40 cards") unless $total_cards == 40;
    
    require ShadowverseDeckBuilder::SVDeck;
    my $deck;
    
    if ($deck_id) {
        # Update existing deck
        $deck = ShadowverseDeckBuilder::SVDeck->load($deck_id);
        return $app->error("Deck not found") unless $deck;
        return $app->error("Permission denied") unless $deck->author_id == $user->id;
    } else {
        # Create new deck
        $deck = ShadowverseDeckBuilder::SVDeck->new;
        $deck->author_id($user->id);
        $deck->author_name($user->name || $user->nickname || 'Unknown');
        $deck->created_on(MT::Util::epoch2ts(undef, time));
    }
    
    # Get Japanese class name
    my %class_map = (
        'elf' => 'エルフ',
        'royal' => 'ロイヤル',
        'witch' => 'ウィッチ',
        'dragon' => 'ドラゴン',
        'necromancer' => 'ネクロマンサー',
        'vampire' => 'ヴァンパイア',
        'bishop' => 'ビショップ',
        'nemesis' => 'ネメシス',
        'neutral' => 'ニュートラル',
    );
    
    $deck->title($title);
    $deck->description($description);
    $deck->class($class);
    $deck->class_jp($class_map{$class} || $class);
    $deck->cards_data($cards_data);
    $deck->is_public($is_public);
    $deck->modified_on(MT::Util::epoch2ts(undef, time));
    
    # Generate share token if public and doesn't have one
    if ($is_public && !$deck->share_token) {
        $deck->generate_share_token();
    }
    
    $deck->save or return $app->error("Failed to save deck: " . $deck->errstr);
    
    return $app->redirect(
        $app->uri(
            mode => 'sv_deck_list',
            args => { saved => 1 }
        )
    );
}

sub deck_delete_mode {
    my $app = shift;
    
    my $user = $app->user;
    return $app->error("Permission denied") unless $user;
    
    my $deck_id = $app->param('id');
    return $app->error("Deck ID is required") unless $deck_id;
    
    require ShadowverseDeckBuilder::SVDeck;
    my $deck = ShadowverseDeckBuilder::SVDeck->load($deck_id);
    return $app->error("Deck not found") unless $deck;
    return $app->error("Permission denied") unless $deck->author_id == $user->id;
    
    $deck->remove or return $app->error("Failed to delete deck");
    
    return $app->redirect(
        $app->uri(
            mode => 'sv_deck_list',
            args => { deleted => 1 }
        )
    );
}

sub card_list_mode {
    my $app = shift;
    my $param = {};
    
    my $user = $app->user;
    return $app->error("Permission denied") unless $user;
    
    # Load all cards
    require ShadowverseDeckBuilder::SVCard;
    my @cards = ShadowverseDeckBuilder::SVCard->load(
        {},
        { sort => [{ column => 'cost' }, { column => 'name' }] }
    );
    
    my @card_data = ();
    foreach my $card (@cards) {
        push @card_data, $card->as_hash;
    }
    
    $param->{cards} = \@card_data;
    $param->{card_count} = scalar @cards;
    
    return $app->load_tmpl('card_list.tmpl', $param);
}

sub card_edit_mode {
    my $app = shift;
    my $param = {};
    
    my $user = $app->user;
    return $app->error("Permission denied") unless $user;
    
    my $card_id = $app->param('id');
    my $card;
    
    if ($card_id) {
        # Edit existing card
        require ShadowverseDeckBuilder::SVCard;
        $card = ShadowverseDeckBuilder::SVCard->load($card_id);
        return $app->error("Card not found") unless $card;
        
        $param->{card} = $card->as_hash;
        $param->{editing} = 1;
    } else {
        # Create new card
        $param->{editing} = 0;
    }
    
    return $app->load_tmpl('card_edit.tmpl', $param);
}

sub card_save_mode {
    my $app = shift;
    
    my $user = $app->user;
    return $app->error("Permission denied") unless $user;
    
    my $card_id = $app->param('id');
    my $card_id_field = $app->param('card_id') || '';
    my $name = $app->param('name') || '';
    my $name_en = $app->param('name_en') || '';
    my $cost = $app->param('cost') || 0;
    my $attack = $app->param('attack');
    my $life = $app->param('life');
    my $type = $app->param('type') || '';
    my $class = $app->param('class') || '';
    my $rarity = $app->param('rarity') || '';
    my $set_name = $app->param('set_name') || '';
    my $description = $app->param('description') || '';
    my $image_url = $app->param('image_url') || '';
    
    return $app->error("Card ID is required") unless $card_id_field;
    return $app->error("Name is required") unless $name;
    return $app->error("Type is required") unless $type;
    return $app->error("Class is required") unless $class;
    return $app->error("Rarity is required") unless $rarity;
    
    require ShadowverseDeckBuilder::SVCard;
    my $card;
    
    if ($card_id) {
        # Update existing card
        $card = ShadowverseDeckBuilder::SVCard->load($card_id);
        return $app->error("Card not found") unless $card;
    } else {
        # Create new card
        $card = ShadowverseDeckBuilder::SVCard->new;
    }
    
    $card->card_id($card_id_field);
    $card->name($name);
    $card->name_en($name_en);
    $card->cost($cost);
    $card->attack($attack eq '' ? undef : $attack);
    $card->life($life eq '' ? undef : $life);
    $card->type($type);
    $card->class($class);
    $card->rarity($rarity);
    $card->set_name($set_name);
    $card->description($description);
    $card->image_url($image_url);
    
    $card->save or return $app->error("Failed to save card: " . $card->errstr);
    
    return $app->redirect(
        $app->uri(
            mode => 'sv_card_list',
            args => { saved => 1 }
        )
    );
}

1;