package ShadowverseDeckBuilder::SVCard;

use strict;
use warnings;
use base qw( MT::Object );

__PACKAGE__->install_properties({
    column_defs => {
        'id' => 'integer not null auto_increment',
        'card_id' => 'string(50) not null',
        'name' => 'string(255) not null',
        'name_en' => 'string(255)',
        'cost' => 'integer not null',
        'attack' => 'integer',
        'life' => 'integer',
        'type' => 'string(20) not null',
        'class' => 'string(20) not null',
        'rarity' => 'string(20) not null',
        'set_name' => 'string(100)',
        'description' => 'text',
        'image_url' => 'string(500)',
    },
    indexes => {
        card_id => 1,
        class => 1,
        cost => 1,
        type => 1,
        rarity => 1,
    },
    audit => 0,
    datasource => 'svcard',
    primary_key => 'id',
});

sub class_label {
    MT->translate('Shadowverse Card');
}

sub class_labels {
    MT->translate('Shadowverse Cards');
}

sub get_class_name_jp {
    my $self = shift;
    my $class = $self->class || '';
    
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
    
    return $class_map{$class} || $class;
}

sub get_type_name_jp {
    my $self = shift;
    my $type = $self->type || '';
    
    my %type_map = (
        'follower' => 'フォロワー',
        'spell' => 'スペル',
        'amulet' => 'アミュレット',
    );
    
    return $type_map{$type} || $type;
}

sub get_rarity_name_jp {
    my $self = shift;
    my $rarity = $self->rarity || '';
    
    my %rarity_map = (
        'bronze' => 'ブロンズ',
        'silver' => 'シルバー',
        'gold' => 'ゴールド',
        'legendary' => 'レジェンド',
    );
    
    return $rarity_map{$rarity} || $rarity;
}

sub as_hash {
    my $self = shift;
    return {
        id => $self->id,
        card_id => $self->card_id,
        name => $self->name,
        name_en => $self->name_en,
        cost => $self->cost,
        attack => $self->attack,
        life => $self->life,
        type => $self->type,
        class => $self->class,
        rarity => $self->rarity,
        set_name => $self->set_name,
        description => $self->description,
        image_url => $self->image_url,
        class_jp => $self->get_class_name_jp,
        type_jp => $self->get_type_name_jp,
        rarity_jp => $self->get_rarity_name_jp,
    };
}

1;