package ShadowverseDeckBuilder::Tags;

use strict;
use warnings;
use JSON;

sub _hdlr_sv_deck_list {
    my ($ctx, $args, $cond) = @_;
    
    my $builder = $ctx->stash('builder');
    my $tokens = $ctx->stash('tokens');
    
    # Get parameters
    my $limit = $args->{limit} || 10;
    my $offset = $args->{offset} || 0;
    my $public_only = $args->{public_only} || 0;
    my $author_id = $args->{author_id};
    my $class_filter = $args->{class};
    
    # Build conditions
    my %terms = ();
    if ($public_only) {
        $terms{is_public} = 1;
    }
    if ($author_id) {
        $terms{author_id} = $author_id;
    }
    if ($class_filter) {
        $terms{class} = $class_filter;
    }
    
    # Load decks
    require ShadowverseDeckBuilder::SVDeck;
    my @decks = ShadowverseDeckBuilder::SVDeck->load(
        \%terms,
        {
            sort => 'created_on',
            direction => 'descend',
            limit => $limit,
            offset => $offset,
        }
    );
    
    my $out = '';
    my $vars = $ctx->var_stash;
    
    foreach my $deck (@decks) {
        local $vars->{svdeck_id} = $deck->id;
        local $vars->{svdeck_title} = $deck->title;
        local $vars->{svdeck_description} = $deck->description;
        local $vars->{svdeck_class} = $deck->class;
        local $vars->{svdeck_class_jp} = $deck->class_jp;
        local $vars->{svdeck_author_id} = $deck->author_id;
        local $vars->{svdeck_author_name} = $deck->author_name;
        local $vars->{svdeck_is_public} = $deck->is_public;
        local $vars->{svdeck_share_token} = $deck->share_token;
        local $vars->{svdeck_view_count} = $deck->view_count;
        local $vars->{svdeck_like_count} = $deck->like_count;
        local $vars->{svdeck_created_on} = $deck->created_on;
        local $vars->{svdeck_modified_on} = $deck->modified_on;
        local $vars->{svdeck_card_count} = $deck->get_card_count;
        local $vars->{svdeck_share_url} = $deck->get_share_url;
        
        defined(my $res = $builder->build($ctx, $tokens, $cond))
            or return $ctx->error($builder->errstr);
        $out .= $res;
    }
    
    return $out;
}

sub _hdlr_sv_deck_detail {
    my ($ctx, $args) = @_;
    
    my $token = $args->{token} || $ctx->var('svdeck_share_token');
    my $deck_id = $args->{id} || $ctx->var('svdeck_id');
    
    require ShadowverseDeckBuilder::SVDeck;
    my $deck;
    
    if ($token) {
        $deck = ShadowverseDeckBuilder::SVDeck->load({ share_token => $token });
    } elsif ($deck_id) {
        $deck = ShadowverseDeckBuilder::SVDeck->load($deck_id);
    }
    
    return '' unless $deck;
    
    # Increment view count for public decks accessed by token
    if ($token && $deck->is_public) {
        $deck->increment_view_count;
    }
    
    my $vars = $ctx->var_stash;
    local $vars->{svdeck_id} = $deck->id;
    local $vars->{svdeck_title} = $deck->title;
    local $vars->{svdeck_description} = $deck->description;
    local $vars->{svdeck_class} = $deck->class;
    local $vars->{svdeck_class_jp} = $deck->class_jp;
    local $vars->{svdeck_author_id} = $deck->author_id;
    local $vars->{svdeck_author_name} = $deck->author_name;
    local $vars->{svdeck_is_public} = $deck->is_public;
    local $vars->{svdeck_share_token} = $deck->share_token;
    local $vars->{svdeck_view_count} = $deck->view_count;
    local $vars->{svdeck_like_count} = $deck->like_count;
    local $vars->{svdeck_created_on} = $deck->created_on;
    local $vars->{svdeck_modified_on} = $deck->modified_on;
    local $vars->{svdeck_card_count} = $deck->get_card_count;
    local $vars->{svdeck_share_url} = $deck->get_share_url;
    local $vars->{svdeck_cards_json} = $deck->cards_data;
    
    # Set cards data for nested loops
    my $cards_with_details = $deck->get_cards_with_details;
    local $vars->{svdeck_cards} = $cards_with_details;
    
    # Set cost distribution
    my $cost_dist = $deck->get_cost_distribution;
    local $vars->{svdeck_cost_distribution} = $cost_dist;
    
    return '';
}

