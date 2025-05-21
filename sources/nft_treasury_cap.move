module cifarm::nft_treasury_cap {
    // ===== Structs =====
    // This struct is used to store the traits of the NFT

    use cifarm::wrap_ext_kiosik_tests::NFT;

    public struct NFTTreasuryCap<phantom OTW: drop> has key, store {
        // id of the treasury cap
        id: UID,
        // total supply of the treasury cap
        supply: u64,
    } 

    // ===== Public Functions =====
    // This function is to update the total supply of the treasury cap
    public fun update_total_supply<OTW:drop>(
        self: &mut NFTTreasuryCap<OTW>,
        new_supply: u64
    ) {
        self.supply = new_supply;
    }

    // This function is to get the total supply of the treasury cap
    public fun get_total_supply<OTW:drop>(self: &NFTTreasuryCap<OTW>): u64 {
        self.supply
    }

    // This function is to get the id of the treasury cap
    public fun create_treasury_cap<OTW: drop>(ctx: &mut TxContext): NFTTreasuryCap<OTW> {
        // Create a new treasury cap
        NFTTreasuryCap<OTW> {
            id: object::new(ctx),
            supply: 0,
        }
    }
}