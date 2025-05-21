#[test_only]
module cifarm::dragon_fruit_tests {
    // ===== Imports =====
    use cifarm::dragon_fruit_collection::{Self, DRAGON_FRUIT_COLLECTION};
    use cifarm::nft_collection::{CollectionMetadata};
    use std::string::{Self};
    use std::ascii::{Self};
    use sui::test_scenario::{Self};
    use cifarm::nft_treasury_cap::{Self};
    use sui::url::{Self};

    #[test]
    fun test_init() {
        let initial_owner = @0xCAFE;
        let mut scenario = test_scenario::begin(initial_owner);
        let ctx = test_scenario::ctx(&mut scenario);

        // Call the initializer
        dragon_fruit_collection::init_for_testing(ctx);

        // Next transaction to retrieve objects
        test_scenario::next_tx(&mut scenario, initial_owner);

        // Retrieve treasury cap (owned by initial_owner)
        let treasury_cap = test_scenario::take_from_sender<nft_treasury_cap::NFTTreasuryCap<DRAGON_FRUIT_COLLECTION>>(&scenario);
        // Assert the uri, name, and traits
        assert!(treasury_cap.get_total_supply() == 0);
        // return the treasury cap to the sender
        test_scenario::return_to_sender(&scenario, treasury_cap);
        // Retrieve collection metadata (shared object)
        let collection_metadata = test_scenario::take_shared<CollectionMetadata>(&scenario);
        // Assert the uri, name, and traits
        assert!(collection_metadata.get_collection_name() == string::from_ascii(ascii::string(b"Dragon Fruit Collection")));
        assert!(collection_metadata.get_collection_uri() == url::new_unsafe_from_bytes(b"https://cifarm.sgp1.cdn.digitaloceanspaces.com/1TespPmHeRo5WWGp2z3wMFDKmeVL2SGcB3cCo5y9QS1"));
        // ... now you can use treasury_cap and collection_metadata in your test
        // return the collection metadata to the sender
        test_scenario::return_shared(collection_metadata);
        test_scenario::end(scenario);
}
}