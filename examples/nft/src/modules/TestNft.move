address 0x1 {
module TestNft {
    struct TestNft has store, key, drop{}
    public fun new_test_nft(): TestNft {
        TestNft{}
    }
}
}

address 0x2 {
module MoveNft {
    use 0x1::NonFungibleToken::{Self, NonFungibleToken};
    use 0x1::TestNft::TestNft;
    use 0x1::Signer;
    struct MoveNft has store, key, drop {
        nft: NonFungibleToken<TestNft>
    }
    public fun move_nft(account: &signer) {
        let nft = NonFungibleToken::get_nft<TestNft>(account);
        move_to<MoveNft>(account, MoveNft{ nft });
    }
    public fun move_back_nft(account: &signer) acquires MoveNft {
        let sender = Signer::address_of(account);
        let MoveNft { nft } = move_from<MoveNft>(sender);
        NonFungibleToken::put_nft<TestNft>(account, nft);
    }
}
}