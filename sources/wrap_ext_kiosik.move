// === Define module ===
module cifarm::wrap_ext_kiosik {
   // === Imports ===
   // use kiosk::kiosk_lock_rule::Rule as LockRule;
   use sui::kiosk::{Kiosk, KioskOwnerCap};
   use sui::kiosk_extension;

   // Wrap struct as Kiosk core
   public struct WrapExt has drop { }

   // === Constants ===
   const PERMISSIONS: u128 = 11;

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
   public fun wrap_nft<T: key + store>(
      kiosk: &mut Kiosk,
      cap: &KioskOwnerCap,
      nft: T
   ) {
      kiosk.place(
         cap, 
         nft
      );
   }

   // === Unwrap NFT ===
   public fun unwrap_nft<T: key + store>(
      kiosk: &mut Kiosk,
      cap: &KioskOwnerCap,
      nft_id: ID,
      previous_owner: address
   ) {
      let nft = kiosk.take<T>(
         cap,
         nft_id
      );
      // transfer back to the owner
      transfer::public_transfer(
         nft, 
         previous_owner
      );
   }
}