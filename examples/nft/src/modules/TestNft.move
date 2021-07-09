address 0x2 {
module TestNft {
    struct TestNft has store, key, drop {}
    public fun new_test_nft(): TestNft {
        TestNft{}
    }
}
}
