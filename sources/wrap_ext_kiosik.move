// === Define module ===
module cifarm::wrap_ext_kiosik {
   // === Imports ===
   // use kiosk::kiosk_lock_rule::Rule as LockRule;
   use sui::kiosk::{Kiosk, KioskOwnerCap};
   use sui::kiosk_extension::{Self};
   use cifarm::nft_collection::{Self,NFT};
   use std::ascii::{Self};
   use std::string::{Self, String};

   // Wrap struct as Kiosk core
   public struct WrapExt has drop { }

   // === Constants ===
   const PERMISSIONS: u128 = 11;
   const OBJECT_ID_KEY: vector<u8> = b"object_id";

   // === Errors ===
   const EWrapHaveObjectId: u64 = 0;
   const EUnwrapObjectIdNotFound: u64 = 1;
   // === Structs ===

   // === Public Functions ===
   // === Instanll Kiosk Extension ===
   public fun install(
      kiosk: &mut Kiosk, 
      cap: &KioskOwnerCap, 
      ctx: &mut TxContext
      ) {
      kiosk_extension::add(
         WrapExt {}, 
         kiosk, cap, 
         PERMISSIONS, 
         ctx
      );
   }
   // === Uninstanll Kiosk Extension ===
   public fun uninstall(
      kiosk: &mut Kiosk, 
      cap: &KioskOwnerCap
   ) {
      kiosk_extension::remove<WrapExt>(
         kiosk, 
         cap);
   }
   // === Wrap NFT ===
   public fun wrap_nft<OTW: drop>(
      kiosk: &mut Kiosk,
      cap: &KioskOwnerCap,
      mut nft: NFT<OTW>,
      // mongodb id for the NFT
      object_id: String
   ) {
      let mut traits = nft.get_traits_arr();
      // check if the object_id is already in the traits
      let mut i = 0;
      while (i < traits.length()) {
         if (traits[i].get_trait_key() == string::from_ascii(ascii::string(OBJECT_ID_KEY))) {
            // if it is, change the object_id
            // update the object_id
            assert!(false, EWrapHaveObjectId)
         };
         i = i + 1;
      };
      // create the object_id trait
      let object_id_trait = nft_collection::create_trait(
         string::from_ascii(ascii::string(OBJECT_ID_KEY)),
         object_id
      );
      // add the object_id trait to the traits
      traits.push_back(object_id_trait);
      let traits_wrapper = nft_collection::create_traits(
            traits
         );
         // update the traits
      nft.update_traits_internal(traits_wrapper);
      // update the kiosk
      kiosk.place(
         cap, 
         nft
      );
   }

   // === Unwrap NFT ===
   public fun unwrap_nft<OTW: drop>(
      kiosk: &mut Kiosk,
      cap: &KioskOwnerCap,
      nft_id: ID,
      previous_owner: address
   ) {
      let mut nft = kiosk.take<NFT<OTW>>(
         cap,
         nft_id
      );
      // delete the object_id trait
      let mut traits = nft.get_traits_arr();
      let mut i = 0;
      let mut found = false;
      while (i < traits.length()) {
         if (traits[i].get_trait_key() == string::from_ascii(ascii::string(OBJECT_ID_KEY))) {
            // if it is, delete the object_id
            // update the object_id
            traits.remove(i);
            found = true;
         };
         i = i + 1;
      };
      if (!found) {
         // if it is not, abort
         assert!(false, EUnwrapObjectIdNotFound)
      };
      // update the traits
      let traits_wrapper = nft_collection::create_traits(
         traits
      );
      nft.update_traits_internal(traits_wrapper);
      // transfer back to the owner
      transfer::public_transfer(
         nft, 
         previous_owner
      );
   }
}