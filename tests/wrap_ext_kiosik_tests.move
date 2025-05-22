#[test_only]
module cifarm::wrap_ext_kiosik_tests {

    use sui::kiosk::{Self};
    use sui::kiosk_extension::{Self};
    use sui::test_scenario::{Self};
    use sui::kiosk_test_utils::{Self};
    use cifarm::wrap_ext_kiosik::{Self};
    use sui::url::{Self};
    use cifarm::nft_treasury_cap::{Self};
    use cifarm::nft_collection::{Self, NFT, Trait};
    use std::ascii::{Self};
    use std::string::{Self};
    
    public struct OTW has drop {}

    #[test]
    public fun test_install_extension() {
        let initial_owner = @0xCAFE;

        let mut scenario = test_scenario::begin(initial_owner);
        let ctx = test_scenario::ctx(&mut scenario);

        kiosk::default(ctx);
        let (mut kiosk, owner_cap) = kiosk_test_utils::get_kiosk(ctx);
        // Install the extension
        wrap_ext_kiosik::install(&mut kiosk, &owner_cap, ctx);
        // Check if the extension is installed
        assert!(kiosk_extension::is_installed<wrap_ext_kiosik::WrapExt>(&kiosk));
        // Uninstall the extension
        kiosk_test_utils::return_kiosk(kiosk, owner_cap, ctx);
        // Check if the extension is uninstalled
        test_scenario::end(scenario);
    }   

    #[test]
    public fun test_uninstall_extension() {
        let initial_owner = @0xCAFE;

        let mut scenario = test_scenario::begin(initial_owner);
        let ctx = test_scenario::ctx(&mut scenario);

        kiosk::default(ctx);
        let (mut kiosk, owner_cap) = kiosk_test_utils::get_kiosk(ctx);
        wrap_ext_kiosik::install(&mut kiosk, &owner_cap, ctx);
        // Check if the extension is installed
        assert!(kiosk_extension::is_installed<wrap_ext_kiosik::WrapExt>(&kiosk));
        // Uninstall the extension
        wrap_ext_kiosik::uninstall(&mut kiosk, &owner_cap);
        // Check if the extension is uninstalled
        assert!(!kiosk_extension::is_installed<wrap_ext_kiosik::WrapExt>(&kiosk));
        kiosk_test_utils::return_kiosk(kiosk, owner_cap, ctx);
        test_scenario::end(scenario);
    }

    #[test]
    public fun test_wrap_nft() {
        // Test the wrap_nft function
        let initial_owner = @0xCAFE;
        // Create a test scenario
        let mut scenario = test_scenario::begin(initial_owner);
        let ctx = test_scenario::ctx(&mut scenario);
        // Create the kiosk
        kiosk::default(ctx);
        let (mut kiosk, owner_cap) = kiosk_test_utils::get_kiosk(ctx);
        wrap_ext_kiosik::install(&mut kiosk, &owner_cap, ctx);
        // Check if the extension is installed
        assert!(kiosk_extension::is_installed<wrap_ext_kiosik::WrapExt>(&kiosk));
        // Wrap the NFT
        // Mint NFT
        create_nft(initial_owner, ctx);
        // Next transaction to retrieve objects
        test_scenario::next_tx(&mut scenario, initial_owner);
        test_scenario::next_tx(&mut scenario, initial_owner);
        // take the nft from the initial owner
        let nft = test_scenario::take_from_address<NFT<OTW>>(
            &scenario, 
            initial_owner
        );
        let nft_id = object::id(&nft);
        let object_id_value = string::from_ascii(ascii::string(b"64f1c872e1d5c234fae5c1a2"));
        wrap_ext_kiosik::wrap_nft(
            &mut kiosk, 
            &owner_cap, 
            nft, 
            object_id_value
        );
        // get next transaction
        test_scenario::next_tx(&mut scenario, initial_owner);
        // take the nft from the initial owner
        let nft_taken = kiosk.take<NFT<OTW>>(
            &owner_cap, 
            nft_id
        );
        //check nft traits
        let traits = nft_taken.get_traits_arr();
        assert!(traits.length() == 4);
        assert!(traits[3].get_trait_key() == string::from_ascii(
            ascii::string(b"object_id")
        ));
        assert!(traits[3].get_trait_value() == string::from_ascii(
            ascii::string(b"64f1c872e1d5c234fae5c1a2")
        ));
        // clean up the scenario
        transfer::public_transfer(nft_taken, initial_owner);
        transfer::public_transfer(kiosk, initial_owner);
        transfer::public_transfer(owner_cap, initial_owner);
        // end the scenario
        test_scenario::end(scenario);
    }

