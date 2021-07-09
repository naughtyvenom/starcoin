script {
use 0x1::NonFungibleToken;
use 0x2::TestNft::TestNft;
fun main(account: signer) {
    NonFungibleToken::accept_token<TestNft>(&account);
}
}
