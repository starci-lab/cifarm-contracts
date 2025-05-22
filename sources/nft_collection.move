#[allow(unused_field)]
module cifarm::nft_collection {
    // ===== Imports =====
    use std::string::{Self};
    use sui::url::{Url};
    use cifarm::nft_treasury_cap::{NFTTreasuryCap,Self};
    use sui::event::{Self};
    use std::ascii::{Self};
    use sui::url::{Self};
    
    // ===== Strucs =====
    // This struct is used to store the traits of the NFT
    public struct Trait has store, copy, drop {
        // key of the trait
        key: string::String,
        // value of the trait
        value: string::String,
    }

    // This struct is used to store the traits of the NFT
    public struct Traits has store, copy, drop {
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

    // Struct for storing the metadata of the collection
    public struct CollectionMetadata has key, store {
        id: UID,
        // The name of the collection
        name: string::String,
        // The uri of the collection
        uri: Url,
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

    // This event is emitted when a new collection is created
    public struct CollectionCreated has copy, drop {
        // The Object ID of the collection
        object_id: ID,
        // The creator of the collection
        creator: address,
        // The name of the collection
        name: string::String,
        // The uri of the collection
        uri: Url,
    }

    // ===== Errors =====
    // This error is emitted when trait key is not found
    const ETraitKeyNotFound: u64 = 0;

    // ===== Public Functions =====
    // Create a collection
    public fun create_collection<OTW: drop>(
        otw: OTW,
        name: string::String,
        uri: Url,
        ctx: &mut TxContext,
    ): (NFTTreasuryCap<OTW>, CollectionMetadata) {
        // Create collection metadata object
        let treasury = nft_treasury_cap::create_treasury_cap(otw, ctx);
        // Emit the CollectionCreated event
        let event = CollectionCreated {
            object_id: object::id(&treasury),
            creator: ctx.sender(),
            name,
            uri,
        };
        event::emit(event);

        // Return the treasury cap and collection metadata
        (
            treasury,
            CollectionMetadata {
                id: object::new(ctx),
                name,
                uri,
            }
        )
    }

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

    // Update nft functions
    // This function is to update the name of the NFT
    public fun update_name<OTW: drop>(
        self: &mut NFT<OTW>,
        name: string::String,
    ) {
        self.name = name;
    }

    // This function is to update the URI of the NFT
    public fun update_uri<OTW: drop>(
        self: &mut NFT<OTW>,
        uri: Url,
    ) {
        self.uri = uri;
    }
    // This function is to update the traits of the NFT
    public fun update_traits<OTW: drop>(
        self: &mut NFT<OTW>,
        traits: Traits,
    ) {
        self.traits = traits;
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

    // Update functions
    // This function is to update the name of the NFT
    public fun update_collection_name(
        self: &mut CollectionMetadata,
        name: string::String,
    ) {
        self.name = name;
    }

    // This function is to update the URI of the NFT
    public fun update_collection_uri(
        self: &mut CollectionMetadata,
        uri: ascii::String,
    ) {
        self.uri = url::new_unsafe(uri);
    }

    // This function to get the collection name
    public fun get_collection_name(self: &CollectionMetadata): string::String {
        self.name
    }

    // This function to get the collection URI
    public fun get_collection_uri(self: &CollectionMetadata): Url {
        self.uri
    }

    // This function to get traits of the NFT
    public fun get_traits_arr<OTW: drop>(self: &NFT<OTW>): vector<Trait> {
        self.traits.traits
    }

    // Get key of the trait
    public fun get_trait_key(self: &Trait): string::String {
        self.key
    }
    // Get value of the trait
    public fun get_trait_value(self: &Trait): string::String {
        self.value
    }

    // Update trait value by key
    public fun update_trait_value(
        self: &mut Trait,
        key: string::String,
        value: string::String,
    ) {
        if (self.key == key) {
            self.value = value;
        } else {
            assert!(false, ETraitKeyNotFound);
        }
    }
}