    #[test]
    public fun test_unwrap_nft() {
        let initial_owner = @0xCAFE;
        // Create a test scenario
        let mut scenario = test_scenario::begin(initial_owner);
        let ctx = test_scenario::ctx(&mut scenario);
        // Mint NFT
        kiosk::default(ctx);
        let (mut kiosk, owner_cap) = kiosk_test_utils::get_kiosk(ctx);
        wrap_ext_kiosik::install(&mut kiosk, &owner_cap, ctx);
        // Check if the extension is installed
        assert!(kiosk_extension::is_installed<wrap_ext_kiosik::WrapExt>(&kiosk));
        // Wrap the NFT
        // Mint NFT
        create_nft(initial_owner, ctx);
        // Next transaction to retrieve objects
        test_scenario::next_tx(&mut scenario, initial_owner);
        // take the nft from the initial owner
        let nft = test_scenario::take_from_address<NFT<OTW>>(
            &scenario, 
            initial_owner
        );
        let nft_id = object::id(&nft);
        // // let (mut kiosk, owner_cap) = kiosk_test_utils::get_kiosk(ctx);
        // // kiosk_test_utils::return_kiosk(kiosk, owner_cap, ctx);
        // let nft_id = object::id(&nft);
        // // // // Check if the NFT is owned by the initial owner
        let object_id_value = string::from_ascii(ascii::string(b"64f1c872e1d5c234fae5c1a2"));
        wrap_ext_kiosik::wrap_nft(
            &mut kiosk, 
            &owner_cap, 
            nft, 
            object_id_value
        );
        // Unwrap the NFT
        wrap_ext_kiosik::unwrap_nft<OTW>(&mut kiosk, &owner_cap, nft_id, initial_owner);
        // // return the kiosk to the owner
        // move to next tx, to ensure the NFT is returned to the owner
        test_scenario::next_tx(&mut scenario, initial_owner);
        //check if the NFT is wrapped
        // This should fail because the NFT is locked
        let nft_2 = test_scenario::take_from_address<NFT<OTW>>(
            &scenario, 
            initial_owner
        );
        assert!(nft_2.get_traits_arr().length() == 3);
        assert!(nft_2.get_name() == string::from_ascii(
            ascii::string(b"Dragon Fruit")
        ));
        assert!(nft_2.get_uri() == url::new_unsafe_from_bytes(b"https://cifarm.sgp1.cdn.digitaloceanspaces.com/1TespPmHeRo5WWGp2z3wMFDKmeVL2SGcB3cCo5y9QS1"));

        // Return the NFT to the the inital owner
        test_scenario::return_to_address<NFT<OTW>>(
            initial_owner, 
            nft_2
        );
        //Clean up the scenario
        // return the kiosk to the owner
        transfer::public_transfer(kiosk, initial_owner);
        transfer::public_transfer(owner_cap, initial_owner);
        // return the scenario to the owner
        test_scenario::end(scenario);
    }

     // internal function to create a NFT
    fun create_nft(initial_owner: address, ctx: &mut TxContext) {
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
        nft_collection::mint_nft<OTW>(
            &mut treasury_cap,
            name,
            uri,
            traits,
            initial_owner,
            ctx
        );
        // Return the treasury cap to the initial owner
        transfer::public_transfer(treasury_cap, initial_owner);
    }
}
