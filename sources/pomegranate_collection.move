#[allow(unused_field)]
module cifarm::pomegranate_collection {
    // ===== Imports =====
    use cifarm::nft_treasury_cap::{Self};
    use std::string::{Self};
    use std::ascii::{Self};
    use sui::url::{Self};
    use cifarm::nft_collection::{Self};

    // ===== Structs =====
    // One-time witness struct
    public struct POMEGRANATE_COLLECTION has drop {}

    // ===== Public Functions =====
    // Minting function
    // This function is called when the user wants to mint a new NFT
    // It takes the mint cap, name, uri, traits, recipient and context as parameters
    fun init(otw: POMEGRANATE_COLLECTION, ctx: &mut TxContext) {
        // Create collection
        let (treasury_cap, collection_metadata) = nft_collection::create_collection(
            otw,
            string::from_ascii(ascii::string(b"Pomegranate Collection")),
            url::new_unsafe_from_bytes(b"https://cifarm.sgp1.cdn.digitaloceanspaces.com/1TespPmHeRo5WWGp2z3wMFDKmeVL2SGcB3cCo5y9QS1"),
            ctx
        );
        // make the metadata shared
        transfer::public_share_object(collection_metadata);
        // transfer the treasury cap to the user
        transfer::public_transfer(treasury_cap, ctx.sender());
    }

    public entry fun mint_nft(
        treasury_cap: &mut nft_treasury_cap::NFTTreasuryCap<POMEGRANATE_COLLECTION>,
        name: string::String,
        uri: string::String,
        trait_keys: vector<string::String>, // Pass traits as vectors of strings or bytes
        trait_values: vector<string::String>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let traits = nft_collection::make_traits(trait_keys, trait_values);
        let uri_byte = string::as_bytes(&uri);
        nft_collection::mint_nft<POMEGRANATE_COLLECTION>(
            treasury_cap,
            name,
            url::new_unsafe_from_bytes(*uri_byte),
            traits,
            recipient,
            ctx
        );
    }

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(POMEGRANATE_COLLECTION {}, ctx);
    }
}