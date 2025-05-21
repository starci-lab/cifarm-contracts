#[allow(unused_field)]
module cifarm::dragon_fruit_collection {
    // ===== Imports =====
    use cifarm::nft_treasury_cap::{Self};
    use std::string::{Self};
    use std::ascii::{Self};
    use sui::url::{Self, Url};
    use cifarm::nft_collection::{Self, CollectionMetadata, NFT};
    
    // ===== Structs =====
    // One-time witness struct
    public struct DRAGON_FRUIT_COLLECTION has drop {}

    // ===== Public Functions =====
    // Minting function
    // This function is called when the user wants to mint a new NFT
    // It takes the mint cap, name, uri, traits, recipient and context as parameters
    fun init(otw: DRAGON_FRUIT_COLLECTION, ctx: &mut TxContext) {
        // Create collection
        let (treasury_cap, collection_metadata) = nft_collection::create_collection(
            otw,
            string::from_ascii(ascii::string(b"Dragon Fruit Collection")),
            url::new_unsafe_from_bytes(b"https://cifarm.sgp1.cdn.digitaloceanspaces.com/1TespPmHeRo5WWGp2z3wMFDKmeVL2SGcB3cCo5y9QS1"),
            ctx
        );
        // make the metadata shared
        transfer::public_share_object(collection_metadata);
        // transfer the treasury cap to the user
        transfer::public_transfer(treasury_cap, ctx.sender());
    }

    public fun mint_nft<OTW: drop>(
        treasury_cap: &mut nft_treasury_cap::NFTTreasuryCap<OTW>,
        name: string::String,
        uri: Url,
        traits: nft_collection::Traits,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        nft_collection::mint_nft<OTW>(
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
        init(DRAGON_FRUIT_COLLECTION {}, ctx);
    }
}