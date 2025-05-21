#[allow(unused_field)]
module cifarm::nft_collection {
    // ===== Imports =====
    use std::string::{Self};
    use sui::url::{Url};
    use cifarm::nft_treasury_cap::{NFTTreasuryCap};
    use sui::event::{Self};

    // ===== Strucs =====
    // This struct is used to store the traits of the NFT
    public struct Trait has store, copy {
        // key of the trait
        key: string::String,
        // value of the trait
        value: string::String,
    }

    // This struct is used to store the traits of the NFT
    public struct Traits has store, copy {
        // traits of the NFT
        traits: vector<Trait>,
    }

    // This struct is generic to create any NFT
    // It has a type parameter T which is used to create the NFT
    public struct NFT<phantom OTW: drop> has key, store {
        // id of the NFT
        id: UID,
        // name of the NFT
        name: string::String,
        // URI for the token
        uri: Url,
        // traits of the NFT
        traits: Traits,
    }

    // ===== Events =====
    // This event is emitted when a new NFT is minted
    public struct NFTMinted has copy, drop {
        // The Object ID of the NFT
        object_id: ID,
        // The creator of the NFT
        creator: address,
        // The name of the NFT
        name: string::String,
    }

    // ===== Public Functions =====
    // Minting function
    // This function is called when the user wants to mint a new NFT
    // It takes the mint cap, name, uri, traits, recipient and context as parameters
    public fun mint_nft<OTW: drop>(
        treasury_cap: &mut NFTTreasuryCap<OTW>,
        name: string::String,
        uri: Url,
        traits: Traits,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        // Create treasury cap object
        let total_supply = treasury_cap.get_total_supply();
        treasury_cap.update_total_supply(total_supply + 1);
        // Transfer the nft to the recipient
        // Create nft object
        let nft = NFT<OTW> {
            id: object::new(ctx),
            name,
            uri,
            traits,
        };
        // Emit the NFTMinted event
        let object_id = object::id(&nft);
        let event = NFTMinted {
            object_id,
            creator: ctx.sender(),
            name: nft.name,
        };
        event::emit(event);
        // Transfer the nft to the recipient
        transfer::public_transfer(nft, recipient);
    }

    // This function is used to create a new trait
    public fun create_trait(
        key: string::String,
        value: string::String,
    ): Trait {
        Trait {
            key,
            value,
        }
    }

    // This function is used to create a new traits
    public fun create_traits(
        traits: vector<Trait>,
    ): Traits {
        Traits {
            traits,
        }
    }

    // This function to get the name of the NFT
    public fun get_name<OTW: drop>(self: &NFT<OTW>): string::String {
        self.name
    }

    // This function to get the URI of the NFT
    public fun get_uri<OTW: drop>(self: &NFT<OTW>): Url {
        self.uri
    }

    // This function to get the traits of the NFT
    public fun get_traits<OTW: drop>(self: &NFT<OTW>): Traits {
        self.traits
    }
}