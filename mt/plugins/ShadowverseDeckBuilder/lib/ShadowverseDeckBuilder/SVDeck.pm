package ShadowverseDeckBuilder::SVDeck;

use strict;
use warnings;
use base qw( MT::Object );
use JSON;

__PACKAGE__->install_properties({
    column_defs => {
        'id' => 'integer not null auto_increment',
        'title' => 'string(255) not null',
        'description' => 'text',
        'class' => 'string(20) not null',
        'class_jp' => 'string(20) not null',
        'cards_data' => 'text not null',
        'author_id' => 'integer not null',
        'author_name' => 'string(255) not null',
        'is_public' => 'integer not null default 0',
        'share_token' => 'string(32)',
        'view_count' => 'integer not null default 0',
        'like_count' => 'integer not null default 0',
        'created_on' => 'datetime not null',
        'modified_on' => 'datetime not null',
    },
    indexes => {
        author_id => 1,
        is_public => 1,
        share_token => 1,
        class => 1,
        created_on => 1,
    },
    audit => 1,
    datasource => 'svdeck',
    primary_key => 'id',
});

sub class_label {
    MT->translate('Shadowverse Deck');
}

sub class_labels {
    MT->translate('Shadowverse Decks');
}

sub get_cards {
    my $self = shift;
    my $cards_data = $self->cards_data || '[]';
    
    eval {
        return decode_json($cards_data);
    };
    if ($@) {
        return [];
    }
}

sub set_cards {
    my $self = shift;
    my $cards = shift || [];
    
    $self->cards_data(encode_json($cards));
}

sub get_card_count {
    my $self = shift;
    my $cards = $self->get_cards;
    my $total = 0;
    
    foreach my $card (@$cards) {
        $total += $card->{count} if $card->{count};
    }
    
    return $total;
}

sub get_cards_with_details {
    my $self = shift;
    my $cards = $self->get_cards;
    my @detailed_cards = ();
    
    require ShadowverseDeckBuilder::SVCard;
    
    foreach my $card_ref (@$cards) {
        my $card = ShadowverseDeckBuilder::SVCard->load({ card_id => $card_ref->{card_id} });
        if ($card) {
            push @detailed_cards, {
                card => $card->as_hash,
                count => $card_ref->{count},
            };
        }
    }
    
    # Sort by cost, then by name
    @detailed_cards = sort {
        $a->{card}->{cost} <=> $b->{card}->{cost} ||
        $a->{card}->{name} cmp $b->{card}->{name}
    } @detailed_cards;
    
    return \@detailed_cards;
}

sub get_cost_distribution {
    my $self = shift;
    my $cards = $self->get_cards_with_details;
    my %distribution = ();
    
    # Initialize distribution
    for my $i (0..10) {
        my $key = $i == 10 ? '10+' : $i;
        $distribution{$key} = 0;
    }
    
    foreach my $card_ref (@$cards) {
        my $cost = $card_ref->{card}->{cost};
        my $key = $cost >= 10 ? '10+' : $cost;
        $distribution{$key} += $card_ref->{count};
    }
    
    return \%distribution;
}

sub generate_share_token {
    my $self = shift;
    
    # Generate a unique token for sharing
    my @chars = ('a'..'z', 'A'..'Z', '0'..'9');
    my $token = '';
    for (1..32) {
        $token .= $chars[rand @chars];
    }
    
    # Check if token already exists
    my $existing = ShadowverseDeckBuilder::SVDeck->load({ share_token => $token });
    if ($existing) {
        return $self->generate_share_token(); # Try again
    }
    
    $self->share_token($token);
    return $token;
}

sub increment_view_count {
    my $self = shift;
    $self->view_count(($self->view_count || 0) + 1);
    $self->save;
}

sub get_share_url {
    my $self = shift;
    my $app = MT->instance;
    my $blog = $app->blog;
    
    if ($self->share_token && $blog) {
        my $base_url = $blog->site_url;
        $base_url =~ s/\/$//;
        return "$base_url/deck/" . $self->share_token;
    }
    
    return '';
}

sub as_hash {
    my $self = shift;
    return {
        id => $self->id,
        title => $self->title,
        description => $self->description,
        class => $self->class,
        class_jp => $self->class_jp,
        cards_data => $self->cards_data,
        author_id => $self->author_id,
        author_name => $self->author_name,
        is_public => $self->is_public,
        share_token => $self->share_token,
        view_count => $self->view_count,
        like_count => $self->like_count,
        created_on => $self->created_on,
        modified_on => $self->modified_on,
        card_count => $self->get_card_count,
        share_url => $self->get_share_url,
        cards => $self->get_cards_with_details,
        cost_distribution => $self->get_cost_distribution,
    };
}

1;