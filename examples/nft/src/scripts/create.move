script {
use 0x1::NonFungibleToken;
use 0x2::TestNft::{Self, TestNft};
fun main(account: signer) {
    let uri = x"0001";
    let token = TestNft::new_test_nft();
    NonFungibleToken::create<TestNft>(&account, @0x1, token, uri);
}
}
