script {
use 0x1::NonFungibleToken;
use 0x1::TestNft::TestNft;
use 0x1::Hash;
fun main(account: signer,to_addr:address) {
    let input = b"input";
    let token_id = Hash::sha2_256(input);
    NonFungibleToken::safe_transfer<TestNft>(&account, @0x1, token_id, to_addr);
}
}
