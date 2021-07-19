address 0x1 {
module Oracle {
    use 0x1::Event;
    use 0x1::Timestamp;
    use 0x1::Signer;
    use 0x1::Vector;

    struct PriceFeedInfo<DateT> has key {
        ///Get the number of decimals present in the data value.
        decimals: u8,
        ///Get the description of the data type
        description: vector<u8>,
    }

    struct PriceFeedData has copy, store, drop {
        version: u64,
        answer: u128,
        updatedAt: u64,
    }

    struct PriceFeed<DataT> has key {
        value: PriceFeedData,
    }

    struct PriceFeedUpdateEvent<DataT> has copy,drop {
        value: PriceFeedData,
    }

    struct PriceFeedDataSource<DataT> has key {
        counter: u64,
        update_events: Event::EventHandle<PriceFeedUpdateEvent<DataT>>,
    }

    struct UpdatePriceFeedCapability<DataT> has store, key {
        account: address,
    }

    public fun init_price_feed_data_source<DataT:store>(signer: &signer, init_price: u128) {
        let now = Timestamp::now_milliseconds();
        move_to(signer, PriceFeed<DataT> {
            value: PriceFeedData {
                version: 0,
                answer: init_price,
                updatedAt: now,
            }
        });
        move_to(signer, PriceFeedDataSource<DataT> {
            counter: 1,
            update_events: Event::new_event_handle<PriceFeedUpdateEvent<DataT>>(),
        });
        move_to(signer, UpdatePriceFeedCapability<DataT>{account: Signer::address_of(signer)});
    }

    public fun update_price_by_cap<DataT:store>(cap: &mut UpdatePriceFeedCapability<DataT>, price: u128) acquires PriceFeedDataSource,PriceFeed  {
        let account = cap.account;
        assert(exists<PriceFeedDataSource<DataT>>(account), 100);
        let source = borrow_global_mut<PriceFeedDataSource<DataT>>(account);
        let counter = source.counter;
        let now = Timestamp::now_milliseconds();
        let price_feed = borrow_global_mut<PriceFeed<DataT>>(account);
        price_feed.value.version = source.counter;
        price_feed.value.answer = price;
        price_feed.value.updateAt = now;
        source.counter = source.counter + 1;
        Event::emit_event(&mut source.update_events,PriceFeedUpdateEvent<DataT>{
            value: price_feed.value
        });
    }

    public fun update_price<DataT:store>(signer: &signer, price: u128) acquires UpdatePriceFeedCapability, PriceFeed{
        let account = Signer::address_of(signer);
        let cap = borrow_global_mut<UpdatePriceFeedCapability<DataT>>(account);
        update_price_by_cap(cap,price);
    }

    public fun get_price_feed<DataT:store>(addr: address): PriceFeedData acquires PriceFeed{
        let price_feed = borrow_global<PriceFeed<DataT>>(addr);
        *price_feed.value
    }

    public fun get_price_feeds<DataT:store>(addrs: vector<address>): vector<PriceFeedData> acquires PriceFeed{
        let len = Vector::length(&addrs);
        let results = Vector::empty();
        let i = 0;
        while (i < len){
            let addr = *Vector::borrow(&addrs, i);
            let data = Self::get_price_feed<DataT>(addr);
            Vector::push_back(&mut results, data);
            i = i + 1;
        };
        results
    }

    public fun get_price<DataT:store>(addr: address): u128 acquires PriceFeed{
        let price_feed = borrow_global<PriceFeed<DataT>>(addr);
        price_feed.value.answer
    }
}

}