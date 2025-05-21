#[test_only]
module cifarm::nft_collection_tests {
    // ===== Imports =====
    use sui::test_scenario::{Self};
    use sui::url::{Self};
    use cifarm::nft_collection::{NFT, Trait, Self};
    use cifarm::nft_treasury_cap::{Self, NFTTreasuryCap};
    use std::string::{Self};
    use std::ascii::{Self};

    // ===== Structs =====
    public struct OTW has drop {}

    // Error codes
    const ENFTMismatch: u64 = 0;

    #[test]
    fun test_mint_nft() {
        let initial_owner = @0xCAFE;
        let recipient = @0xBEEF;
        let mut scenario = test_scenario::begin(initial_owner);
        let ctx = test_scenario::ctx(&mut scenario);

        // Create treasury cap
        let mut treasury_cap = nft_treasury_cap::create_treasury_cap<OTW>(OTW {}, ctx);

        // Prepare NFT data
        let name = string::from_ascii(
                ascii::string(b"Dragon Fruit")
            );
        let uri = url::new_unsafe_from_bytes(b"https://cifarm.sgp1.cdn.digitaloceanspaces.com/1TespPmHeRo5WWGp2z3wMFDKmeVL2SGcB3cCo5y9QS1");
        
        // Create traits
        let trait_1 = nft_collection::create_trait(
            string::from_ascii(
                ascii::string(b"Quality Yield")
            ),
            string::from_ascii(
                ascii::string(b"100")
            )
        );
        // Create traits
        let trait_2 = nft_collection::create_trait(
            string::from_ascii(
                ascii::string(b"Growth Acceleration")
            ),
            string::from_ascii(
                ascii::string(b"100")
            )
        );
        // Create traits
        let trait_3 = nft_collection::create_trait(
            string::from_ascii(
                ascii::string(b"Quantity Yield Bonus")
            ),
            string::from_ascii(
                ascii::string(b"100")
            )
        );

        // Create traits vector
        let mut traits = vector<Trait>[];
        traits.push_back(trait_1);
        traits.push_back(trait_2);
        traits.push_back(trait_3);

        // Create traits object
        let traits = nft_collection::create_traits(
            traits
        );

        // Mint NFT
        nft_collection::mint_nft<OTW>(
            &mut treasury_cap,
            name,
            uri,
            traits,
            recipient,
            ctx
        );

        // Next transaction as recipient to check ownership
        test_scenario::next_tx(&mut scenario, recipient);
        let nft = test_scenario::take_from_address<NFT<OTW>>(
            &scenario, 
            recipient
        );

        // Check if the NFT is owned by the recipient
        assert!(nft.get_name() == string::from_ascii(
            ascii::string(b"Dragon Fruit")
        ), ENFTMismatch);

        // Return the NFT to the treasury cap
        test_scenario::return_to_address<NFT<OTW>>(
            recipient, 
            nft
        );

        // Return the treasury cap to the initial owner
        transfer::public_transfer<NFTTreasuryCap<OTW>>(
            treasury_cap,
            initial_owner, 
        );

        // Clean up the scenario
        test_scenario::end(scenario);
    }
}