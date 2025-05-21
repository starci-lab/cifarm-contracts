#[allow(unused_field)]
module cifarm::jackfruit_collection {
    // ===== Imports =====
    use cifarm::nft_treasury_cap::{Self};
    use std::string::{Self};
    use std::ascii::{Self};
    use sui::url::{Self, Url};
    use cifarm::nft_collection::{Self, NFT};

    // ===== Structs =====
    // One-time witness struct
    public struct JACKFRUIT_COLLECTION has drop {}

    // ===== Public Functions =====
    // Minting function
    // This function is called when the user wants to mint a new NFT
    // It takes the mint cap, name, uri, traits, recipient and context as parameters
    fun init(otw: JACKFRUIT_COLLECTION, ctx: &mut TxContext) {
        // Create collection
        let (treasury_cap, collection_metadata) = nft_collection::create_collection(
            otw,
            string::from_ascii(ascii::string(b"Jackfruit Collection")),
            url::new_unsafe_from_bytes(b"https://cifarm.sgp1.cdn.digitaloceanspaces.com/1TespPmHeRo5WWGp2z3wMFDKmeVL2SGcB3cCo5y9QS1"),
            ctx
        );
        // make the metadata shared
        transfer::public_share_object(collection_metadata);
        // transfer the treasury cap to the user
        transfer::public_transfer(treasury_cap, ctx.sender());
    }

    // Update the name of the NFT
    public fun update_name(
        self: &mut NFT<JACKFRUIT_COLLECTION>,
        name: string::String,
    ) {
        self.update_name(name);
    }

    public fun mint_nft(
        treasury_cap: &mut nft_treasury_cap::NFTTreasuryCap<JACKFRUIT_COLLECTION>,
        name: string::String,
        uri: Url,
        traits: nft_collection::Traits,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        nft_collection::mint_nft<JACKFRUIT_COLLECTION>(
            treasury_cap,
            name,
            uri,
            traits,
            recipient,
            ctx
        );
    }

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(JACKFRUIT_COLLECTION {}, ctx);
    }
}