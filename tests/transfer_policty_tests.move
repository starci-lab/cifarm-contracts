#[test_only]
module cifarm::transfer_policy_tests {

    use sui::transfer_policy::{ Self };
    use cifarm::transfer_policy::{Self as cifarm_transfer_policy};
    
    public struct OTW has drop {}

    public struct TestAsset has key, store {
        id: UID,
    }

    #[test]
    /// No policy set;
    fun test_default_flow() {
        let ctx = &mut tx_context::dummy();
        let (
            policy,
            cap
        ) = cifarm_transfer_policy::prepare<TestAsset>(ctx);

        // time to make a new transfer request
        let request = transfer_policy::new_request(
            cifarm_transfer_policy::fresh_id(ctx), 
            10_000, 
            cifarm_transfer_policy::fresh_id(ctx)
        );
        policy.confirm_request(request);
        cifarm_transfer_policy::wrapup(policy, cap, ctx);
    }
}
