#[test_only]
module cifarm::wrap_ext_kiosik_tests {

    use sui::kiosk::{Self};
    use sui::kiosk_extension::{Self};
    use sui::test_scenario::{Self, EEmptyInventory};
    use sui::kiosk_test_utils::{Self};
    use cifarm::wrap_ext_kiosik::{Self};
    
    // structs
    // demo struct for testing
    public struct NFT has key, store {
        id: UID,
        growth_acceleration: u64,
        quality_yield: u64,
        disease_resistance: u64,
        harvest_yield_bonus: u64,
    }

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
    #[expected_failure(abort_code = EEmptyInventory)]
    public fun test_wrap_nft() {
        let initial_owner = @0xCAFE;

        let mut scenario = test_scenario::begin(initial_owner);
        let ctx = test_scenario::ctx(&mut scenario);

        kiosk::default(ctx);
        let (mut kiosk, owner_cap) = kiosk_test_utils::get_kiosk(ctx);
        wrap_ext_kiosik::install(&mut kiosk, &owner_cap, ctx);
        // Check if the extension is installed
        assert!(kiosk_extension::is_installed<wrap_ext_kiosik::WrapExt>(&kiosk));
        // Wrap the NFT
        let nft = NFT {
            id: object::new(ctx),
            growth_acceleration: 200,
            quality_yield: 200,
            disease_resistance: 200,
            harvest_yield_bonus: 200,
        };
        wrap_ext_kiosik::wrap_nft(&mut kiosk, &owner_cap, nft);
        //check if the NFT is wrapped
        // This should fail because the NFT is locked
        let _should_fail = test_scenario::take_from_address<NFT>(
            &scenario, 
            initial_owner
        );
        abort 1000 // wrong code
    }

    #[test]
    public fun test_unwrap_nft() {
        let initial_owner = @0xCAFE;

        let mut scenario = test_scenario::begin(initial_owner);
        let ctx = test_scenario::ctx(&mut scenario);

        kiosk::default(ctx);
        let (mut kiosk, owner_cap) = kiosk_test_utils::get_kiosk(ctx);
        wrap_ext_kiosik::install(&mut kiosk, &owner_cap, ctx);
        // Check if the extension is installed
        assert!(kiosk_extension::is_installed<wrap_ext_kiosik::WrapExt>(&kiosk));
        // Wrap the NFT
        let nft = NFT {
            id: object::new(ctx),
            growth_acceleration: 200,
            quality_yield: 200,
            disease_resistance: 200,
            harvest_yield_bonus: 200,
        };
        let nft_id = object::id(&nft);
        wrap_ext_kiosik::wrap_nft(&mut kiosk, &owner_cap, nft);
        // Unwrap the NFT
        wrap_ext_kiosik::unwrap_nft<NFT>(&mut kiosk, &owner_cap, nft_id, initial_owner);
        // return the kiosk to the owner
        kiosk_test_utils::return_kiosk(kiosk, owner_cap, ctx);
        
        // move to next tx, to ensure the NFT is returned to the owner
        test_scenario::next_tx(&mut scenario, initial_owner);
        //check if the NFT is wrapped
        // This should fail because the NFT is locked
        let nft = test_scenario::take_from_address<NFT>(
            &scenario, 
            initial_owner
        );
        assert!(nft.growth_acceleration == 200);
        assert!(nft.quality_yield == 200);
        assert!(nft.disease_resistance == 200);
        assert!(nft.harvest_yield_bonus == 200);

        // Return the NFT to the treasury cap
        test_scenario::return_to_address<NFT>(
            initial_owner, 
            nft
        );
        // Return the treasury cap to the initial owner
        test_scenario::end(scenario);
    }
}
