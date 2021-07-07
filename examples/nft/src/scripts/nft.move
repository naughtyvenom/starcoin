script {
use 0x1::NonFungibleToken;
use 0x1::TestNft::TestNft;
fun main(account: signer) {
    NonFungibleToken::initialize<TestNft>(&account, false, 0);
}
}
