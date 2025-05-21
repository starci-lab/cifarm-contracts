// === Define module ===
module cifarm_nft::wrap_ext_kiosik;

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
public fun install(kiosk: &mut Kiosk, cap: &KioskOwnerCap, ctx: &mut TxContext) {
   kiosk_extension::add(WrapExt {}, kiosk, cap, PERMISSIONS, ctx);
}