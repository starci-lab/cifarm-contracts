#[test_only]
module cifarm_nft::wrap_ext_kiosik_test {

    use sui::kiosk;
    use sui::test_scenario;
    use sui::kiosk_test_utils;
    use sui::transfer_policy::{Self};
    use cifarm_nft::wrap_ext_kiosik;
    use sui::kiosk_extension::{Self};
    use sui::object::{Self, UID};
    use sui::package::{Self};
    
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
    #[expected_failure(abort_code = sui::kiosk::EItemLocked)]
    public fun test_wrap_nft_and_check_locked() {
        let initial_owner = @0xCAFE;

        let mut scenario = test_scenario::begin(initial_owner);
        let ctx = test_scenario::ctx(&mut scenario);

        kiosk::default(ctx);
        let (mut kiosk, owner_cap) = kiosk_test_utils::get_kiosk(ctx);
        wrap_ext_kiosik::install(&mut kiosk, &owner_cap, ctx);
        // Check if the extension is installed
        assert!(kiosk_extension::is_installed<wrap_ext_kiosik::WrapExt>(&kiosk));
        // Create a transfer policy
        let publisher = sui::package::test_claim<OTW>( OTW {}, ctx);
        let (transfer_policy, _policy_cap) = transfer_policy::new<NFT>(&publisher, ctx);
        // Wrap the NFT
        let item = NFT {
            id: sui::object::new(ctx),
            growth_acceleration: 200,
            quality_yield: 200,
            disease_resistance: 200,
            harvest_yield_bonus: 200,
        };
        let item_id = sui::object::id(&item);
        wrap_ext_kiosik::wrap_nft(&mut kiosk, &owner_cap, &transfer_policy, item);
        //check if the NFT is wrapped
        // This should fail because the NFT is locked
        let _should_fail = kiosk.take<NFT>(&owner_cap, item_id);
        abort 1000 // wrong code
    }
}
