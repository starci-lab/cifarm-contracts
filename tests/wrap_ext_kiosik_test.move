#[test_only]
module cifarm_nft::wrap_ext_kiosik_test;

use sui::kiosk;
use sui::test_scenario;
use sui::kiosk_test_utils;

#[test]
public fun test_install_extension() {
    let initial_owner = @0xCAFE;

    let mut scenario = test_scenario::begin(initial_owner);
    let ctx = test_scenario::ctx(&mut scenario);

    kiosk::default(ctx);
    let (mut kiosk, owner_cap) = kiosk_test_utils::get_kiosk(ctx);

    let old_owner = kiosk.owner();
    kiosk.set_owner(&owner_cap, ctx);
    assert!(kiosk.owner() == old_owner);
    kiosk.set_owner_custom(&owner_cap, @0xA11CE);
    assert!(kiosk.owner() != old_owner);
    assert!(kiosk.owner() == @0xA11CE);

    kiosk_test_utils::return_kiosk(kiosk, owner_cap, ctx);

    test_scenario::end(scenario);
}   

