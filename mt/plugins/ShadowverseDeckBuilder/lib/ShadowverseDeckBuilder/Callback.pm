package ShadowverseDeckBuilder::Callback;

use strict;
use warnings;

sub cms_init_request {
    my ($cb, $app) = @_;
    
    # Add methods for public deck access
    $app->add_methods(
        'public_deck_view' => \&public_deck_view,
        'public_deck_create' => \&public_deck_create,
        'public_deck_save' => \&public_deck_save,
        'api_cards' => \&api_cards,
    );
    
    return 1;
}

sub public_deck_view {
    my $app = shift;
    my $share_token = $app->param('share_token') || '';
    
    return $app->error("Invalid share token") unless $share_token;
    
    # Load deck by share token
    require ShadowverseDeckBuilder::SVDeck;
    my $deck = ShadowverseDeckBuilder::SVDeck->load({ 
        share_token => $share_token,
        is_public => 1 
    });
    
    return $app->error("Deck not found") unless $deck;
    
    # Increment view count
    $deck->increment_view_count;
    
    # Get deck details
    my $deck_data = $deck->as_hash;
    my $cards_with_details = $deck->get_cards_with_details;
    
    # Build OGP meta tags
    my $title = $deck->title . " - Shadowverseデッキ";
    my $description = $deck->description || 
        sprintf("%sデッキ「%s」- %d枚のカードで構成", 
                $deck->class_jp, $deck->title, $deck->get_card_count);
    my $share_url = $deck->get_share_url;
    
    # Build cost distribution chart data
    my $cost_dist = $deck->get_cost_distribution;
    
    # Render template with deck data
    my $tmpl = $app->load_tmpl('deck_share.tmpl');
    $tmpl->param(
        deck => $deck_data,
        cards => $cards_with_details,
        cost_distribution => $cost_dist,
        og_title => $title,
        og_description => $description,
        og_url => $share_url,
        page_title => $title,
    );
    
    return $tmpl;
}

sub public_deck_create {
    my $app = shift;
    
    # Check if public access is enabled
    my $plugin = MT->component('ShadowverseDeckBuilder');
    my $public_access = $plugin->get_config_value('SVDeckBuilderPublicAccess');
    
    unless ($public_access) {
        return $app->error("Public deck creation is disabled");
    }
    
    # Check if user is logged in for deck saving
    my $user = $app->user;
    my $can_save = $user ? 1 : 0;
    
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
    
    # Render public deck builder template
    my $tmpl = $app->load_tmpl('public_deck_builder.tmpl');
    $tmpl->param(
        all_cards => JSON::encode_json(\@card_data),
        can_save => $can_save,
        user_id => $user ? $user->id : 0,
        user_name => $user ? ($user->name || $user->nickname) : '',
    );
    
    return $tmpl;
}

sub public_deck_save {
    my $app = shift;
    
    # Check if user is logged in
    my $user = $app->user;
    return $app->error("Login required to save decks") unless $user;
    
    # Check if public access is enabled
    my $plugin = MT->component('ShadowverseDeckBuilder');
    my $public_access = $plugin->get_config_value('SVDeckBuilderPublicAccess');
    
    unless ($public_access) {
        return $app->error("Public deck creation is disabled");
    }
    
    # Get form data
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
        $cards = JSON::decode_json($cards_data);
    };
    return $app->error("Invalid cards data") if $@;
    
    # Validate deck (should have 40 cards)
    my $total_cards = 0;
    foreach my $card (@$cards) {
        $total_cards += $card->{count} if $card->{count};
    }
    return $app->error("Deck must have exactly 40 cards") unless $total_cards == 40;
    
    # Check user deck limit
    my $max_decks = $plugin->get_config_value('SVDeckBuilderMaxDecksPerUser') || 50;
    require ShadowverseDeckBuilder::SVDeck;
    my $user_deck_count = ShadowverseDeckBuilder::SVDeck->count({ author_id => $user->id });
    
    if ($user_deck_count >= $max_decks) {
        return $app->error("You have reached the maximum number of decks ($max_decks)");
    }
    
    # Create new deck
    my $deck = ShadowverseDeckBuilder::SVDeck->new;
    
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
    $deck->author_id($user->id);
    $deck->author_name($user->name || $user->nickname || 'Unknown');
    $deck->is_public($is_public);
    $deck->created_on(MT::Util::epoch2ts(undef, time));
    $deck->modified_on(MT::Util::epoch2ts(undef, time));
    
    # Generate share token if public
    if ($is_public) {
        $deck->generate_share_token();
    }
    
    $deck->save or return $app->error("Failed to save deck: " . $deck->errstr);
    
    # Return success response
    $app->send_http_header('application/json');
    return JSON::encode_json({
        success => 1,
        deck_id => $deck->id,
        share_url => $deck->get_share_url,
        message => 'Deck saved successfully'
    });
}

sub api_cards {
    my $app = shift;
    
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
    
    $app->send_http_header('application/json');
    return JSON::encode_json(\@card_data);
}

1;