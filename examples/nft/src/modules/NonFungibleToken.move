address 0x1 {
// a distributed key-value map is used to store entry (token_id, address, NonFungibleToken)
// key is the token_id(:vector<u8>), stored in a sorted linked list
// value is a struct 'NonFungibleToken', contains the non fungible token
// the account address of each list node is actually the owner of the token
module NonFungibleToken {
    use 0x1::SimpleSortedLinkedList;
    use 0x1::Option::{Self, Option};
    use 0x1::Signer;
    use 0x1::Vector;
    use 0x1::BCS;
    const NFT_PUBLISHER: address = @0x1;

    struct LimitedMeta has key {
        limited: bool,
        total: u64,
    }

    struct NonFungibleToken<Token> has key, store, drop {
        token: Option<Token>,
        id: vector<u8>,
        info: Option<NftInfo>,
            
    }
    struct NftInfo has key, store, drop{
        uri: vector<u8>,
        creator: address,
    }

    public fun initialize<Token: store>(account: &signer, limited: bool, total: u64) {
        let sender = Signer::address_of(account);
        assert(sender == NFT_PUBLISHER, 8000);

        let limited_meta = LimitedMeta {
            limited: limited,
            total: total,
        };
        move_to<LimitedMeta>(account, limited_meta);
        SimpleSortedLinkedList::create_new_list<vector<u8>>(account, Vector::empty());
    }

    public fun create<Token: store>(account: &signer, nft_service_address: address, token: Token, uri: vector<u8>):Option<Token> {
        let creator = Signer::address_of(account);
        let token_id = BCS::to_bytes(&creator);

        let (exist, location) = Self::find(copy token_id, nft_service_address);
        if (exist) return Option::some(token);
        SimpleSortedLinkedList::add_node<vector<u8>>(account, copy token_id, location);
        move_to<NonFungibleToken<Token>>(account,
                                         NonFungibleToken<Token>{
                                             token: Option::some(token),
                                             id: token_id,
                                             info: Option::some(NftInfo{uri: uri, creator:creator})});
        Option::none() //preemptive success
    }

    public fun accept_token<Token: store>(account: &signer) {
        let sender = Signer::address_of(account);
        assert(!exists<NonFungibleToken<Token>>(sender), 8001);
        SimpleSortedLinkedList::empty_node<vector<u8>>(account, Vector::empty());
        move_to<NonFungibleToken<Token>>(account, NonFungibleToken<Token>{token: Option::none(),id: Vector::empty<u8>(),info: Option::none()});
    }

    public fun safe_transfer<Token: drop + store>(account: &signer, _nft_service_address: address, token_id: vector<u8>, receiver: address) acquires NonFungibleToken {
        let sender = Signer::address_of(account);
        assert(exists<NonFungibleToken<Token>>(receiver), 8002);
        assert(Option::is_none(&borrow_global<NonFungibleToken<Token>>(receiver).token), 8005);
        assert(Self::get_token_id(sender) == token_id, 8003);
        let NonFungibleToken<Token>{token,id,info} = Self::get_nft<Token>(account);
        SimpleSortedLinkedList::move_node_to<vector<u8>>(account, receiver);
        let receiver_token_ref_mut = borrow_global_mut<NonFungibleToken<Token>>(receiver);
        receiver_token_ref_mut.token = token;
        receiver_token_ref_mut.id = id;
        receiver_token_ref_mut.info = info;
    }

    public fun get_token_id(addr: address): vector<u8> {
        SimpleSortedLinkedList::get_key_of_node<vector<u8>>(addr)
    }

    public fun find(token_id: vector<u8>, head_address: address): (bool, address) {
        SimpleSortedLinkedList::find<vector<u8>>(token_id, head_address)
    }

    public fun get_nft<Token: store>(account: &signer): NonFungibleToken<Token> acquires NonFungibleToken {
        let sender = Signer::address_of(account);
        assert(exists<NonFungibleToken<Token>>(sender), 8006);
        move_from<NonFungibleToken<Token>>(sender)
    }

    public fun put_nft<Token: store>(account: &signer, nft: NonFungibleToken<Token>) {
        move_to<NonFungibleToken<Token>>(account, nft)
    }
}
}
