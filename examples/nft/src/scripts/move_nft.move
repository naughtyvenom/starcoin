script {
use 0x1::NonFungibleToken;
use 0x1::TestNft::{Self, TestNft};
use 0x1::Hash;
use 0x2::MoveNft;    
fun main(account: signer) {
    let input = b"input";
    let token_id = Hash::sha2_256(input);
    let token = TestNft::new_test_nft();
    NonFungibleToken::preemptive<TestNft>(&account, @0x1, token_id, token);
    MoveNft::move_nft(&account);
}
}