sub _hdlr_sv_card_list {
    my ($ctx, $args, $cond) = @_;
    
    my $builder = $ctx->stash('builder');
    my $tokens = $ctx->stash('tokens');
    
    # Get parameters
    my $limit = $args->{limit} || 50;
    my $offset = $args->{offset} || 0;
    my $class_filter = $args->{class};
    my $type_filter = $args->{type};
    my $rarity_filter = $args->{rarity};
    my $cost_filter = $args->{cost};
    
    # Build conditions
    my %terms = ();
    if ($class_filter) {
        $terms{class} = $class_filter;
    }
    if ($type_filter) {
        $terms{type} = $type_filter;
    }
    if ($rarity_filter) {
        $terms{rarity} = $rarity_filter;
    }
    if (defined $cost_filter) {
        $terms{cost} = $cost_filter;
    }
    
    # Load cards
    require ShadowverseDeckBuilder::SVCard;
    my @cards = ShadowverseDeckBuilder::SVCard->load(
        \%terms,
        {
            sort => [{ column => 'cost' }, { column => 'name' }],
            limit => $limit,
            offset => $offset,
        }
    );
    
    my $out = '';
    my $vars = $ctx->var_stash;
    
    foreach my $card (@cards) {
        local $vars->{svcard_id} = $card->id;
        local $vars->{svcard_card_id} = $card->card_id;
        local $vars->{svcard_name} = $card->name;
        local $vars->{svcard_name_en} = $card->name_en;
        local $vars->{svcard_cost} = $card->cost;
        local $vars->{svcard_attack} = $card->attack;
        local $vars->{svcard_life} = $card->life;
        local $vars->{svcard_type} = $card->type;
        local $vars->{svcard_class} = $card->class;
        local $vars->{svcard_rarity} = $card->rarity;
        local $vars->{svcard_set_name} = $card->set_name;
        local $vars->{svcard_description} = $card->description;
        local $vars->{svcard_image_url} = $card->image_url;
        local $vars->{svcard_class_jp} = $card->get_class_name_jp;
        local $vars->{svcard_type_jp} = $card->get_type_name_jp;
        local $vars->{svcard_rarity_jp} = $card->get_rarity_name_jp;
        
        defined(my $res = $builder->build($ctx, $tokens, $cond))
            or return $ctx->error($builder->errstr);
        $out .= $res;
    }
    
    return $out;
}

sub _hdlr_sv_deck_builder {
    my ($ctx, $args) = @_;
    
    # This tag renders the Vue.js deck builder interface
    my $user_id = $args->{user_id} || '';
    my $deck_id = $args->{deck_id} || '';
    my $public_access = $args->{public_access} || 0;
    
    # Load all cards for the builder
    require ShadowverseDeckBuilder::SVCard;
    my @cards = ShadowverseDeckBuilder::SVCard->load(
        {},
        { sort => [{ column => 'cost' }, { column => 'name' }] }
    );
    
    my @card_data = ();
    foreach my $card (@cards) {
        push @card_data, $card->as_hash;
    }
    
    my $cards_json = encode_json(\@card_data);
    
    # Load existing deck if specified
    my $saved_cards = '[]';
    if ($deck_id) {
        require ShadowverseDeckBuilder::SVDeck;
        my $deck = ShadowverseDeckBuilder::SVDeck->load($deck_id);
        if ($deck) {
            $saved_cards = $deck->cards_data;
        }
    }
    
    # Return the HTML for the deck builder
    return qq{
<div id="sv-deck-builder-app">
    <deck-editor 
        :all-cards='$cards_json'
        :saved-cards='$saved_cards'
    ></deck-editor>
</div>
<script>
window.SV_CARDS_DATA = $cards_json;
window.SV_SAVED_CARDS = $saved_cards;
</script>
};
}

1;