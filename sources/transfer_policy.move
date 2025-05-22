module cifarm::transfer_policy {

    use sui::transfer_policy::{Self, TransferPolicy, TransferPolicyCap};
    use sui::package;

    public struct OTW has drop {}

    #[test_only]
    public fun prepare<Asset: key + store>(ctx: &mut TxContext): (TransferPolicy<Asset>, TransferPolicyCap<Asset>) {
        let publisher = package::test_claim(OTW {}, ctx);
        let (policy, cap) = transfer_policy::new<Asset>(&publisher, ctx);
        publisher.burn_publisher();
        (policy, cap)
    }

    #[test_only]
    public fun wrapup<Asset: key + store>(
        policy: TransferPolicy<Asset>,
        cap: TransferPolicyCap<Asset>,
        ctx: &mut TxContext,
    ): u64 {
        let profits = policy.destroy_and_withdraw(cap, ctx);
        profits.burn_for_testing()
    }

    public fun fresh_id(ctx: &mut TxContext): ID {
        ctx.fresh_object_address().to_id()
    }
}
